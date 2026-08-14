#!/bin/bash
# Oncestory.sh — unique colored commands from shell history (once + history)
#
#   . /pl/active/KellerLab/Emmanuel/gameticphasing/alltriooffspring/Oncestory.sh
#
# Do not `set -o history` here: that records every line of THIS file into history.

# Stop recording immediately so this script is not added to history.
set +o history 2>/dev/null || true

_oncestory_sourced=0
if [[ -n "${BASH_SOURCE[0]:-}" && "${BASH_SOURCE[0]}" != "${0:-}" ]]; then
  _oncestory_sourced=1
fi

_oncestory_die() {
  echo "Oncestory: $*" >&2
  if [[ "$_oncestory_sourced" -eq 1 ]]; then
    return 1
  fi
  exit 1
}

_ONCESTORY_SELF="${BASH_SOURCE[0]:-$0}"

usage() {
  cat <<EOF
Oncestory.sh — unique colored shell history

  . ${_ONCESTORY_SELF}

Not: bash Oncestory.sh
EOF
}

for a in "$@"; do
  case "$a" in
    -h|--help)
      usage
      if [[ "$_oncestory_sourced" -eq 1 ]]; then set -o history 2>/dev/null || true; return 0; fi
      exit 0
      ;;
  esac
done

pat=""
for a in "$@"; do
  case "$a" in
    -*) ;;
    *) pat="$a"; break ;;
  esac
done

if [[ "$_oncestory_sourced" -ne 1 ]]; then
  echo "Oncestory: that was bash/sh (new process). history 1001+ is only in your login shell." >&2
  echo "Oncestory: type this, including the dot and the space:" >&2
  echo "" >&2
  echo "  . ${_ONCESTORY_SELF}" >&2
  echo "" >&2
  exit 2
fi

if [[ -z "${HISTSIZE:-}" ]] || [[ "${HISTSIZE:-0}" -lt 100000 ]]; then
  HISTSIZE=100000
fi
if [[ -z "${HISTFILESIZE:-}" ]] || [[ "${HISTFILESIZE:-0}" -lt 100000 ]]; then
  HISTFILESIZE=100000
fi
shopt -s histappend 2>/dev/null || true
builtin history -a 2>/dev/null || true

limit="${ONCESTORY_LIMIT:-0}"

_oncestory_tmp=$(mktemp "${TMPDIR:-/tmp}/oncestory.XXXXXX") || {
  _oncestory_die "mktemp failed"
  set -o history 2>/dev/null || true
  return 1
}
_oncestory_cleanup() {
  rm -f "$_oncestory_tmp" "${_oncestory_tmp}.raw"
}

# Never pipe `history` (subshell reloads HISTFILE with HISTSIZE=1000).
HISTTIMEFORMAT= builtin history > "${_oncestory_tmp}.raw" 2>/dev/null || true
if [[ ! -s "${_oncestory_tmp}.raw" ]]; then
  fc -ln 1 1000000 > "${_oncestory_tmp}.raw" 2>/dev/null || true
fi
_n=$(wc -l < "${_oncestory_tmp}.raw" | tr -d ' ')
_last=$(tail -n 1 "${_oncestory_tmp}.raw" | awk '{print $1}')
echo "Oncestory: sourced=yes  lines=${_n}  last_event=${_last:-?}  HISTSIZE=${HISTSIZE:-unset}" >&2
sed 's/\r$//; s/^[[:space:]]*[0-9][0-9]*[[:space:]][[:space:]]*//' "${_oncestory_tmp}.raw" > "$_oncestory_tmp"
rm -f "${_oncestory_tmp}.raw"

echo "Oncestory: reading live history ..." >&2
[[ -n "$pat" ]] && echo "Oncestory: filter \"$pat\"" >&2

{
  cat "$_oncestory_tmp"
  printf '\n'
} | awk -v pat="$pat" -v lim="$limit" \
  -v R=$'\033[0m' -v B=$'\033[1m' '

