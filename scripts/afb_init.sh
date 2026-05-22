#!/usr/bin/env bash
#
# afb_init.sh — bootstrap AgentFrameworkBootstrap assets into a downstream project.
#
# Native bash implementation (no PowerShell required). Merges/copies `.agents/`,
# performs an additive `agents.yml` merge, optionally scaffolds `.specify/`,
# copies root AI entry points, and sets up canonical memory at ai/memory/memory.md.
#
# Usage:
#   afb_init.sh [--target DIR] [--source-repo DIR] [--pack-source DIR]...
#               [--dry-run] [--skip-spec-kit] [--skip-cursor]
#               [--skip-agents-md] [--no-canonical-memory] [--validate-only]
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/afb_merge_agents.sh
. "$SCRIPT_DIR/lib/afb_merge_agents.sh"

TARGET="$(pwd)"
SOURCE_REPO=""
PACK_SOURCES=()
DRY_RUN=0
SKIP_SPEC_KIT=0
SKIP_CURSOR=0
SKIP_AGENTS_MD=0
NO_CANONICAL_MEMORY=0
VALIDATE_ONLY=0

info() { echo "afb_init: $*"; }
warn() { echo "afb_init: $*" >&2; }
die()  { echo "afb_init: error: $*" >&2; exit 1; }

usage() {
  sed -n '3,14p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

# Resolve a path to absolute form (path must exist).
abspath() {
  if [ -d "$1" ]; then (cd "$1" && pwd);
  else (cd "$(dirname "$1")" && printf '%s/%s\n' "$(pwd)" "$(basename "$1")"); fi
}

# --- argument parsing ---
while [ $# -gt 0 ]; do
  case "$1" in
    --target)            TARGET="$2"; shift 2 ;;
    --target=*)          TARGET="${1#*=}"; shift ;;
    --source-repo)       SOURCE_REPO="$2"; shift 2 ;;
    --source-repo=*)     SOURCE_REPO="${1#*=}"; shift ;;
    --pack-source)       PACK_SOURCES+=("$2"); shift 2 ;;
    --pack-source=*)     PACK_SOURCES+=("${1#*=}"); shift ;;
    --dry-run)           DRY_RUN=1; shift ;;
    --skip-spec-kit)     SKIP_SPEC_KIT=1; shift ;;
    --skip-cursor)       SKIP_CURSOR=1; shift ;;
    --skip-agents-md)    SKIP_AGENTS_MD=1; shift ;;
    --no-canonical-memory) NO_CANONICAL_MEMORY=1; shift ;;
    --validate-only)     VALIDATE_ONLY=1; shift ;;
    -h|--help)           usage 0 ;;
    --) shift; break ;;
    -*) die "unknown option: $1 (try --help)" ;;
    *)  TARGET="$1"; shift ;;
  esac
done

if [ -z "$SOURCE_REPO" ]; then
  SOURCE_REPO="$(abspath "$SCRIPT_DIR/..")"
fi
[ -d "$SOURCE_REPO" ] || die "SourceRepo not found: $SOURCE_REPO"

# Merge-copy the contents of a directory (including dotfiles), overwriting.
copy_dir_merge() {
  local src="$1" dst="$2"
  [ -d "$src" ] || die "Source directory not found: $src"
  if [ "$DRY_RUN" = "1" ]; then
    info "[dry-run] Merge-copy folder: $src -> $dst"; return 0
  fi
  mkdir -p "$dst"
  cp -R "$src/." "$dst/"
}

