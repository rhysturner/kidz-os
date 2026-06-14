#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TARGET_ROOT="${1:-/}"

if [ ! -d "$TARGET_ROOT" ]; then
  echo "Target root '$TARGET_ROOT' does not exist" >&2
  exit 1
fi

rsync -a "$REPO_ROOT/overlay/" "$TARGET_ROOT/"

EXECUTABLES=(
  "$TARGET_ROOT/usr/local/bin/kidz-postinstall.sh"
  "$TARGET_ROOT/usr/local/bin/kidz-launcher.py"
  "$TARGET_ROOT/usr/local/bin/kidz-session-timer.sh"
  "$TARGET_ROOT/usr/local/bin/kidz-refresh-allowlist.sh"
  "$TARGET_ROOT/usr/local/bin/kidz-apply-firewall.sh"
  "$TARGET_ROOT/home/guest/.config/openbox/autostart"
)
chmod +x "${EXECUTABLES[@]}"

if [ "$TARGET_ROOT" = "/" ]; then
  /usr/local/bin/kidz-postinstall.sh
else
  chroot "$TARGET_ROOT" /usr/local/bin/kidz-postinstall.sh
fi
