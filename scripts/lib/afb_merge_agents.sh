# afb_merge_agents.sh — helpers for additive agents.yml merges (no YAML dependency).
# Source this file: `. "$(dirname "$0")/lib/afb_merge_agents.sh"`

# Print the agent ids under the top-level `agents:` list.
afb_agent_ids() {
  awk '
    /^agents:[[:space:]]*$/ { inagents=1; next }
    inagents && /^  - id:[[:space:]]+/ {
      id=$0; sub(/^  - id:[[:space:]]+/,"",id); sub(/[[:space:]]+$/,"",id); print id
    }
  ' "$1"
}

# Print the ids under delegation_matrix.orchestration.can_delegate_to.
afb_can_delegate_to() {
  awk '
    /^delegation_matrix:[[:space:]]*$/ { indm=1; ino=0; inlist=0; next }
    indm==1 && /^[a-z_]+:[[:space:]]*$/ { exit }
    indm==1 && /^  orchestration:[[:space:]]*$/ { ino=1; inlist=0; next }
    ino==1 && /^  [a-z_]+:[[:space:]]*$/ { exit }
    ino==1 && /^    can_delegate_to:[[:space:]]*$/ { inlist=1; next }
    inlist==1 && /^      -[[:space:]]+/ {
      v=$0; sub(/^      -[[:space:]]+/,"",v); sub(/[[:space:]]+$/,"",v); print v; next
    }
    inlist==1 && /^    [a-z_]+:[[:space:]]*$/ { exit }
  ' "$1"
}

# Print the full agent blocks (in source order) whose id is in $2 (space-separated).
afb_extract_blocks() {
  awk -v want="$2" '
    BEGIN { n=split(want, a, " "); for (i=1;i<=n;i++) if (a[i]!="") W[a[i]]=1 }
    /^agents:[[:space:]]*$/ { inagents=1; next }
    !inagents { next }
    /^  - id:[[:space:]]+/ {
      id=$0; sub(/^  - id:[[:space:]]+/,"",id); sub(/[[:space:]]+$/,"",id);
      cur=(id in W)?1:0
    }
    cur { print }
  ' "$1"
}

# Merge SOURCE agents.yml into TARGET agents.yml; print merged content to stdout.
# Additive only: appends missing agent blocks and missing can_delegate_to ids.
afb_merge_agents_yaml_content() {
  local src="$1" tgt="$2"
  local work; work="$(mktemp)"

  # Start from target with trailing blank lines trimmed.
  awk '
    { lines[NR]=$0 }
    END { last=NR; while (last>0 && lines[last] ~ /^[[:space:]]*$/) last--; for (i=1;i<=last;i++) print lines[i] }
  ' "$tgt" > "$work"

  # 1) Append agent blocks present in source but missing from target.
  local src_ids tgt_ids missing="" id
  src_ids="$(afb_agent_ids "$src")"
  tgt_ids="$(afb_agent_ids "$work")"
  while IFS= read -r id; do
    [ -z "$id" ] && continue
    printf '%s\n' "$tgt_ids" | grep -qxF -- "$id" || missing="$missing $id"
  done <<EOF
$src_ids
EOF
  missing="${missing# }"
  if [ -n "$missing" ]; then
    afb_extract_blocks "$src" "$missing" >> "$work"
  fi

  # 2) Add can_delegate_to ids present in source but missing from target.
  local src_del tgt_del add_del="" d
  src_del="$(afb_can_delegate_to "$src")"
  tgt_del="$(afb_can_delegate_to "$work")"
  while IFS= read -r d; do
    [ -z "$d" ] && continue
    printf '%s\n' "$tgt_del" | grep -qxF -- "$d" || add_del="$add_del$d"$'\n'
  done <<EOF
$src_del
EOF

  if [ -z "$add_del" ]; then
    cat "$work"
    rm -f "$work"
    return 0
  fi

  if ! grep -qE '^  planning:[[:space:]]*$' "$work"; then
    rm -f "$work"
    echo "afb_merge: could not find delegation_matrix.orchestration sibling key 'planning:' to insert can_delegate_to entries." >&2
    return 3
  fi

  local ins=""
  while IFS= read -r d; do
    [ -z "$d" ] && continue
    ins="$ins      - $d"$'\n'
  done <<EOF
$add_del
EOF

  awk -v ins="$ins" '
    /^  planning:[[:space:]]*$/ && !done { printf "%s", ins; done=1 }
    { print }
  ' "$work"
  rm -f "$work"
}

# File-level merge wrapper. Args: SOURCE TARGET DRY_RUN(0|1)
afb_merge_agents_yaml_file() {
  local src="$1" tgt="$2" dry="${3:-0}"
  if [ ! -f "$src" ]; then
    echo "afb_merge: source agents.yml not found: $src" >&2
    return 2
  fi
  if [ ! -f "$tgt" ]; then
    if [ "$dry" = "1" ]; then
      echo "afb_init: [dry-run] Would create $tgt from $src"
      return 0
    fi
    mkdir -p "$(dirname "$tgt")"
    cp "$src" "$tgt"
    return 0
  fi
  local merged; merged="$(afb_merge_agents_yaml_content "$src" "$tgt")"
  if [ "$dry" = "1" ]; then
    if [ "$merged" != "$(cat "$tgt")" ]; then
      echo "afb_init: [dry-run] Would update $tgt (agents / delegation merge from $src)"
    fi
    return 0
  fi
  printf '%s\n' "$merged" > "$tgt"
}
