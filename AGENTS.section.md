## Cross-session tracker protocol

Models do not share memory between sessions. `tracker/STATE.md` is the single
source of handoff truth — how a new session picks up where the last one left
off.

- **At the start** of a session: read `tracker/STATE.md` before doing anything
  else. If it lists unfinished work, continue it (or say what you are doing
  instead).
- **At the end**: update it — add one short entry to the Session log (what you
  changed, decisions + why, what is unfinished) and refresh **Status** and
  **Next up**.
- **Verify before claiming done**: when you close a "Next up" item, quickly
  grep the docs (`README.md`, `PLAN.md`, …) for adjacent stale references
  (old stack names, outdated claims) and fix or flag them in your entry.
  Entries are claims, not facts.
- **Rebase before you write**: right before updating the tracker, if the repo
  has a remote run `git fetch`, then re-read `tracker/STATE.md` and place your
  entry above anything another session added in the meantime; commit the
  whole change (+ push if a remote exists) atomically.
- **Never skip the ritual**: if a session changed nothing, add a one-line
  "no code changes this session" entry anyway.
- Keep entries short and concrete: file paths, commands, exact next steps, and
  the reason behind decisions. No essays. End each entry with the exact
  command(s) that verify its claims.
- The log is append-only; **newest entry at the top**. Do not delete or rewrite
  other sessions' entries.
- **Compaction**: once the log passes ~40–50 entries, move the oldest into
  `tracker/archive/STATE-YYYY.md` and leave a one-line summary entry.
  Archive — never delete.
- **Privacy**: keep entries de-personalized — no secrets, private paths, or
  commentary about the human. Sensitive scratch goes in an untracked
  `tracker/.scratch.md` (gitignored).
- Commit `tracker/STATE.md` together with the code it describes so handoff
  state is versioned like everything else.