initialize_spec_kit_scaffold() {
  local fw="$1" dst="$2"
  local spec_dst="$dst/.specify"
  if [ -d "$spec_dst" ]; then
    info 'Spec Kit: `.specify` already exists — skipping scaffold (validate or update manually).'
    local need=(
      "$spec_dst/integration.json"
      "$spec_dst/templates/agent-file-template.md"
      "$spec_dst/scripts/powershell/common.ps1"
    )
    local p
    for p in "${need[@]}"; do
      [ -e "$p" ] || warn "Spec Kit validation: expected file missing: $p"
    done
    return 0
  fi

  local spec_src="$fw/.specify"
  [ -d "$spec_src" ] || die "Framework \`.specify\` not found under: $fw"

  local d
  for d in templates scripts workflows integrations; do
    if [ -d "$spec_src/$d" ]; then
      if [ "$DRY_RUN" = "1" ]; then info "[dry-run] Would copy $spec_src/$d -> $spec_dst/$d";
      else mkdir -p "$spec_dst/$d"; cp -R "$spec_src/$d/." "$spec_dst/$d/"; fi
    fi
  done

  local f
  for f in integration.json init-options.json; do
    if [ -f "$spec_src/$f" ]; then
      if [ "$DRY_RUN" = "1" ]; then info "[dry-run] Would copy $spec_src/$f -> $spec_dst/$f";
      else mkdir -p "$spec_dst"; cp "$spec_src/$f" "$spec_dst/$f"; fi
    fi
  done

  if [ -f "$spec_src/memory/constitution.md" ]; then
    if [ "$DRY_RUN" = "1" ]; then info "[dry-run] Would copy $spec_src/memory/constitution.md -> $spec_dst/memory/constitution.md";
    else mkdir -p "$spec_dst/memory"; cp "$spec_src/memory/constitution.md" "$spec_dst/memory/constitution.md"; fi
  fi

  local specs_readme="$spec_dst/specs/README.md"
  if [ ! -f "$specs_readme" ]; then
    if [ "$DRY_RUN" = "1" ]; then info "[dry-run] Would create $specs_readme";
    else
      mkdir -p "$spec_dst/specs"
      cat > "$specs_readme" <<'EOF'
# Spec Kit specs

Create initiative folders under `.specify/specs/<FeatureId>/` per `docs/conventions.md` (or your local copy of that contract).

FeatureId format: `NNN-kebab-case-short-name`.
EOF
    fi
  fi

  info 'Spec Kit: scaffold copied (initiatives under `.specify/specs/` are not copied).'
}

ensure_canonical_memory() {
  local fw="$1" dst="$2"
  local dest="$dst/ai/memory/memory.md"
  [ -f "$dest" ] && return 0
  if [ "$DRY_RUN" = "1" ]; then info "[dry-run] Would create $dest"; return 0; fi
  mkdir -p "$(dirname "$dest")"
  if [ -f "$fw/ai/memory/memory.md" ]; then
    cp "$fw/ai/memory/memory.md" "$dest"
  else
    cat > "$dest" <<'EOF'
# Project memory (canonical)

**Single source of truth** for durable facts, decisions, and continuity across assistants.
Keep content safe to commit—no secrets.

## Log

- YYYY-MM-DD — Initialized via `afb_init`.
EOF
  fi
}

set_delegated_agent_memories() {
  local dst="$1"
  local agents_dir="$dst/.agents"
  [ -d "$agents_dir" ] || return 0
  local stub
  stub='# Delegated memory

Long-lived project memory lives in the repository at **[`ai/memory/memory.md`](../../../ai/memory/memory.md)** (path relative from this file).

Do not rely on device-local vendor memory for facts that belong in git.

## Scratch (optional)

'
  local d name
  for d in "$agents_dir"/*/; do
    [ -d "$d" ] || continue
    name="$(basename "$d")"
    [ "$name" = ".skills" ] && continue
    local mem_file="$d.memory/memory.md"
    if [ "$DRY_RUN" = "1" ]; then info "[dry-run] Would write delegated memory stub: $mem_file";
    else mkdir -p "$d.memory"; printf '%s' "$stub" > "$mem_file"; fi
  done
}

copy_ai_entry_points() {
  local fw="$1" dst="$2"
  local rel src dest parent
  for rel in "AGENTS.md" "CLAUDE.md" "GEMINI.md" ".github/copilot-instructions.md"; do
    dest="$dst/$rel"; src="$fw/$rel"
    if [ ! -e "$dest" ] && [ -f "$src" ]; then
      if [ "$DRY_RUN" = "1" ]; then info "[dry-run] Would copy $src -> $dest";
      else parent="$(dirname "$dest")"; mkdir -p "$parent"; cp "$src" "$dest"; fi
    fi
  done
}

# Validate a project root. Prints warnings; sets AFB_VALIDATION_ISSUES count.
validate_project() {
  local root="$1"
  AFB_VALIDATION_ISSUES=0
  local _issue
  _issue() { warn "$1"; AFB_VALIDATION_ISSUES=$((AFB_VALIDATION_ISSUES + 1)); }

  local yml="$root/agents.yml"
  if [ ! -f "$yml" ]; then _issue "Missing agents.yml at repo root."; return; fi

  # duplicate ids
  local dup
  dup="$(afb_agent_ids "$yml" | sort | uniq -d)"
  if [ -n "$dup" ]; then
    local id
    while IFS= read -r id; do [ -n "$id" ] && _issue "Duplicate agents.yml entry for id: $id"; done <<EOF
$dup
EOF
  fi

  # orphan agent folders
  if [ -d "$root/.agents" ]; then
    local d name
    for d in "$root/.agents"/*/; do
      [ -d "$d" ] || continue
      name="$(basename "$d")"
      [ "$name" = ".skills" ] && continue
      if ! grep -qE "^[[:space:]]*path:[[:space:]]*\.agents/${name}[[:space:]]*$" "$yml"; then
        _issue "Orphan .agents/$name folder (no matching 'path: .agents/$name' in agents.yml)."
      fi
    done
  fi

  # AI context files should reference canonical memory
  local canon="ai/memory/memory.md" f
  for f in "$root/CLAUDE.md" "$root/GEMINI.md" "$root/.cursor/rules/specify-rules.mdc" "$root/.cursor/rules/spec-kit-workflow.md"; do
    if [ -f "$f" ] && ! grep -q "ai/memory/memory\.md" "$f"; then
      _issue "AI context file should reference canonical memory ($canon): $f"
    fi
  done

  [ -f "$root/$canon" ] || _issue "Missing canonical memory file: $canon"
}

