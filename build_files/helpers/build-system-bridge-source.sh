#!/usr/bin/env bash
set -euo pipefail

version="${1:?usage: build-system-bridge-source.sh VERSION}"
source_pin=5.28.5@0569fe41dde64b5ec607c97bede0b403ae3071df
pinned_version="${source_pin%@*}"
commit="${source_pin#*@}"
if [[ "${version}" != "${pinned_version}" ]]; then
  printf 'Containerfile version %s does not match pinned source %s\n' "${version}" "${pinned_version}" >&2
  exit 1
fi

pacman -Syu --noconfirm
pacman -S --noconfirm --needed base-devel ca-certificates curl git libx11 libxkbcommon libxkbcommon-x11 libxtst openssl pkgconf unzip wget xorgproto
pacman -Scc --noconfirm

export MISE_DATA_DIR=/mise
export MISE_CACHE_DIR=/mise/cache
export MISE_INSTALL_PATH=/usr/local/bin/mise
export PATH="/mise/shims:/usr/local/bin:/usr/bin:${PATH}"
curl --fail --location --silent --show-error \
  https://github.com/jdx/mise/releases/download/v2026.1.0/mise-v2026.1.0-linux-x64 \
  --output /usr/local/bin/mise
echo 'a0a812c3a87fbaa7792742f6d84c27a175fed44a8f2ab3e900d50479396e840e  /usr/local/bin/mise' | sha256sum --check
chmod 0755 /usr/local/bin/mise

git clone --depth 1 --branch "${version}" https://github.com/timmo001/system-bridge.git .
test "$(git rev-parse HEAD)" = "${commit}"
mise trust -a
mise install
mise run build:all
