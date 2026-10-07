# opencode-memory-kit — State Tracker

Live handoff file for **this** repo — *not* the seed template (that's
`template/STATE.md`, for new projects). Read first, update last, per the
protocol in the global hook / `AGENTS.md`.

**Last updated:** 2026-10-07
**Status:** Healthy — protocol + templates current; in use by the custom MD project

## Goal

A tiny, local, reusable system giving OpenCode sessions shared memory across
sessions: a per-project `tracker/STATE.md` handoff file plus a protocol every
session follows automatically (global hook + per-project `AGENTS.md` section).

## Current state

- Protocol (6 rules: verify-before-claiming, rebase-before-write, fallback
  entries, verify-command lines, compaction to `tracker/archive/`, privacy +
  `tracker/.scratch.md`) lives in `template/AGENTS.section.md` — canonical.
  Global hook `~/.config/opencode/AGENTS.md` kept wording-identical.
- `scaffold.sh` seeds a new project with: `tracker/STATE.md` +
  `AGENTS.md` (protocol section) + `tracker/.gitignore` — all copied from
  `template/`.
- Live proof: the custom MD project has used this system since bootstrap;
  its tracker contains real working entries.
- Installed via symlink at `~/.config/opencode/memory-template` → this repo.

## Next up

- [ ] Keep watching the custom MD tracker — it is the reference
      implementation and will surface real-world problems first.

## Ideas backlog (not started)

- Per-track trackers (multiple STATE files in one project).
- A tiny state read/append helper (`oc-state`).
- A git hook or reminder to commit the tracker.

## Session log

Append-only. Newest entry at the top.

```text
Format:
#### <date> — <role / what this session was for>
What happened · decisions + why · unfinished work · concrete next step.
End with the exact command(s) that verify the claims. Keep it to a few lines.
```

#### 2026-10-07 — repo becomes its own project (template/live split)
- Restructured the kit: seed materials now live in `template/`
  (`AGENTS.section.md` + `STATE.md`); `tracker/STATE.md` is now THIS repo's
  live tracker (this file), with its own `.gitignore`.
- Rationale: starting sessions inside the kit dir would have made every
  session read the old `tracker/STATE.md` template as live state — drift.
- `scaffold.sh` now sources from `template/`; README + global hook footer
  updated to match; a project `AGENTS.md` (this file's sibling) added so
  sessions here know the layout.
- Verify: `~/.config/opencode/memory-template/scaffold.sh` smoke test in a
  temp dir · `git -C opencode-memory-kit status` clean after commit.