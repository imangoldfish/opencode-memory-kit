#!/usr/bin/env bash
# Smoke tests for scaffold.sh — run from anywhere:
#   bash tests/smoke.sh
# Runs locally and in GitHub Actions (.github/workflows/test.yml).
set -euo pipefail

KIT="${KIT:-$(cd "$(dirname "$0")/.." && pwd)}"
FAILS=0

pass() { echo "  ok: $1"; }
fail() { echo "  FAIL: $1" >&2; FAILS=$((FAILS + 1)); }

echo "== scaffold.sh syntax =="
if bash -n "$KIT/scaffold.sh"; then pass "bash -n"; else fail "bash -n"; fi

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT
mkdir "$workdir/proj"
cd "$workdir/proj"

echo "== first run =="
if KIT="$KIT" "$KIT/scaffold.sh" >out1.txt 2>&1; then
  pass "exits 0"
else
  fail "first run exited non-zero"
  cat out1.txt >&2
fi
if [ -f tracker/STATE.md ] && cmp -s "$KIT/template/STATE.md" tracker/STATE.md; then
  pass "tracker/STATE.md created from seed template"
else
  fail "tracker/STATE.md missing or differs from template"
fi
if [ -f tracker/.gitignore ] && grep -q '^\.scratch\.md$' tracker/.gitignore; then
  pass "tracker/.gitignore ignores .scratch.md"
else
  fail "tracker/.gitignore missing or wrong"
fi
if [ -f AGENTS.md ] && cmp -s "$KIT/template/AGENTS.section.md" AGENTS.md; then
  pass "AGENTS.md created with protocol verbatim"
else
  fail "AGENTS.md missing or protocol not verbatim"
fi

echo "== rerun: idempotent, never clobbers live state =="
if [ -f tracker/STATE.md ]; then echo "LIVE STATE MARKER" >> tracker/STATE.md; fi
if KIT="$KIT" "$KIT/scaffold.sh" >out2.txt 2>&1; then
  pass "exits 0"
else
  fail "rerun exited non-zero"
  cat out2.txt >&2
fi
if grep -q 'LIVE STATE MARKER' tracker/STATE.md; then
  pass "existing live tracker left untouched"
else
  fail "existing live tracker was OVERWRITTEN"
fi
if grep -q 'left unchanged' out2.txt; then
  pass "says tracker left unchanged"
else
  fail "no 'left unchanged' message"
fi
n="$(grep -c '^## Cross-session tracker protocol' AGENTS.md 2>/dev/null || true)"
if [ "${n:-0}" -eq 1 ]; then
  pass "protocol not duplicated in AGENTS.md"
else
  fail "expected exactly 1 protocol section in AGENTS.md, got '${n:-0}'"
fi

echo "== templates are sane =="
if grep -q '^# <Project name> — State Tracker' "$KIT/template/STATE.md"; then
  pass "seed template has placeholders"
else
  fail "seed template placeholders missing"
fi
if grep -q '^## Cross-session tracker protocol' "$KIT/template/AGENTS.section.md"; then
  pass "protocol section header present"
else
  fail "protocol section header missing"
fi

# Global-hook wording sync — only checkable where the hook exists (local machines).
HOOK="$HOME/.config/opencode/AGENTS.md"
if [ -f "$HOOK" ]; then
  echo "== global hook wording sync =="
  if diff -B \
      <(cat "$KIT/template/AGENTS.section.md") \
      <(awk '/^## Cross-session tracker protocol/{f=1} f && /^To set up a tracker/{exit} f' "$HOOK") \
      >/dev/null; then
    pass "template and global hook identical"
  else
    fail "template/AGENTS.section.md and global hook wording differ"
  fi
fi

echo "== KIT missing or broken: fails loudly, scaffolds nothing =="
mkdir "$workdir/nokit"
cd "$workdir/nokit"
if KIT="$workdir/does-not-exist" "$KIT/scaffold.sh" >out.txt 2>&1; then
  fail "KIT pointing nowhere should exit non-zero"
else
  pass "KIT pointing nowhere exits non-zero"
fi
if grep -q 'Template kit not found' out.txt; then
  pass "clear 'Template kit not found' message"
else
  fail "missing 'Template kit not found' message"
fi
if [ ! -e tracker ] && [ ! -e AGENTS.md ]; then
  pass "nothing scaffolded when kit missing"
else
  fail "scaffolded despite missing kit"
fi

