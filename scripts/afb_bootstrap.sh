#!/usr/bin/env bash
#
# afb_bootstrap.sh — download pinned GitHub release archives, then run afb_init.sh.
#
# One-time flow for downstream projects: downloads
# https://github.com/<org>/<repo>/archive/refs/tags/<tag>.zip for the framework
# tag (and each optional pack tag), unpacks under a temp dir, then invokes
# scripts/afb_init.sh from the unpacked framework tree.
#
# Requires network access plus `curl` (or `wget`) and `unzip`.
#
# Usage:
#   afb_bootstrap.sh --framework-tag TAG [--pack-tag TAG]... [--target DIR]
#                    [--github-org ORG] [--github-repo REPO]
#                    [--dry-run] [--skip-cleanup] [--allow-dirty-git]
#                    [--skip-spec-kit] [--skip-cursor] [--skip-agents-md]
#                    [--no-canonical-memory]
#
set -euo pipefail

FRAMEWORK_TAG=""
PACK_TAGS=()
TARGET="$(pwd)"
GITHUB_ORG="arioch666"
GITHUB_REPO="AgentFrameworkBootstrap"
DRY_RUN=0
SKIP_CLEANUP=0
ALLOW_DIRTY_GIT=0
PASSTHROUGH=()

info() { echo "afb_bootstrap: $*"; }
die()  { echo "afb_bootstrap: error: $*" >&2; exit 1; }

usage() { sed -n '3,18p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

while [ $# -gt 0 ]; do
  case "$1" in
    --framework-tag)   FRAMEWORK_TAG="$2"; shift 2 ;;
    --framework-tag=*) FRAMEWORK_TAG="${1#*=}"; shift ;;
    --pack-tag)        PACK_TAGS+=("$2"); shift 2 ;;
    --pack-tag=*)      PACK_TAGS+=("${1#*=}"); shift ;;
    --target)          TARGET="$2"; shift 2 ;;
    --target=*)        TARGET="${1#*=}"; shift ;;
    --github-org)      GITHUB_ORG="$2"; shift 2 ;;
    --github-org=*)    GITHUB_ORG="${1#*=}"; shift ;;
    --github-repo)     GITHUB_REPO="$2"; shift 2 ;;
    --github-repo=*)   GITHUB_REPO="${1#*=}"; shift ;;
    --dry-run)         DRY_RUN=1; shift ;;
    --skip-cleanup)    SKIP_CLEANUP=1; shift ;;
    --allow-dirty-git) ALLOW_DIRTY_GIT=1; shift ;;
    --skip-spec-kit)        PASSTHROUGH+=(--skip-spec-kit); shift ;;
    --skip-cursor)          PASSTHROUGH+=(--skip-cursor); shift ;;
    --skip-agents-md)       PASSTHROUGH+=(--skip-agents-md); shift ;;
    --no-canonical-memory)  PASSTHROUGH+=(--no-canonical-memory); shift ;;
    -h|--help)         usage 0 ;;
    *) die "unknown option: $1 (try --help)" ;;
  esac
done

[ -n "$FRAMEWORK_TAG" ] || die "--framework-tag is required"

abspath() {
  if [ -d "$1" ]; then (cd "$1" && pwd);
  else (cd "$(dirname "$1")" && printf '%s/%s\n' "$(pwd)" "$(basename "$1")"); fi
}

download() {
  local url="$1" out="$2"
  if command -v curl >/dev/null 2>&1; then curl -fsSL -o "$out" "$url";
  elif command -v wget >/dev/null 2>&1; then wget -qO "$out" "$url";
  else die "need curl or wget to download $url"; fi
}

zip_url() { echo "https://github.com/$1/$2/archive/refs/tags/$3.zip"; }

