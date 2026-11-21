#!/usr/bin/env bash
set -euo pipefail

# renovate: datasource=custom.proton-pass depName=proton-pass versioning=regex:^(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)-(?<build>\d+)\.x86_64$
PROTON_PASS_URL="https://proton.me/download/pass/linux/proton-pass-1.44.0-1.x86_64.rpm"

dnf5 -y install \
  'https://discord.com/api/download?platform=linux&format=rpm' \
  https://persistent.oaistatic.com/codex-app-prod/linux/rpm/latest/chatgpt.x86_64.rpm \
  https://proton.me/download/mail/linux/ProtonMail-desktop-beta.rpm \
  "$PROTON_PASS_URL" \
  /run/system-bridge.rpm \
  coolercontrol liquidctl code code-insiders ghostty docker-ce docker-ce-cli \
  containerd.io docker-buildx-plugin docker-compose-plugin podman zsh autofs syncthing \
  alsa-lib portaudio pulseaudio-libs pipewire-libs avahi-compat-libdns_sd \
  google-noto-emoji-color-fonts

# Keep release lookup and archive installation out of the package list.
bash /ctx/helpers/install-serein.sh
python3 /ctx/helpers/install-waywallen-kde-plugin.py
bash /ctx/helpers/install-sendspin-cli.sh
