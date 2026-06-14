# kidz-os

A kid-friendly Ubuntu/Debian derivative overlay for ages 5-10.

## Repository layout

```text
/home/runner/work/kidz-os/kidz-os/rhysturner/kidz-os/
├── overlay/
│   ├── etc/
│   │   ├── firefox/policies/policies.json
│   │   ├── lightdm/lightdm.conf.d/50-kidzos.conf
│   │   ├── systemd/system/kidz-allowlist-refresh.service
│   │   ├── systemd/system/kidz-allowlist-refresh.timer
│   │   └── X11/xorg.conf.d/10-kidz-kiosk.conf
│   ├── home/guest/.config/openbox/autostart
│   └── usr/
│       ├── local/bin/
│       │   ├── kidz-apply-firewall.sh
│       │   ├── kidz-launcher.py
│       │   ├── kidz-postinstall.sh
│       │   ├── kidz-refresh-allowlist.sh
│       │   └── kidz-session-timer.sh
│       └── share/kidz-os/click.wav
├── live-build/config/package-lists/kidz.list.chroot
└── scripts/install-overlay.sh
```

## Components

### 1. Base configuration and lockdown

- `overlay/usr/local/bin/kidz-postinstall.sh` installs kiosk dependencies, removes common desktop shells and terminal apps, locks root, creates a restricted `guest` user, enables LightDM, and applies the initial network policy.
- `overlay/etc/X11/xorg.conf.d/10-kidz-kiosk.conf` disables VT switching and common X escape sequences.
- `overlay/etc/lightdm/lightdm.conf.d/50-kidzos.conf` configures passwordless autologin into the `guest` Openbox session.

### 2. Kid-friendly launcher UI

- `overlay/home/guest/.config/openbox/autostart` starts the session timer and the launcher on login.
- `overlay/usr/local/bin/kidz-launcher.py` is a PyQt6 fullscreen launcher with large color-coded buttons for Tux Paint, GCompris, Scratch, and Firefox ESR in kiosk mode.
- `overlay/usr/share/kidz-os/click.wav` provides a click sound for button presses.

### 3. Parental controls and safety

- `overlay/usr/local/bin/kidz-refresh-allowlist.sh` resolves the web allowlist into `ipset` sets.
- `overlay/usr/local/bin/kidz-apply-firewall.sh` applies IPv4 and IPv6 firewall rules that only permit DNS plus HTTP/HTTPS to allowlisted destinations for the `guest` user.
- `overlay/etc/systemd/system/kidz-allowlist-refresh.{service,timer}` refresh the allowlist every 15 minutes.
- `overlay/usr/local/bin/kidz-session-timer.sh` logs out the `guest` user after one hour.

## Installation

### Option A: apply overlay to an installed system

Copy the overlay into a target root and run the post-install script:

```bash
sudo /home/runner/work/kidz-os/kidz-os/rhysturner/kidz-os/scripts/install-overlay.sh /
sudo reboot
```

To apply to a mounted root filesystem instead of the current host:

```bash
sudo /home/runner/work/kidz-os/kidz-os/rhysturner/kidz-os/scripts/install-overlay.sh /mnt/kidz-root
```

### Option B: build a bootable ISO with `live-build`

Install the build dependencies:

```bash
sudo apt-get update
sudo apt-get install -y live-build debootstrap squashfs-tools xorriso rsync
```

Create a build workspace and seed it with this repository's package list and overlay:

```bash
mkdir -p ~/kidz-live/config/includes.chroot ~/kidz-live/config/package-lists
cd ~/kidz-live
lb config
cp /home/runner/work/kidz-os/kidz-os/rhysturner/kidz-os/live-build/config/package-lists/kidz.list.chroot config/package-lists/
cp -a /home/runner/work/kidz-os/kidz-os/rhysturner/kidz-os/overlay/* config/includes.chroot/
sudo lb build
```

The resulting ISO can be written to USB media with `dd`, Rufus, Balena Etcher, or Ventoy.

## Validation checklist

After installation, verify:

1. LightDM logs straight into `guest` without prompting for a password.
2. The fullscreen launcher starts automatically and hides the underlying desktop.
3. Tux Paint, GCompris, Scratch, and Firefox ESR launch from the grid buttons.
4. Only allowlisted web destinations are reachable from the browser.
5. The `guest` session ends after one hour.

## Operational notes

- Keep a separate hidden administrator account for maintenance.
- Modern educational sites may require additional CDN hostnames in the allowlist.
- For production deployments, also lock firmware boot order and protect BIOS/UEFI settings with a password.
