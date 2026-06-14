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
for executable in "${EXECUTABLES[@]}"; do
  if [ ! -e "$executable" ]; then
    echo "Expected overlay file '$executable' is missing after sync" >&2
    exit 1
  fi
  chmod +x "$executable"
done

if [ "$TARGET_ROOT" = "/" ]; then
  if ! /usr/local/bin/kidz-postinstall.sh; then
    echo "Overlay copied, but post-install failed on the current system" >&2
    exit 1
  fi
else
  if ! chroot "$TARGET_ROOT" /usr/local/bin/kidz-postinstall.sh; then
    echo "Overlay copied, but post-install failed inside chroot '$TARGET_ROOT'" >&2
    exit 1
  fi
fi
