#!/usr/bin/env bash
set -e

check_env_var() {
  local var_name="$1"
  if [ -z "${!var_name}" ]; then
    echo "Error: Environment variable $var_name is not set."
    exit 1
  fi
}

check_env_var "RESTIC_REPOSITORY"
check_env_var "RESTIC_PASSWORD"

if ! restic cat config; then
  if [ $? -eq 10 ]; then
    echo "restic repository does not exist"
    restic init
  fi
fi

restic backup . --skip-if-unchanged
restic forget --keep-last 7 --keep-monthly 2 --prune
