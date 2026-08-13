#!/bin/bash
# oncestory.sh — portmanteau: once + history
# unique colored commands from my shell history
#
#   bash oncestory.sh
#   bash oncestory.sh -h

usage() {
  cat <<'EOF'
oncestory.sh — unique, colored shell history

  oncestory = once + history  (portmanteau)

Usage:
  bash oncestory.sh [-h|--help] [pattern]

What it does:
  - reads HISTFILE (or ~/.bash_history / ~/.zsh_history)
  - each distinct command once (oldest -> newest)
  - line = preview   times   full_command
      preview = first20...last20  (or whole cmd if length < 43)
  - color by first word (the program)
  - prints progress while loading big history files

Examples:
  bash oncestory.sh
  bash oncestory.sh git
  ONCESTORY_LIMIT=100 bash oncestory.sh

Env:
  HISTFILE            history file
  ONCESTORY_LIMIT     max unique lines to print (0 = all)

EOF
}

for a in "$@"; do
  case "$a" in
    -h|--help) usage; exit 0 ;;
  esac
done

# optional substring filter
pat=""
for a in "$@"; do
  case "$a" in
    -*) ;;
    *) pat="$a"; break ;;
  esac
done

hist="${HISTFILE:-$HOME/.bash_history}"
if [[ ! -f "$hist" ]]; then
  if [[ -f "$HOME/.zsh_history" ]]; then
    hist="$HOME/.zsh_history"
  else
    echo "oncestory: no history file (HISTFILE / ~/.bash_history)" >&2
    exit 1
  fi
fi

limit="${ONCESTORY_LIMIT:-0}"

echo "oncestory: reading $hist ..." >&2
[[ -n "$pat" ]] && echo "oncestory: filter \"$pat\"" >&2
[[ "$limit" != "0" ]] && echo "oncestory: limit $limit" >&2

# load history -> count -> unique (keep most recent) -> print oldest..newest
awk -v pat="$pat" -v lim="$limit" -v histfile="$hist" \
  -v R=$'\033[0m' -v B=$'\033[1m' '

function preview(s, L) {
  L = length(s)
  if (L < 43) return s
  return substr(s, 1, 20) "..." substr(s, L - 19, 20)
}

BEGIN {
  # same palette vibe as sqolor
  nc = split("39 208 48 213 220 51 141 203 120 75 198 82 99 214 45 171 118 33 205 190 69 162 86 135", pal, " ")
  ci = 1
  step = 5000
}

{
  line = $0
  if (line ~ /^#[0-9]+$/) next                    # bash timestamps
  if (line ~ /^:[0-9]+:[0-9]+;/)                   # zsh extended
    sub(/^:[0-9]+:[0-9]+;/, "", line)
  gsub(/\r$/, "", line)
  sub(/^[[:space:]]+/, "", line)                  # no leading spaces
  if (line == "") next

  n++
  raw[n] = line
  if (n % step == 0)
    printf "oncestory: loaded %d lines...\n", n > "/dev/stderr"
}

END {
  printf "oncestory: loaded %d, counting + unique...\n", n > "/dev/stderr"

  for (i = 1; i <= n; i++) cnt[raw[i]]++

  # newest -> oldest so first time we keep = most recent run
  for (i = n; i >= 1; i--) {
    cmd = raw[i]
    if (pat != "" && index(cmd, pat) == 0) continue
    if (cmd in seen) continue
    seen[cmd] = 1

    split(cmd, a, /[[:space:]]+/)
    key = a[1]
    if (!(key in col)) {
      col[key] = sprintf("\033[38;5;%sm", pal[ci])
      ci = ci % nc + 1
    }

    out[++m] = sprintf("%s%-43s  %5d  %s%s", col[key], preview(cmd), cnt[cmd], cmd, R)

    if (m % step == 0)
      printf "oncestory: %d unique (%d/%d scanned)...\n", m, n - i + 1, n > "/dev/stderr"
  }

  max = m
  if (lim + 0 > 0 && m > lim + 0) max = lim + 0
  printf "oncestory: printing %d (newest last)...\n", max > "/dev/stderr"

  printf "%s%-43s  %5s  %s%s\n", B, "preview", "times", "command", R
  for (i = max; i >= 1; i--) print out[i]

  printf "%s--- %d unique (from %s) ---%s\n", B, max + 0, histfile, R > "/dev/stderr"
}
' "$hist"

echo ""
echo "(run: bash oncestory.sh -h  for help)"
