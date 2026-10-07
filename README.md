# opencode-memory-kit

[![tests](https://github.com/imangoldfish/opencode-memory-kit/actions/workflows/test.yml/badge.svg)](https://github.com/imangoldfish/opencode-memory-kit/actions/workflows/test.yml)

Give AI coding sessions a **shared memory across sessions** — a tiny handoff
tracker plus a protocol every session follows automatically.

**The problem:** an AI coding agent has no memory of earlier sessions. Close
one, and the next starts blank — re-explaining the project, forgetting
decisions, repeating mistakes.

**The fix:** each project keeps one file, `tracker/STATE.md`, and every
session is instructed (via `AGENTS.md`) to *read it first* and *update it
last*. Sessions hand off cleanly; the project's state survives.

No database, no server, no dependencies — three small files and a clone.

## What's inside

| File | Purpose |
| --- | --- |
| `template/AGENTS.section.md` | The protocol snippet (**canonical**) — lives in a project's `AGENTS.md` so every session follows the read-first / update-last loop |
| `template/STATE.md` | The handoff tracker **seed template** (Goal · Current state · Next up · append-only Session log) — copied into new projects by `scaffold.sh` |
| `scaffold.sh` | One command that drops the tracker + protocol into a new project |
| `tracker/STATE.md` | **This repo's own live tracker** — real state, not a template. The kit is its own first project |
| `tests/smoke.sh` | Smoke tests for the scaffolder (first run, rerun never clobbers state, hook sync) — run with `bash tests/smoke.sh` |
| `.github/workflows/test.yml` | CI — runs the smoke tests on every push and pull request |
| `.opencode/agents/reviewer.md` | A read-only **reviewer subagent** that checks changes against the tracker protocol |

## How it works

Every session runs the same loop:

1. **Read first** — before touching anything, the session reads
   `tracker/STATE.md`: the goal, current state, what's next, and the recent
   session log. It picks up unfinished work instead of starting cold.
2. **Work** — the session does its job.
3. **Update last** — it appends a short Session-log entry (what changed,
   decisions + why, the exact commands that verify it), refreshes **Status**
   and **Next up**, and commits the tracker together with the code.

A few rules keep the log trustworthy:

- The log is **append-only**, newest entry at the top — never rewritten.
- **Verify before claiming done** — entries are claims, not facts; close-outs
  grep the docs for stale references.
- **Rebase before writing** — `git fetch`, re-read, and place your entry above
  anything another session added meanwhile.
- **Archive, never delete** — past ~40–50 entries the oldest move to
  `tracker/archive/STATE-YYYY.md`.
- **Privacy** — entries stay de-personalized; sensitive scratch goes in
  `tracker/.scratch.md`, which is gitignored.

The full canonical text lives in
[`template/AGENTS.section.md`](template/AGENTS.section.md).

## Install

Clone the kit to the path `scaffold.sh` expects:

```sh
git clone https://github.com/imangoldfish/opencode-memory-kit.git ~/.config/opencode/memory-template
```

That's it — the scaffolder finds the kit at that path (override with the
`KIT` environment variable if you clone elsewhere).

### Optional: the global hook

For the protocol to load into **every** session in **every** workspace
automatically, append it once to your OpenCode global instructions:

```sh
grep -q "Cross-session tracker protocol" ~/.config/opencode/AGENTS.md 2>/dev/null \
  || cat ~/.config/opencode/memory-template/template/AGENTS.section.md >> ~/.config/opencode/AGENTS.md
```

Without the hook things still work: `scaffold.sh` puts the protocol into each
project's own `AGENTS.md`, which sessions in that project read anyway — and
because it's committed, collaborators get it on clone. The hook just means
never depending on that file being present.

## How to give a project memory (tutorial)

**1. Scaffold** — run the scaffolder from your project root:

```sh
cd path/to/your-project
~/.config/opencode/memory-template/scaffold.sh
```

It creates:

```
tracker/STATE.md        # the handoff tracker (seeded from the template)
tracker/.gitignore      # keeps .scratch.md (your private scratch) out of git
AGENTS.md               # created or appended with the tracker protocol
```

**2. Fill in the placeholders** — open `tracker/STATE.md` and replace the
`<...>` placeholders: project name, date, one-line **Goal**, and a short
**Current state** (what exists, how to run it).

**3. Commit:**

```sh
git add AGENTS.md tracker/
git commit -m "Add cross-session tracker"
```

**4. Just work.** Open your next OpenCode session in the project. It reads
`tracker/STATE.md` before doing anything, continues whatever **Next up**
lists, and appends an entry to the Session log when it finishes. Your only
job is reviewing the diff before committing — the handoff is automatic.

A real entry looks like this (from this repo's own tracker):

```text
#### 2026-10-07 — repo becomes its own project (template/live split)
- Restructured the kit: seed materials now live in `template/`.
- Rationale: starting sessions inside the kit dir would have made every
  session read the old template as live state — drift.
- Verify: `scaffold.sh` smoke test in a temp dir · `git status` clean after commit.
```

Short, concrete, and it ends with the command that proves the claim.

## Tracker anatomy

`tracker/STATE.md` has five sections:

| Section | What goes there |
| --- | --- |
| **Status / Last updated** | One line: healthy, blocked, released — and when |
| **Goal** | One line — what the project is trying to be |
| **Current state** | What exists now + how to run/test it |
| **Next up** | Checkboxes — the actual next actionable steps |
| **Session log** | Append-only history, newest at the top |

`Ideas backlog` catches things that aren't started yet, so they don't get
lost.

## Tips

- **Test before you push** — `bash tests/smoke.sh` checks the scaffolder
  end-to-end (fresh run, rerun never overwrites live state, protocol/template
  sync). CI runs the same script on every push.
- **Review before you commit** — in an OpenCode session in this repo, ask:
  *"Use the reviewer subagent to review my current changes."* It runs each
  entry's verify commands, checks log format, stale docs, and secrets —
  read-only, it reports instead of fixing.
- **Upgrade an existing project** — copy
  [`template/AGENTS.section.md`](template/AGENTS.section.md) into its
  `AGENTS.md` and refresh its Session-log Format block; never rewrite its
  existing entries.
- **Improve the kit** — edit files under `template/`; new projects pick the
  changes up on the next scaffold. Existing projects keep their own copies
  (they don't auto-update).
- **It works with other agents** — the protocol is plain Markdown
  instructions. Paste it into `CLAUDE.md`, Cursor rules, or any agent's
  system-instructions file and the same loop applies.
- **This repo is its own proof** — [`tracker/STATE.md`](tracker/STATE.md) is
  this project's live state, maintained by sessions following the protocol
  you're reading about.

## FAQ

**Do I need the global hook?** No. The per-project `AGENTS.md` section does
the job inside each project; the hook just covers every workspace too.

**What about parallel sessions?** The *rebase before you write* rule handles
it: fetch, re-read the tracker, and place your entry above anything another
session added, committing atomically.

**Where do secrets and venting go?** `tracker/.scratch.md` — it's gitignored
via `tracker/.gitignore`. Committed entries stay de-personalized.

**Can two projects share one tracker?** Not by design — one project, one
tracker, so handoff state stays with the code it describes.

## License

[MIT](LICENSE)