mkdir "$workdir/kitisfile"
touch "$workdir/kitisfile/notadir"
cd "$workdir/kitisfile"
if KIT="$workdir/kitisfile/notadir" "$KIT/scaffold.sh" >out.txt 2>&1; then
  fail "KIT pointing at a file should exit non-zero"
else
  pass "KIT pointing at a file exits non-zero"
fi
if [ ! -e tracker ] && [ ! -e AGENTS.md ]; then
  pass "nothing scaffolded when KIT is a file"
else
  fail "scaffolded despite KIT being a file"
fi

mkdir "$workdir/defaultkit"
cd "$workdir/defaultkit"
if env -u KIT HOME="$workdir/fakehome" bash "$KIT/scaffold.sh" >out.txt 2>&1; then
  fail "KIT unset with missing default kit should exit non-zero"
else
  pass "KIT unset with missing default kit exits non-zero"
fi
if grep -q "Template kit not found at $workdir/fakehome/.config/opencode/memory-template" out.txt; then
  pass 'KIT unset falls back to $HOME/.config/opencode/memory-template'
else
  fail 'KIT unset did not use $HOME default path'
fi

echo "== partial kit: missing template files =="
mkdir -p "$workdir/partialkit1/template"
touch "$workdir/partialkit1/template/AGENTS.section.md"   # STATE.md missing
mkdir "$workdir/partial1"
cd "$workdir/partial1"
if KIT="$workdir/partialkit1" "$KIT/scaffold.sh" >out.txt 2>&1; then
  fail "kit missing template/STATE.md should exit non-zero"
else
  pass "kit missing template/STATE.md exits non-zero"
fi
if [ ! -e tracker/STATE.md ] && [ ! -e AGENTS.md ]; then
  pass "no half-created project files from broken kit"
else
  fail "half-created files from kit missing STATE.md"
fi

mkdir -p "$workdir/partialkit2/template"
cp "$KIT/template/STATE.md" "$workdir/partialkit2/template/STATE.md"  # section missing
mkdir "$workdir/partial2"
cd "$workdir/partial2"
if KIT="$workdir/partialkit2" "$KIT/scaffold.sh" >out.txt 2>&1; then
  fail "kit missing template/AGENTS.section.md should exit non-zero"
else
  pass "kit missing template/AGENTS.section.md exits non-zero"
fi
if [ ! -e AGENTS.md ]; then
  pass "AGENTS.md not created when section template missing"
else
  fail "AGENTS.md created despite missing section template"
fi

echo "== existing AGENTS.md variants =="
mkdir "$workdir/agents-no-protocol"
cd "$workdir/agents-no-protocol"
printf '# My project\n\nSome project rules.\n' > AGENTS.md
if KIT="$KIT" "$KIT/scaffold.sh" >out.txt 2>&1; then
  pass "AGENTS.md without protocol: exits 0"
else
  fail "AGENTS.md without protocol: non-zero exit"
  cat out.txt >&2
fi
if grep -q '^# My project' AGENTS.md; then
  pass "existing AGENTS.md content preserved"
else
  fail "existing AGENTS.md content lost"
fi
if [ "$(grep -c 'Cross-session tracker protocol' AGENTS.md || true)" -eq 1 ] &&
   grep -q '^## Cross-session tracker protocol' AGENTS.md; then
  pass "protocol appended exactly once as a section"
else
  fail "protocol not appended exactly once as a section"
fi

mkdir "$workdir/agents-empty"
cd "$workdir/agents-empty"
: > AGENTS.md
if KIT="$KIT" "$KIT/scaffold.sh" >out.txt 2>&1; then
  pass "empty AGENTS.md: exits 0"
else
  fail "empty AGENTS.md: non-zero exit"
  cat out.txt >&2
fi
if [ "$(grep -c 'Cross-session tracker protocol' AGENTS.md || true)" -eq 1 ]; then
  pass "empty AGENTS.md: protocol present exactly once"
else
  fail "empty AGENTS.md: protocol missing or duplicated"
fi

mkdir "$workdir/agents-midfile"
cd "$workdir/agents-midfile"
{ printf '# My project\n\nintro\n\n'
  cat "$KIT/template/AGENTS.section.md"
  printf '\n## Tail section\n\ntail marker\n'; } > AGENTS.md
if KIT="$KIT" "$KIT/scaffold.sh" >out.txt 2>&1; then
  pass "protocol mid-file: exits 0"
else
  fail "protocol mid-file: non-zero exit"
  cat out.txt >&2
