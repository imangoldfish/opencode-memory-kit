# AGENTS.md — opencode-memory-kit

This repo **is** the cross-session memory kit — a small tool that gives
OpenCode projects shared memory across sessions via a handoff tracker. It's
now its own project, so sessions work on it directly.

## Layout

- `AGENTS.md` — this file; guidance for sessions working in this repo.
- `template/` — the **seed materials** scaffolded into new projects:
  - `AGENTS.section.md` — canonical protocol text. Editing this is how the
    protocol itself improves (the global hook is kept identical in wording).
  - `STATE.md` — the seed tracker (placeholders for a brand-new project).
- `tracker/STATE.md` — **this repo's live handoff state. Not a template.**
- `scaffold.sh` — copies `template/` into a new project.
- `README.md` — welcome-back doc + the full story.

## Rules for sessions here

- The cross-session tracker protocol applies here too (global hook): read
  `tracker/STATE.md` first, update it last, append-only log, end entries with
  verify commands.
- Improve the **template** (`template/…`), and be clear in tracker entries
  whether a change was "template" or "this repo's own state".
- Existing projects keep their own copies of the protocol; they pick up
  template changes only via `scaffold.sh` / copying — never by you editing
  their files other than their live tracker.
- This repo is headed for GitHub — treat every committed file as public: no
  secrets, no personal commentary or private paths in committed entries
  (those go in the gitignored `tracker/.scratch.md`).
- Commit changes normally, tracker together with the change.