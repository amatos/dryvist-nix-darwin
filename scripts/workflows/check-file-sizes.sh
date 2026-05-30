#!/usr/bin/env bash
# Check file sizes — reads .file-size.yml with same defaults as shared workflow.
# Used by pre-commit hook. CI uses the shared workflow directly.
# Requires: yq (yq-go in devShell)
#
# Exit codes:
#   0 - All files within limits
#   N - Number of files exceeding their tier limit

set -euo pipefail

# Built-in defaults (must match shared workflow _file-size.yml)
WARN=8192
ERR=16384
EXT_LIMIT=0
DEFAULT_SCAN=".md .nix .tf"
EXTENDED=" "
EXEMPT=" CHANGELOG "

# Find .file-size.yml by walking up from script location or cwd
CONFIG=""
for dir in "." "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"; do
  if [[ -f "$dir/.file-size.yml" ]]; then
    CONFIG="$dir/.file-size.yml"
    break
  fi
done

# Override from .file-size.yml if present
if [[ -n "$CONFIG" ]]; then
  WARN=$(yq ".defaults.warn // $WARN" "$CONFIG")
  ERR=$(yq ".defaults.error // $ERR" "$CONFIG")
  EXT_LIMIT=$(yq '.extended.limit // 0' "$CONFIG")

  # scan: replaces defaults if specified
  # tr -d '"' for compatibility with both kislyuk/yq and mikefarah/yq
  cfg_scan=$(yq '.scan // [] | .[]' "$CONFIG" | tr -d '"' | tr '\n' ' ')
  [ -n "$cfg_scan" ] && DEFAULT_SCAN="$cfg_scan"

  # extended.files: additive to defaults
  cfg_ext=$(yq '.extended.files // [] | .[]' "$CONFIG" | tr -d '"' | tr '\n' ' ')
  [ -n "$cfg_ext" ] && EXTENDED="$EXTENDED$cfg_ext "

  # exempt: additive to defaults (CHANGELOG always exempt)
  cfg_exempt=$(yq '.exempt // [] | .[]' "$CONFIG" | tr -d '"' | tr '\n' ' ')
  [ -n "$cfg_exempt" ] && EXEMPT="$EXEMPT$cfg_exempt "
fi

# Build find name arguments from scan extensions
name_args=(); first=true
for ext in $DEFAULT_SCAN; do
  $first && first=false || name_args+=(-o)
  name_args+=(-name "*${ext}")
done

ERRORS=0

while IFS= read -r -d '' f; do
  base=$(basename "$f" | sed 's/\.[^.]*$//')
  size=$(wc -c < "$f" | tr -d ' ')
  kb=$((size / 1024))

  # Skip exempt files
  if [[ "$EXEMPT" == *" $base "* ]]; then continue; fi

  # Determine limit: extended or standard
  if [[ "$EXT_LIMIT" -gt 0 ]] && [[ "$EXTENDED" == *" $base "* ]]; then
    limit=$EXT_LIMIT
    warn_threshold=$limit
  else
    limit=$ERR
    warn_threshold=$WARN
  fi

  # Report errors and warnings
  if [ "$size" -gt "$limit" ]; then
    echo "::error file=$f::$f is ${kb}KB (exceeds $((limit/1024))KB limit)"
    ERRORS=$((ERRORS + 1))
  elif [ "$size" -gt "$warn_threshold" ]; then
    echo "::warning file=$f::$f is ${kb}KB (exceeds $((warn_threshold/1024))KB recommended)"
  fi
# Note: -type f restricts to regular files and excludes symlinks intentionally.
done < <(find . -path './.git' -prune -o \( "${name_args[@]}" \) -type f -print0 | sort -z)

exit $ERRORS