function preview(s, L) {
  L = length(s)
  if (L < 43) return s
  return substr(s, 1, 20) "..." substr(s, L - 19, 20)
}
function skip_self(s, t) {
  if (s ~ /(^|[[:space:]])(\.|source|bash)[[:space:]]+[^;&|]*Oncestory\.sh/) return 0
  if (s ~ /^[Oo]ncestory([ \t].*)?$/) return 0
  t = tolower(s)
  if (index(t, "_oncestory")) return 1
  if (index(t, "oncestory:")) return 1
  if (s ~ /^echo "/ && index(t, "oncestory")) return 1
  if (s ~ /^printf "/ && index(t, "oncestory")) return 1
  if (index(s, "$pat")) return 1
  if (index(s, "HISTTIMEFORMAT")) return 1
  if (index(s, "builtin history")) return 1
  if (index(s, "histappend")) return 1
  if (index(s, "HISTFILESIZE")) return 1
  if (index(s, "Never pipe")) return 1
  if (s ~ /^hist=/) return 1
  if (s ~ /^limit=/) return 1
  if (s ~ /^set [-+]o history/) return 1
  if (s ~ /^return 0$/) return 1
  if (s ~ /^[{}]$/) return 1
  if (s == sprintf("%c", 39)) return 1
  if (s ~ /^function preview\(/) return 1
  if (s ~ /^L = length\(s\)$/) return 1
  if (s ~ /^if \(L < 43\)/) return 1
  if (s ~ /^return substr\(s,/) return 1
  if (s ~ /^BEGIN \{/) return 1
  if (s ~ /^END \{/) return 1
  if (s ~ /^nc = split\(/) return 1
  if (s ~ /^raw\[n\]/) return 1
  if (s ~ /^seen\[cmd\]/) return 1
  if (s ~ /^col\[key\]/) return 1
  if (s ~ /^out\[\+\+m\]/) return 1
  if (s ~ /^preview\(cmd\)/) return 1
  if (s ~ /^pal\[ci\]/) return 1
  if (s ~ /^cmd = raw\[i\]/) return 1
  if (s ~ /^line = \$0$/) return 1
  if (s ~ /^if \(line == ""\) next$/) return 1
  if (s ~ /^if \(line ~/) return 1
  if (s ~ /^sub\(\/\^/) return 1
  if (s ~ /^gsub\(\/\\r/) return 1
  if (s ~ /^if \(cmd in seen\)/) return 1
  if (s ~ /^split\(cmd, a/) return 1
  if (s ~ /^key = a\[1\]/) return 1
  if (s ~ /^if \(!\(key in col\)/) return 1
  if (s ~ /^ci = ci % nc/) return 1
  if (s ~ /^n\+\+$/) return 1
  if (s ~ /^[nmc]i? = 0$/) return 1
  if (s ~ /^ci = 1$/) return 1
  if (s ~ /^max = m$/) return 1
  if (s ~ /^for \(i = /) return 1
  if (s ~ /^printf "%s%-43s/) return 1
  if (s ~ /^if \(pat != ""/) return 1
  if (s ~ /^if \(lim \+ 0/) return 1
  if (s ~ /^if \(s ~ \/\^/) return 1
  if (s ~ /^if \(index\(s,/) return 1
  if (s ~ /^HISTSIZE=100000/) return 1
  if (s ~ /HISTSIZE:-0/) return 1
  if (index(s, "Oncestory") && s !~ /Oncestory\.sh/) return 1
  return 0
}
BEGIN {
  nc = split("39 208 48 213 220 51 141 203 120 75 198 82 99 214 45 171 118 33 205 190 69 162 86 135", pal, " ")
  ci = 1
  n = 0
  m = 0
}
{
  line = $0
  if (line ~ /^#[0-9]+$/) next
  if (line ~ /^:[0-9]+:[0-9]+;/)
    sub(/^:[0-9]+:[0-9]+;/, "", line)
  gsub(/\r$/, "", line)
  sub(/^[[:space:]]+/, "", line)
  if (line == "") next
  if (skip_self(line)) next
  n++
  raw[n] = line
}
END {
  printf "Oncestory: loaded %d, counting + unique...\n", n > "/dev/stderr"
  for (i = 1; i <= n; i++) cnt[raw[i]]++
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
  }
  max = m
  if (lim + 0 > 0 && m > lim + 0) max = lim + 0
  printf "Oncestory: printing %d (newest last)...\n", max > "/dev/stderr"
  printf "%s%-43s  %5s  %s%s\n", B, "preview", "times", "command", R
  for (i = max; i >= 1; i--) print out[i]
  printf "%s--- %d unique (live history, %d input lines) ---%s\n", B, max + 0, n, R > "/dev/stderr"
}
'

_oncestory_cleanup

Oncestory() {
  builtin history -a 2>/dev/null || true
  . "$_ONCESTORY_SELF" "$@"
}
echo "Oncestory: next time type:  Oncestory" >&2
set -o history 2>/dev/null || true
return 0
