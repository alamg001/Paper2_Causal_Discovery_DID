#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p .lake/validation
if grep -RInE --include='*.lean' '\b(sorry|admit)\b' . --exclude-dir=.lake; then
  echo 'ERROR: admissions found in Lean sources' >&2; exit 1
fi
lake --version | tee .lake/validation/lake_version.log
lean --version | tee .lake/validation/lean_version.log
lake build 2>&1 | tee .lake/validation/lake_build.log
lake env lean Audit.lean 2>&1 | tee .lake/validation/audit.log
if grep -q 'sorryAx' .lake/validation/audit.log; then
  echo 'ERROR: proof depends on sorryAx' >&2; exit 1
fi
lake env lean AuditChallenge.lean 2>&1 | tee .lake/validation/audit_challenge.log
if grep -q 'sorryAx' .lake/validation/audit_challenge.log; then
  echo 'ERROR: Challenge proof depends on sorryAx' >&2; exit 1
fi
if [[ "${1:-}" == "--comparator" ]]; then
  lake comparator --config comparator.json 2>&1 | tee .lake/validation/comparator.log
fi