fi
if [ "$(grep -c 'Cross-session tracker protocol' AGENTS.md || true)" -eq 1 ] &&
   grep -q '^tail marker$' AGENTS.md; then
  pass "protocol mid-file: not duplicated, tail intact"
else
  fail "protocol mid-file duplicated or tail clobbered"
fi
if grep -q 'already has the protocol' out.txt; then
  pass "protocol mid-file: says already has the protocol"
else
  fail "protocol mid-file: no 'already has the protocol' message"
fi

mkdir "$workdir/agents-no-tracker"
cd "$workdir/agents-no-tracker"
cp "$KIT/template/AGENTS.section.md" AGENTS.md
if KIT="$KIT" "$KIT/scaffold.sh" >out.txt 2>&1; then
  pass "protocol without tracker: exits 0"
else
  fail "protocol without tracker: non-zero exit"
  cat out.txt >&2
fi
if [ -f tracker/STATE.md ] &&
   [ "$(grep -c 'Cross-session tracker protocol' AGENTS.md || true)" -eq 1 ]; then
  pass "protocol without tracker: tracker completed, protocol not duplicated"
else
  fail "protocol without tracker: tracker missing or protocol duplicated"
fi

echo "== tracker/ existing as a file: refuses =="
mkdir "$workdir/tracker-file"
cd "$workdir/tracker-file"
printf 'I AM NOT A DIRECTORY\n' > tracker
if KIT="$KIT" "$KIT/scaffold.sh" >out.txt 2>&1; then
  fail "tracker as a file should exit non-zero"
else
  pass "tracker as a file exits non-zero"
fi
if grep -q 'I AM NOT A DIRECTORY' tracker && [ ! -e AGENTS.md ]; then
  pass "tracker file untouched, nothing else created"
else
  fail "tracker file modified or AGENTS.md created"
fi

echo "== leftovers from a partial previous run =="
mkdir -p "$workdir/half-tracker/tracker"
cd "$workdir/half-tracker"
cp "$KIT/template/STATE.md" tracker/STATE.md
echo "LIVE TRACKER MARKER" >> tracker/STATE.md
if KIT="$KIT" "$KIT/scaffold.sh" >out.txt 2>&1; then
  pass "tracker dir without .gitignore: exits 0"
else
  fail "tracker dir without .gitignore: non-zero exit"
  cat out.txt >&2
fi
if grep -q 'LIVE TRACKER MARKER' tracker/STATE.md; then
  pass "existing tracker/STATE.md preserved"
else
  fail "existing tracker/STATE.md OVERWRITTEN"
fi
if [ -f tracker/.gitignore ] && grep -q '^\.scratch\.md$' tracker/.gitignore; then
  pass "missing tracker/.gitignore created"
else
  fail "missing tracker/.gitignore not created"
fi

mkdir -p "$workdir/custom-gitignore/tracker"
cd "$workdir/custom-gitignore"
printf 'custom-ignore-line\n' > tracker/.gitignore
if KIT="$KIT" "$KIT/scaffold.sh" >out.txt 2>&1; then
  pass "custom .gitignore: exits 0"
else
  fail "custom .gitignore: non-zero exit"
  cat out.txt >&2
fi
if grep -q 'custom-ignore-line' tracker/.gitignore; then
  pass "custom tracker/.gitignore not overwritten"
else
  fail "custom tracker/.gitignore OVERWRITTEN"
fi
if grep -q 'does not ignore .scratch.md' out.txt; then
  pass "warns when existing .gitignore misses .scratch.md"
else
  fail "no warning when existing .gitignore misses .scratch.md"
fi

echo "== runs against the current directory only =="
mkdir -p "$workdir/subdir-proj/nested"
cd "$workdir/subdir-proj/nested"
if KIT="$KIT" "$KIT/scaffold.sh" >out.txt 2>&1; then
  pass "run from subdirectory: exits 0"
else
  fail "run from subdirectory: non-zero exit"
  cat out.txt >&2
fi
if [ -f AGENTS.md ] && [ -f tracker/STATE.md ]; then
  pass "scaffolded into the current directory"
else
  fail "not scaffolded into the current directory"
fi
if [ ! -e "$workdir/subdir-proj/AGENTS.md" ] && [ ! -e "$workdir/subdir-proj/tracker" ]; then
  pass "parent directory left untouched"
else
  fail "scaffold leaked into the parent directory"
fi

spaced="$workdir/proj with spaces and 'quotes' \$dollar"
mkdir "$spaced"
cd "$spaced"
if KIT="$KIT" "$KIT/scaffold.sh" >out.txt 2>&1; then
  pass "project dir with spaces/quotes/\$ exits 0"