# --- validate-only mode ---
if [ "$VALIDATE_ONLY" = "1" ]; then
  [ -e "$TARGET" ] || die "ValidateOnly: Target not found: $TARGET"
  v_root="$(abspath "$TARGET")"
  validate_project "$v_root"
  if [ "$AFB_VALIDATION_ISSUES" -eq 0 ]; then
    info "Validation OK for $v_root"; exit 0
  fi
  exit 2
fi

# --- create / resolve target ---
if [ ! -e "$TARGET" ]; then
  if [ "$DRY_RUN" = "1" ]; then info "[dry-run] Target does not exist yet (would create): $TARGET";
  else mkdir -p "$TARGET"; fi
fi
[ -e "$TARGET" ] && TARGET="$(abspath "$TARGET")"

info "Source framework: $SOURCE_REPO"
info "Target project:   $TARGET"

# --- trunk assets ---
[ -d "$SOURCE_REPO/.agents" ] || die "No \`.agents\` folder under framework root: $SOURCE_REPO"
copy_dir_merge "$SOURCE_REPO/.agents" "$TARGET/.agents"

afb_merge_agents_yaml_file "$SOURCE_REPO/agents.yml" "$TARGET/agents.yml" "$DRY_RUN"

if [ "$SKIP_AGENTS_MD" != "1" ]; then
  copy_ai_entry_points "$SOURCE_REPO" "$TARGET"
fi

if [ "$SKIP_CURSOR" != "1" ] && [ -d "$SOURCE_REPO/.cursor" ]; then
  copy_dir_merge "$SOURCE_REPO/.cursor" "$TARGET/.cursor"
fi

if [ "$SKIP_SPEC_KIT" != "1" ]; then
  initialize_spec_kit_scaffold "$SOURCE_REPO" "$TARGET"
fi

if [ "$NO_CANONICAL_MEMORY" != "1" ]; then
  ensure_canonical_memory "$SOURCE_REPO" "$TARGET"
  set_delegated_agent_memories "$TARGET"
fi

# --- packs ---
for pack in "${PACK_SOURCES[@]:-}"; do
  [ -z "$pack" ] && continue
  [ -d "$pack" ] || die "PackSource not found: $pack"
  pack="$(abspath "$pack")"
  info "Merging pack: $pack"
  [ -d "$pack/.agents" ] && copy_dir_merge "$pack/.agents" "$TARGET/.agents"
  [ -f "$pack/agents.yml" ] && afb_merge_agents_yaml_file "$pack/agents.yml" "$TARGET/agents.yml" "$DRY_RUN"
done

# --- post-run validation ---
if [ "$DRY_RUN" = "1" ]; then
  info 'Skipping post-run validation in --dry-run (no files written yet).'
else
  info 'Running validation...'
  validate_project "$TARGET"
  if [ "$AFB_VALIDATION_ISSUES" -gt 0 ]; then
    warn 'Validation reported issues (see above). Exit code 2.'
    exit 2
  fi
fi

info 'Done.'
exit 0
