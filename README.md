# claude-autoformat

**Auto-format files the moment [Claude Code](https://github.com/anthropics/claude-code) edits them — with whatever formatter your project already uses.**

A single `PostToolUse` hook that runs after every `Write`/`Edit`. It looks at the edited file's extension and dispatches to the matching formatter. If that formatter isn't installed, it silently does nothing — so it's safe to drop onto any machine and into any repo.

## Why

Without this, you either format by hand or approve a formatter command on every edit. This eliminates that loop: the file is formatted on the way out, no prompt, no diff noise from inconsistent style.

## What it formats

| File types                                                | Formatter (first one found)                      |
| --------------------------------------------------------- | ------------------------------------------------ |
| `.py`                                                     | `black`, else `ruff format`                      |
| `.js .jsx .ts .tsx .json .css .scss .html .md .yaml .yml` | project-local `prettier`, else global `prettier` |
| `.go`                                                     | `gofmt`                                          |

It **never auto-installs** anything. No formatter present = no-op.

## Install

```bash
git clone https://github.com/jay739/claude-autoformat
cd claude-autoformat
./install.sh
```

The installer copies `hooks/autoformat.sh` into `~/.claude/hooks/` and **merges** a hook entry into `~/.claude/settings.json` (your existing settings and hooks are preserved). It's idempotent — re-running replaces the entry instead of duplicating it.

Then open `/hooks` in Claude Code once (or restart) so the new config loads.

## Installing the formatters

The hook only runs a formatter that's on your PATH:

```bash
pipx install black        # Python (avoids PEP 668 "externally-managed" errors)
npm install -g prettier   # JS/TS/JSON/CSS/MD/YAML
# gofmt ships with Go
```

A project-local prettier (`node_modules/.bin/prettier`) is preferred over the global one, so per-repo prettier configs are respected.

## How it works

- Reads the hook JSON on stdin and pulls the file path with `jq`.
- Dispatches by extension. The prettier branch `cd`s into the **edited file's own directory** first, so `npx --no-install` can walk up to that project's `node_modules` (hooks run with the working directory set to your Claude session, not the project).
- Everything is guarded so a missing tool, an unknown file type, or a parse error just exits cleanly.

## Uninstall

```bash
./uninstall.sh
```

Removes the hook entry from `settings.json` and deletes the script.

## Requirements

- `jq` (for reading the hook payload)
- `python3` (used by the installer for a safe JSON merge)

## License

MIT
