#!/usr/bin/env bash
set -euo pipefail

install -d /usr/share/fonts/nerd-fonts
curl -fLsS --retry 5 \
  https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.tar.xz \
  -o /tmp/FiraCode.tar.xz
tar -xJf /tmp/FiraCode.tar.xz -C /usr/share/fonts/nerd-fonts
fc-cache -f
