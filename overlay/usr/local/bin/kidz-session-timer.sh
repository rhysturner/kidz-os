#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="guest"
PIDFILE="/run/user/$(id -u)/kidz-session-timer.pid"

if [ -f "$PIDFILE" ]; then
  existing_pid="$(cat "$PIDFILE")"
  if [ -n "$existing_pid" ] && [ -d "/proc/$existing_pid" ]; then
    exit 0
  fi
fi

echo $$ > "$PIDFILE"
trap 'rm -f "$PIDFILE"' EXIT

sleep 3600
loginctl terminate-user "$TARGET_USER"
