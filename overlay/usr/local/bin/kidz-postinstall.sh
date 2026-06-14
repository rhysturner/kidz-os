#!/usr/bin/env bash
set -euo pipefail

GUEST_USER="guest"
REQUIRED_PACKAGES=(
  lightdm
  openbox
  xorg
  xserver-xorg-core
  python3
  python3-pyqt6
  alsa-utils
  iptables
  ipset
  iptables-persistent
  firefox-esr
  tuxpaint
  scratch
  gcompris-qt
)
REMOVE_PACKAGES=(
  ubuntu-desktop
  ubuntu-desktop-minimal
  gnome-shell
  gdm3
  xterm
  gnome-terminal
  xfce4-terminal
  konsole
  lxterminal
  mate-terminal
  gnome-control-center
)

ensure_group_membership_removed() {
  local user="$1"
  local group="$2"
  if getent group "$group" >/dev/null 2>&1; then
    gpasswd -d "$user" "$group" || true
  fi
}

echo "[1/9] Installing required packages..."
apt-get update
apt-get install -y "${REQUIRED_PACKAGES[@]}"

echo "[2/9] Removing common desktop shells, terminals, and settings apps..."
apt-get purge -y "${REMOVE_PACKAGES[@]}" || true
apt-get autoremove -y

echo "[3/9] Creating restricted guest user..."
if ! id "$GUEST_USER" >/dev/null 2>&1; then
  useradd -m -s /bin/bash "$GUEST_USER"
fi
mkdir -p "/home/${GUEST_USER}/.config/openbox"
passwd -d "$GUEST_USER" || true
usermod -L "$GUEST_USER" || true
ensure_group_membership_removed "$GUEST_USER" sudo
ensure_group_membership_removed "$GUEST_USER" adm

if getent group plugdev >/dev/null 2>&1; then
  usermod -aG plugdev "$GUEST_USER"
fi
if getent group audio >/dev/null 2>&1; then
  usermod -aG audio "$GUEST_USER"
fi

echo "[4/9] Locking root account..."
passwd -l root || true

echo "[5/9] Disabling extra virtual terminals and reboot shortcuts..."
systemctl mask getty@tty2.service getty@tty3.service getty@tty4.service getty@tty5.service getty@tty6.service || true
systemctl mask ctrl-alt-del.target || true

echo "[6/9] Installing overlay permissions..."
chown -R "${GUEST_USER}:${GUEST_USER}" "/home/${GUEST_USER}/.config"
chmod +x /home/${GUEST_USER}/.config/openbox/autostart
chmod +x /usr/local/bin/kidz-postinstall.sh          /usr/local/bin/kidz-launcher.py          /usr/local/bin/kidz-session-timer.sh          /usr/local/bin/kidz-refresh-allowlist.sh          /usr/local/bin/kidz-apply-firewall.sh

echo "[7/9] Refreshing systemd and enabling LightDM..."
systemctl daemon-reload
systemctl enable lightdm

echo "[8/9] Enabling allowlist refresh timer..."
systemctl enable kidz-allowlist-refresh.timer

echo "[9/9] Applying initial network allowlist..."
/usr/local/bin/kidz-apply-firewall.sh

echo "Post-install complete."