# Download + unpack a tag zip into $WORK/$label; echo the single top-level dir.
expand_release_zip() {
  local url="$1" label="$2"
  local zip="$WORK/$label.zip" into="$WORK/$label"
  info "Downloading $url"
  download "$url" "$zip"
  mkdir -p "$into"
  unzip -q "$zip" -d "$into"
  rm -f "$zip"
  local dirs=("$into"/*/)
  [ "${#dirs[@]}" -eq 1 ] || die "expected exactly one top-level folder under $into after unzip; found ${#dirs[@]}."
  abspath "${dirs[0]}"
}

assert_clean_git() {
  local root="$1"
  [ -d "$root/.git" ] || return 0
  if [ "$ALLOW_DIRTY_GIT" = "1" ]; then info "allow-dirty-git: skipping git cleanliness check."; return 0; fi
  local porcelain
  porcelain="$(git -C "$root" status --porcelain 2>/dev/null || true)"
  if [ -n "$porcelain" ]; then
    die "Target git repo has uncommitted changes. Commit or stash, or pass --allow-dirty-git."$'\n'"$(printf '%s\n' "$porcelain" | head -20)"
  fi
}

# resolve target
if [ -e "$TARGET" ]; then
  TARGET="$(abspath "$TARGET")"
elif [ "$DRY_RUN" = "1" ]; then
  info "[dry-run] Target does not exist yet: $TARGET (afb_init may create it)"
else
  mkdir -p "$TARGET"; TARGET="$(abspath "$TARGET")"
fi

assert_clean_git "$TARGET"

command -v unzip >/dev/null 2>&1 || [ "$DRY_RUN" = "1" ] || die "need unzip to unpack release archives"

WORK="$(mktemp -d "${TMPDIR:-/tmp}/afb-bootstrap-XXXXXXXX")"
cleanup() {
  if [ "$DRY_RUN" != "1" ] && [ "$SKIP_CLEANUP" != "1" ] && [ -d "$WORK" ]; then
    info "Removing temp dir: $WORK"; rm -rf "$WORK"
  elif [ "$SKIP_CLEANUP" = "1" ] && [ -d "$WORK" ]; then
    info "skip-cleanup: temp dir left at: $WORK"
  fi
}
trap cleanup EXIT

fw_url="$(zip_url "$GITHUB_ORG" "$GITHUB_REPO" "$FRAMEWORK_TAG")"
PACK_ROOTS=()

if [ "$DRY_RUN" = "1" ]; then
  info "[dry-run] Framework URL: $fw_url"
  i=0
  for tag in "${PACK_TAGS[@]:-}"; do
    [ -z "$tag" ] && continue
    i=$((i+1))
    info "[dry-run] Pack URL ($tag): $(zip_url "$GITHUB_ORG" "$GITHUB_REPO" "$tag")"
  done
  info '[dry-run] Would run afb_init.sh with:'
  echo "  --target      $TARGET"
  echo "  --source-repo <unpacked-framework-root>"
  for ((j=1;j<=i;j++)); do echo "  --pack-source <unpacked-pack-$j>"; done
  exit 0
fi

framework_root="$(expand_release_zip "$fw_url" framework)"

i=0
for tag in "${PACK_TAGS[@]:-}"; do
  [ -z "$tag" ] && continue
  i=$((i+1))
  PACK_ROOTS+=("$(expand_release_zip "$(zip_url "$GITHUB_ORG" "$GITHUB_REPO" "$tag")" "pack-$i")")
done

init_script="$framework_root/scripts/afb_init.sh"
[ -f "$init_script" ] || die "Unpacked framework missing scripts/afb_init.sh under: $framework_root"

args=(--target "$TARGET" --source-repo "$framework_root")
for p in "${PACK_ROOTS[@]:-}"; do [ -n "$p" ] && args+=(--pack-source "$p"); done
if [ "${#PASSTHROUGH[@]}" -gt 0 ]; then args+=("${PASSTHROUGH[@]}"); fi

info 'Invoking afb_init.sh...'
bash "$init_script" "${args[@]}"

info 'Done. Commit vendored files in your project when satisfied.'
