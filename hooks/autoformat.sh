#!/usr/bin/env bash
# claude-autoformat — PostToolUse auto-formatter dispatcher.
#
# Reads the hook JSON on stdin, finds the edited file, and runs whatever
# formatter is locally available for that file type. No-ops silently if the
# tool is not installed, so it is safe to drop into any machine / any repo.
#
#   .py            -> black, else ruff format
#   .js .ts .json
#   .css .md .yml  -> project-local prettier (resolved from the file's dir),
#                     else a global prettier on PATH
#   .go            -> gofmt
#
# Never auto-installs anything.

f="$(jq -r '.tool_response.filePath // .tool_input.file_path // empty' 2>/dev/null)"
[ -z "$f" ] || [ ! -f "$f" ] && exit 0

case "$f" in
  *.py)
    if command -v black >/dev/null 2>&1; then black -q "$f"
    elif command -v ruff  >/dev/null 2>&1; then ruff format -q "$f"
    fi ;;
  *.js|*.jsx|*.ts|*.tsx|*.json|*.css|*.scss|*.html|*.md|*.yaml|*.yml)
    # Prefer a project-local prettier (resolve from the file's own dir, walking up to its
    # node_modules); fall back to a global prettier on PATH. Never auto-installs.
    if ! ( cd "$(dirname "$f")" && npx --no-install prettier --write --ignore-unknown "$f" ) 2>/dev/null; then
      command -v prettier >/dev/null 2>&1 && prettier --write --ignore-unknown "$f"
    fi
    ;;
  *.go)
    command -v gofmt >/dev/null 2>&1 && gofmt -w "$f" ;;
esac
exit 0
