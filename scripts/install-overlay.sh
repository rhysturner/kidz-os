#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="/home/runner/work/kidz-os/kidz-os/rhysturner/kidz-os"
TARGET_ROOT="${1:-/}"

if [ ! -d "$TARGET_ROOT" ]; then
  echo "Target root '$TARGET_ROOT' does not exist" >&2
  exit 1
fi

rsync -a "$REPO_ROOT/overlay/" "$TARGET_ROOT/"

chmod +x   "$TARGET_ROOT/usr/local/bin/kidz-postinstall.sh"   "$TARGET_ROOT/usr/local/bin/kidz-launcher.py"   "$TARGET_ROOT/usr/local/bin/kidz-session-timer.sh"   "$TARGET_ROOT/usr/local/bin/kidz-refresh-allowlist.sh"   "$TARGET_ROOT/usr/local/bin/kidz-apply-firewall.sh"   "$TARGET_ROOT/home/guest/.config/openbox/autostart"

if [ "$TARGET_ROOT" = "/" ]; then
  /usr/local/bin/kidz-postinstall.sh
else
  chroot "$TARGET_ROOT" /usr/local/bin/kidz-postinstall.sh
fi
