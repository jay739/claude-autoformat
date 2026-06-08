#!/usr/bin/env bash
# claude-autoformat uninstaller. Removes the hook entry from settings.json
# and deletes the hook script. Idempotent.
set -euo pipefail

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SETTINGS="$CLAUDE_DIR/settings.json"
HOOK_DST="$CLAUDE_DIR/hooks/autoformat.sh"

if [ -f "$SETTINGS" ]; then
python3 - "$SETTINGS" <<'PY'
import json, sys
settings = sys.argv[1]
try:
    with open(settings) as f:
        cfg = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    sys.exit(0)

arr = cfg.get("hooks", {}).get("PostToolUse", [])
def is_ours(group):
    return any("autoformat.sh" in h.get("command", "") for h in group.get("hooks", []))
arr[:] = [g for g in arr if not is_ours(g)]
if not arr:
    cfg.get("hooks", {}).pop("PostToolUse", None)

with open(settings, "w") as f:
    json.dump(cfg, f, indent=2)
    f.write("\n")
print(f"Removed auto-format hook from {settings}")
PY
fi

rm -f "$HOOK_DST"
echo "Uninstalled. Open /hooks (or restart) to reload."
