#!/usr/bin/env bash
set -euo pipefail

VERSION="0.4.0"
ARCHIVE="sendspin-cli-${VERSION}-linux-x86_64.tar.gz"
URL="https://github.com/Sendspin/sendspin-cpp-cli/releases/download/v${VERSION}/${ARCHIVE}"
EXPECTED_SHA256="40efcab39ef303d026d8880ad1ada7b53b29e806114ae3744f9ed33daee0c5d9"

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

curl --fail --location --silent --show-error "$URL" --output "$workdir/$ARCHIVE"
printf '%s  %s\n' "$EXPECTED_SHA256" "$workdir/$ARCHIVE" | sha256sum --check --status

tar -xzf "$workdir/$ARCHIVE" \
  --directory / \
  --no-same-owner \
  "sendspin-cli-${VERSION}-linux-x86_64/usr/local"