else
  fail "project dir with weird chars: non-zero exit"
  cat out.txt >&2
fi
if [ -f AGENTS.md ] && [ -f tracker/STATE.md ]; then
  pass "scaffolded in weird-named directory"
else
  fail "not scaffolded in weird-named directory"
fi

echo "== second project from a different cwd is independent =="
mkdir "$workdir/proj-a" "$workdir/proj-b"
cd "$workdir/proj-a"
KIT="$KIT" "$KIT/scaffold.sh" >out-a.txt 2>&1 || true
cd "$workdir/proj-b"
if KIT="$KIT" "$KIT/scaffold.sh" >out.txt 2>&1; then
  pass "fresh cwd: exits 0"
else
  fail "fresh cwd: non-zero exit"
  cat out.txt >&2
fi
if grep -q 'Created AGENTS.md with the tracker protocol' out.txt &&
   grep -q 'Created tracker/STATE.md' out.txt; then
  pass "fresh cwd: not confused by the previous project"
else
  fail "fresh cwd: reused previous project's state"
fi
if [ "$(grep -c 'Cross-session tracker protocol' AGENTS.md || true)" -eq 1 ]; then
  pass "fresh cwd: protocol present exactly once"
else
  fail "fresh cwd: protocol missing or duplicated"
fi

echo "== regression guards: scrutiny/tester findings (2026-10-07) =="
# M1: a prose *mention* of the protocol must not block its installation.
mkdir "$workdir/agents-prose-mention"
cd "$workdir/agents-prose-mention"
printf 'We do NOT follow the Cross-session tracker protocol here.\n' > AGENTS.md
if KIT="$KIT" "$KIT/scaffold.sh" >out.txt 2>&1; then
  pass "prose mention: exits 0"
else
  fail "prose mention: non-zero exit"
  cat out.txt >&2
fi
if [ "$(grep -c '^## Cross-session tracker protocol' AGENTS.md || true)" -eq 1 ] &&
   grep -q 'We do NOT follow' AGENTS.md; then
  pass "prose mention: protocol still installed, original line kept"
else
  fail "prose mention blocked protocol install (unanchored grep?)"
fi

# M2: a broken kit must not mutate an existing AGENTS.md (validate, then write).
mkdir -p "$workdir/partialkit3/template"
cp "$KIT/template/STATE.md" "$workdir/partialkit3/template/STATE.md"  # section missing
mkdir "$workdir/partial3"
cd "$workdir/partial3"
printf 'SENTINEL CONTENT\n' > AGENTS.md
if KIT="$workdir/partialkit3" "$KIT/scaffold.sh" >out.txt 2>&1; then
  fail "broken kit + existing AGENTS.md should exit non-zero"
else
  pass "broken kit + existing AGENTS.md exits non-zero"
fi
if cmp -s AGENTS.md <(printf 'SENTINEL CONTENT\n'); then
  pass "broken kit leaves existing AGENTS.md byte-identical"
else
  fail "broken kit mutated existing AGENTS.md"
fi

# m1: STATE.md / AGENTS.md existing as directories must refuse, not lie-success.
mkdir -p "$workdir/state-is-dir/tracker/STATE.md"
cd "$workdir/state-is-dir"
if KIT="$KIT" "$KIT/scaffold.sh" >out.txt 2>&1; then
  fail "tracker/STATE.md as a directory should exit non-zero"
else
  pass "tracker/STATE.md as a directory exits non-zero"
fi
if [ ! -e AGENTS.md ] && [ ! -e tracker/STATE.md/STATE.md ]; then
  pass "directory STATE.md: nothing created, no nested copy"
else
  fail "directory STATE.md: AGENTS.md created or nested copy made"
fi

mkdir "$workdir/agents-is-dir"
cd "$workdir/agents-is-dir"
mkdir AGENTS.md
if KIT="$KIT" "$KIT/scaffold.sh" >out.txt 2>&1; then
  fail "AGENTS.md as a directory should exit non-zero"
else
  pass "AGENTS.md as a directory exits non-zero"
fi
if [ ! -e tracker ]; then
  pass "directory AGENTS.md: validated before any mutation"
else
  fail "directory AGENTS.md: tracker created anyway"
fi

echo
if [ "$FAILS" -eq 0 ]; then
  echo "ALL TESTS PASSED"
else
  echo "$FAILS TEST(S) FAILED" >&2
  exit 1
fi
