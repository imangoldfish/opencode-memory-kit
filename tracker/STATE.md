# opencode-memory-kit — State Tracker

Live handoff file for **this** repo — *not* the seed template (that's
`template/STATE.md`, for new projects). Read first, update last, per the
protocol in the global hook / `AGENTS.md`.

**Last updated:** 2026-10-07
**Status:** Healthy — published at https://github.com/imangoldfish/opencode-memory-kit

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
- [ ] Decide with human: tester/reviewer agents for this repo? (asked 2026-10-07,
      awaiting answer — likely shape: `tests/smoke.sh` + CI as "tester",
      checklist subagent as "reviewer".)

## Ideas backlog (not started)

- Per-track trackers (multiple STATE files in one project).
- A tiny state read/append helper (`oc-state`).
- A git hook or reminder to commit the tracker.
- Fix `scaffold.sh` if OpenCode's AGENTS.md behavior changes.
- Re-check the global hook wording vs README if OpenCode changes how
  AGENTS.md / global instructions load.

## Session log

Append-only. Newest entry at the top.

```text
Format:
#### <date> — <role / what this session was for>
What happened · decisions + why · unfinished work · concrete next step.
End with the exact command(s) that verify the claims. Keep it to a few lines.
```

#### 2026-10-07 — published to GitHub
- Pushed repo public: https://github.com/imangoldfish/opencode-memory-kit
  (`gh repo create --public`, remote `origin`, branch `master`).
- Rebase-before-write: `git fetch` clean — no new remote commits.
  Verify-before-claiming: closed the push item; stale "headed for GitHub"
  claim fixed in `AGENTS.md`; historical log entries left untouched.
- Unfinished: answer human's tester/reviewer-agent question (Next up).
- Verify: `git remote -v` shows origin · `gh repo view imangoldfish/opencode-memory-kit --json visibility` → `"PUBLIC"`.

#### 2026-10-07 — publish prep: public README + MIT (no push)
- Rewrote `README.md` for a public audience (what/why, loop, install, step-by-step
  tutorial, tracker anatomy, tips, FAQ); added MIT `LICENSE`. Old README's
  personal notes preserved in gitignored `tracker/.scratch.md`.
- Decided with human: prepare only — no remote/push yet; they push themselves later.
  Stale "personal, local-only / no GitHub" claims cleaned in `AGENTS.md` +
  README. Protocol (`template/AGENTS.section.md`) untouched, so the global
  hook stays wording-identical.
- Scaffold bug found + fixed while smoke-testing: re-running `scaffold.sh`
  used to overwrite a live `tracker/STATE.md` with the blank template (state
  loss). Now it refuses to touch an existing tracker; still idempotent for
  `AGENTS.md` / `.gitignore`.
- No remote exists → rebase-before-write's `git fetch` not applicable here.
- Unfinished: create `github.com/imangoldfish/opencode-memory-kit` + push
  (Next up); clone URL in README assumes that name.
- Verify: `grep -RniE 'local-only|No pushing|no GitHub remote' README.md AGENTS.md template/` empty ·
  scaffold smoke test in a temp dir: run twice, second run leaves `tracker/STATE.md` untouched.

#### 2026-10-07 — handoff: session moved into this repo
- Moved the working session into this repo (was in `custom MD`) so kit work
  happens here from now on; kit is self-hosting per its own AGENTS.md.
- No repo changes this session; next fresh session opens with a GitHub
  discussion planned (see Next up).
- Verify: `git status` clean · `git log --oneline -1` shows `c37def0`.

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