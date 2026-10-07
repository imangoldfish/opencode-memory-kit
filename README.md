# opencode-memory-kit

A small, **personal, local-only** toolkit. It gives AI coding-agent sessions
(OpenCode) a *shared memory across sessions*, so a new session can pick up
where a previous one left off.

**The problem it solves:** an AI coding agent has no memory of earlier
sessions — close a session and the next one starts blank. This kit is the
fix: each project keeps a `tracker/STATE.md` handoff file, and every session
is told (via `AGENTS.md`) to *read it first* and *update it last*.

## What's inside

| File | Purpose |
| --- | --- |
| `AGENTS.section.md` | The protocol snippet — pasted into a project's `AGENTS.md` so every session follows the read-first / update-last loop |
| `tracker/STATE.md` | The handoff tracker **template** (Goal · Current state · Next up · append-only Session log) — copied into new projects |
| `scaffold.sh` | One command that drops the tracker + protocol into a new project |

## How it's installed (current machine)

- **Global hook:** `~/.config/opencode/AGENTS.md` — auto-loaded into every
  session in every workspace. It tells sessions to read/update a project's
  `tracker/STATE.md` when one exists.
- **Installed copy:** `~/.config/opencode/memory-template` is a **symlink**
  pointing at this directory. Edit files *here*; the install follows.

## How I use it

```sh
cd new-project
~/.config/opencode/memory-template/scaffold.sh   # creates tracker/ + AGENTS.md
# edit the placeholders (project name, Goal, Current state), then commit
```

From then on, any session in that project reads `tracker/STATE.md` first and
updates it at the end, automatically. Real-world example:
`~/Programming/OpenCode/custom MD/tracker/STATE.md`.

## Actions I can take later (when I come back)

- **Improve the templates** — better `AGENTS.section.md` or `tracker/STATE.md`
  go here; run `scaffold.sh` in new projects to pick them up. Existing
  projects keep their own copies (they don't auto-update).
- **Fix `scaffold.sh`** if OpenCode's AGENTS.md behavior changes.
- **Add features**, e.g.: per-track trackers (several STATE files, one per
  area), a git hook or reminder to commit the tracker, a tiny
  read/append state helper script.
- **Decide on backup** — if I ever want this off the machine, init a remote
  and push, or move it into a dotfiles repo. Currently intentionally local.
- If OpenCode changes how AGENTS.md/global instructions work, re-check that
  the global hook at `~/.config/opencode/AGENTS.md` still matches this README.

## What NOT to do

- No secrets or passwords in here.
- No pushing to GitHub unless I decide to — it's a personal tool.
- `tracker/STATE.md` in *this* repo is a **template**, not live state. The
  real state lives in each project's own `tracker/STATE.md`.

> _If you're reading this after a hiatus: you built a memory system for AI_
> _sessions. It works — the Custom MD project used it and sessions hand off_
> _cleanly. The whole thing is three small files and one symlink._