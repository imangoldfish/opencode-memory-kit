# opencode-memory-kit — State Tracker

Live handoff file for **this** repo — *not* the seed template (that's
`template/STATE.md`, for new projects). Read first, update last, per the
protocol in the global hook / `AGENTS.md`.

**Last updated:** 2026-10-07
**Status:** Healthy — published; four-subagent crew (reviewer/tester/docs/scrutiny) + 57-check CI suite

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
- Four subagents in `.opencode/agents/`: `reviewer` (read-only protocol
  audit), `tester` (edits `tests/` only), `docs` (edits docs only),
  `scrutiny` (read-only line-by-line shell review).
- `scaffold.sh` hardened after scrutiny+tester findings: validates templates
  before writing, anchored `^##` protocol grep, refuses directory-shaped
  targets, warns on wrong `.gitignore`. Suite: 57 checks, CI on every push.

## Next up

- [ ] Keep watching the custom MD tracker — it is the reference
      implementation and will surface real-world problems first.

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

#### 2026-10-07 — tester + docs + scrutiny agents; scaffold hardened from findings
- Human asked for a tester, a docs agent, and a line-by-line shell reviewer →
  built `.opencode/agents/{tester,docs,scrutiny}.md` (edit scope: `tests/` /
  docs-only / none) alongside the existing `reviewer`. README table + Tips,
  AGENTS.md Layout/rules document the four-agent crew (docs agent fixed its
  own two finds: README example now verbatim from the log; AGENTS.md dropped
  a colliding "the tester" label).
- Dogfooded all three: `scrutiny` + `tester` independently found the same 3
  scaffold bugs — unanchored protocol grep (a prose mention blocked install),
  no template validation before mutating AGENTS.md (partial-apply), and
  directory-shaped `STATE.md`/`AGENTS.md` cp-into-dir lie-success. Fixed all
  three + minors (`.gitignore` silent skip, 2 test-quality issues). `tester`
  grew the suite 12 → 48 checks; regression guards added → **57 checks**.
- Verify: `bash tests/smoke.sh` → ALL TESTS PASSED (57) · `gh run list` after
  push → `tests` run for this commit `completed success`.

#### 2026-10-07 — AI disclosure section added to README
- Human asked for an AI-made note like `custom MD`'s README; added an
  "AI disclosure" section after the intro (same wording style: primary agent
  wrote it, reviewer subagent audited, human directed/reviewed) plus the
  meta-note that the repo self-hosts its tracker.
- Verify: `grep -c 'AI disclosure' README.md` → 1 · `gh run list` → latest
  `tests` run for the disclosure commit `completed success`.

#### 2026-10-07 — tester + reviewer built (human picked both)
- Decided with human: **tester = `tests/smoke.sh` + GitHub Actions**
  (deterministic, free, runs every push) rather than an agent; **reviewer =
  read-only subagent** `.opencode/agents/reviewer.md` with a protocol
  checklist (runs verify commands, log format, stale refs, secrets). Ordered
  broad-before-exceptions per V2 docs so specific `shell` allows win over the
  default `ask`.
- Also: README badge + table rows + Tips bullets; AGENTS.md Layout/rules
  updated; `scaffold.sh` untouched this round but now covered by 12 smoke
  checks (first run, clobber-protection, idempotency, hook wording sync — 11
  in CI where the hook is absent; count corrected from "13" after reviewer
  catch).
- Reviewer subagent dogfooded on `eeda65f..56ec973`: no blockers/majors; 2
  minors (wrong "13 tests" claim; stale README "three small files" line) —
  both fixed in `56ec973`. Nit: same-round entry correction noted inline
  rather than appended.
- Verify: `bash tests/smoke.sh` → ALL TESTS PASSED (12/12) ·
  `gh run list --repo imangoldfish/opencode-memory-kit` → runs 37608366055
  and 37610080945 both `completed success`.

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