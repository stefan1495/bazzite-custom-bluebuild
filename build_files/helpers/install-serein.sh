#!/usr/bin/env bash
set -euo pipefail

# Install the newest Serein nightly RPM compatible with the Fedora 44 image.
api=https://api.github.com/repos/ViceVerse-cz/Serein/releases?per_page=100
asset_url=$(curl --fail --silent --show-error "$api" | python3 -c '
import json, sys
releases = json.load(sys.stdin)
for release in releases:
    if release.get("draft") or not release.get("prerelease"):
        continue
    for asset in release.get("assets", []):
        name = asset["name"]
        if "Linux-fedora-44-" in name and name.endswith(".x86_64.rpm"):
            print(asset["browser_download_url"])
            raise SystemExit(0)
raise SystemExit("No Fedora 44 x86_64 RPM found in Serein nightly releases")
')
curl --fail --location --silent --show-error "$asset_url" --output /tmp/serein.rpm
dnf5 -y install /tmp/serein.rpm
rm -f /tmp/serein.rpm
