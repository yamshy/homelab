#!/usr/bin/env bash
set -Eeuo pipefail

# Test: check_cli logs success and exits 0 when required deps exist

if output=$(LOG_LEVEL=debug bash -c 'source /workspace/scripts/lib/common.sh; check_cli bash printf'); then
  # Strip ANSI color codes for stable matching
  clean_output=$(echo "$output" | sed -r 's/\x1B\[[0-9;]*[mK]//g')

  if echo "$clean_output" | grep -q "DEBUG Deps are installed"; then
    echo "PASS: check_cli main path logs success and exits 0"
    exit 0
  else
    echo "FAIL: Expected success log not found in output"
    echo "$clean_output"
    exit 1
  fi
else
  echo "FAIL: check_cli exited non-zero on main path"
  exit 1
fi

