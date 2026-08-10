#!/usr/bin/env bash
# Assert no AI attribution anywhere in the tracked tree.
set -uo pipefail
cd "$(dirname "$0")/../.."

hits=$(git ls-files -z \
       | grep -zvE '^(AGENTS\.md|\.github/workflows/checks\.yml|runtime/local/check_attribution\.sh)$' \
       | xargs -0 grep -lniE 'co-authored-by:.*claude|generated with .*claude|🤖' 2>/dev/null || true)

if [ -n "$hits" ]; then
  echo "AI attribution found in:" >&2
  printf '  %s\n' $hits >&2
  exit 1
fi
echo "no AI attribution in $(git ls-files | wc -l) tracked files"
