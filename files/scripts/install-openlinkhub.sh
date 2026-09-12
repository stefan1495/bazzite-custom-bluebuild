#!/usr/bin/env bash

set -oue pipefail

install_dir=/usr/lib/OpenLinkHub
tmp_dir=$(mktemp -d)
archive="$tmp_dir/OpenLinkHub.tar.gz"

cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

# Immutable distributions must use the upstream user-space archive, not an RPM.
tag=$(curl --fail --silent --show-error https://api.github.com/repos/jurkovic-nikola/OpenLinkHub/releases/latest \
  | sed -nE 's/.*"tag_name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' \
  | head -n 1)

if [ -z "$tag" ]; then
  echo "Could not determine the latest OpenLinkHub release" >&2
  exit 1
fi

curl --fail --location --silent --show-error \
  "https://github.com/jurkovic-nikola/OpenLinkHub/releases/download/${tag}/OpenLinkHub_${tag}_amd64.tar.gz" \
  --output "$archive"

mkdir -p "$install_dir"
tar --extract --gzip --file "$archive" --directory "$tmp_dir"

if [ ! -d "$tmp_dir/OpenLinkHub" ] || [ ! -f "$tmp_dir/OpenLinkHub/OpenLinkHub" ] || [ ! -f "$tmp_dir/OpenLinkHub/99-openlinkhub.rules" ]; then
  echo "OpenLinkHub archive has an unexpected layout" >&2
  exit 1
fi

# The archive contains an OpenLinkHub directory. Preserve the image's config.json.
cp --archive --no-clobber "$tmp_dir/OpenLinkHub/." "$install_dir/"

# Give logged-in users access to supported USB devices without requiring a mutable
# system user or a manual post-install step on the immutable host.
sed 's/, OWNER="openlinkhub"/, TAG+="uaccess"/g' \
  "$install_dir/99-openlinkhub.rules" \
  > /etc/udev/rules.d/99-openlinkhub.rules
rm "$install_dir/99-openlinkhub.rules"

chmod 755 "$install_dir/OpenLinkHub"
chmod 644 /etc/udev/rules.d/99-openlinkhub.rules
