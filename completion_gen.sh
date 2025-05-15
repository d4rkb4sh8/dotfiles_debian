#!/usr/bin/env bash
set -eo pipefail

generate_completions() {
  local command=$1
  local help_text man_text

  # Parse help output
  help_text=$({ $command --help || $command -h; } 2>&1 | tr -d '\r') || true

  # Parse man page
  man_text=$(man -P cat "$command" 2>/dev/null | col -bx | grep -E '^[ ]*-' || true)

  declare -A opts
  parse_content() {
    while read -r line; do
      # Split into option and description
      IFS=$'\t' read -r opt desc <<<"$(echo "$line" | sed -E 's/(  +|\t)/\t/')"

      # Clean up option part
      opt=$(echo "$opt" | tr -d ',[:space:]')
      [[ "$opt" ]] || continue

      # Split combined options (-a, --all)
      IFS=' ' read -ra split_opts <<<"$opt"
      for o in "${split_opts[@]}"; do
        [[ "$o" =~ ^- ]] || continue
        # Use existing description if available
        opts["$o"]=${desc:-${opts["$o"]:-No description available}}
      done
    done <<<"$(echo "$1" | grep -E '^[ ]*-')"
  }

  parse_content "$help_text"
  parse_content "$man_text"

  # Generate completion function
  cat <<EOF
_${command}_completions() {
    local cur=\${COMP_WORDS[COMP_CWORD]}
    declare -A opts=(
$(
    for opt in "${!opts[@]}"; do
      printf "        [%q]=%q\n" "$opt" "${opts[$opt]}"
    done
  )
    )
    COMPREPLY=()
    keys="\${!opts[@]}"
    for k in \$keys; do [[ \$k == \$cur* ]] && COMPREPLY+=("\$k"); done
    
    if [[ \${#COMPREPLY[@]} -ne 0 ]]; then
        printf "\n"
        for i in \${!COMPREPLY[@]}; do
            printf "%-30s %s\n" "\${COMPREPLY[i]}" "\${opts[\${COMPREPLY[i]}]}"
        done | column -t >&2
    fi
}
complete -F _${command}_completions $command
EOF
}

# Main execution
if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <command>"
  exit 1
fi

generate_completions "$1"
