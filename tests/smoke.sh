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
if [ -f tracker/.gitignore ] && grep -q '.scratch.md' tracker/.gitignore; then
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
echo "LIVE STATE MARKER" >> tracker/STATE.md
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
if [ "$(grep -c 'Cross-session tracker protocol' AGENTS.md || true)" -eq 1 ]; then
  pass "protocol not duplicated in AGENTS.md"
else
  fail "protocol duplicated in AGENTS.md"
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

echo
if [ "$FAILS" -eq 0 ]; then
  echo "ALL TESTS PASSED"
else
  echo "$FAILS TEST(S) FAILED" >&2
  exit 1
fi
