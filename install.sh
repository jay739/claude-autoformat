#!/usr/bin/env bash
# claude-autoformat installer.
# Copies the hook into ~/.claude/hooks/ and merges the hook config into
# ~/.claude/settings.json (preserving everything already there).
# Idempotent: safe to re-run. Requires python3 for the JSON merge.
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
HOOK_SRC="$SRC_DIR/hooks/autoformat.sh"
HOOK_DST="$CLAUDE_DIR/hooks/autoformat.sh"
SETTINGS="$CLAUDE_DIR/settings.json"

mkdir -p "$CLAUDE_DIR/hooks"
cp "$HOOK_SRC" "$HOOK_DST"
chmod +x "$HOOK_DST"

python3 - "$SETTINGS" <<'PY'
import json, os, sys

settings = sys.argv[1]
try:
    with open(settings) as f:
        cfg = json.load(f)
except FileNotFoundError:
    cfg = {}
except json.JSONDecodeError:
    print(f"ERROR: {settings} is not valid JSON; fix it and re-run.", file=sys.stderr)
    sys.exit(1)

cmd = "bash ~/.claude/hooks/autoformat.sh 2>/dev/null || true"
hooks = cfg.setdefault("hooks", {})
arr = hooks.setdefault("PostToolUse", [])

# Drop any prior install of this exact hook so re-running doesn't duplicate it.
def is_ours(group):
    return any("autoformat.sh" in h.get("command", "") for h in group.get("hooks", []))
arr[:] = [g for g in arr if not is_ours(g)]

arr.append({
    "matcher": "Write|Edit",
    "hooks": [{"type": "command", "command": cmd, "statusMessage": "Auto-formatting..."}],
})

with open(settings, "w") as f:
    json.dump(cfg, f, indent=2)
    f.write("\n")
print(f"Merged PostToolUse(Write|Edit) auto-format hook into {settings}")
PY

echo
echo "Installed. Auto-format runs after Claude edits a file, using whatever formatter is present:"
echo "  Python -> black (pipx install black) or ruff"
echo "  JS/TS/JSON/CSS/MD/YAML -> prettier (npm i -g prettier, or project-local)"
echo "  Go -> gofmt"
echo "No formatter installed = the hook silently no-ops; nothing breaks."
echo
echo "Open /hooks in Claude Code once (or restart) to load the new config."
echo "To remove: ./uninstall.sh"
