#!/usr/bin/env bash
# Smoke tests for hooks/autoformat.sh: it must never break the hook chain,
# and must leave files untouched when no formatter is available.
set -u
HOOK="$(dirname "$0")/../hooks/autoformat.sh"
fail() { echo "FAIL: $1"; exit 1; }

# 1. Empty/garbage stdin: exits 0, no crash.
echo '{}' | bash "$HOOK" || fail "empty payload should exit 0"
echo 'not-json' | bash "$HOOK" || fail "garbage payload should exit 0"

# 2. Missing file path: exits 0.
echo '{"tool_input":{"file_path":"/nonexistent/x.py"}}' | bash "$HOOK" \
  || fail "missing file should exit 0"

# 3. A .py file with NO formatter on PATH: file must be byte-identical after.
tmp=$(mktemp -d)
printf 'x=1\n' > "$tmp/sample.py"
cp "$tmp/sample.py" "$tmp/before.py"
PATH="/usr/bin:/bin" bash -c \
  "echo '{\"tool_input\":{\"file_path\":\"$tmp/sample.py\"}}' | bash '$HOOK'" \
  || fail "no-formatter case should exit 0"
cmp -s "$tmp/sample.py" "$tmp/before.py" || fail "file changed with no formatter present"

# 4. Unknown extension: untouched, exit 0.
printf 'data' > "$tmp/blob.xyz"
echo "{\"tool_input\":{\"file_path\":\"$tmp/blob.xyz\"}}" | bash "$HOOK" \
  || fail "unknown extension should exit 0"

echo "all smoke tests passed"
