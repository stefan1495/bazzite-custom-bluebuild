#!/usr/bin/env python3
"""Download and install the latest architecture-specific Waywallen KDE plugin."""

import json
import os
import platform
import urllib.request
import zipfile
from io import BytesIO
from pathlib import PurePosixPath


def main():
    arch = {"x86_64": "x86_64", "aarch64": "aarch64"}.get(platform.machine())
    if arch is None:
        raise SystemExit(
            f"Unsupported architecture for Waywallen KDE plugin: {platform.machine()}"
        )

    request = urllib.request.Request(
        "https://api.github.com/repos/waywallen/waywallen-display/releases/latest",
        headers={
            "Accept": "application/vnd.github+json",
            "User-Agent": "cleav-os-image-build",
        },
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        release = json.load(response)

    asset_name = f"waywallen-kde-{release['tag_name'].removeprefix('v')}-{arch}.zip"
    asset = next((item for item in release["assets"] if item["name"] == asset_name), None)
    if asset is None:
        raise SystemExit(f"No KDE plugin asset {asset_name} in latest release")

    with urllib.request.urlopen(asset["browser_download_url"], timeout=60) as response:
        archive = zipfile.ZipFile(BytesIO(response.read()))

    root = "org.waywallen.kde"
    target = "/usr/share/plasma/wallpapers"
    os.makedirs(target, exist_ok=True)
    for member in archive.infolist():
        path = PurePosixPath(member.filename)
        if path.is_absolute() or ".." in path.parts or not path.parts or path.parts[0] != root:
            raise SystemExit(f"Unexpected path in Waywallen plugin archive: {member.filename}")
        archive.extract(member, target)

    print(f"Installed Waywallen KDE plugin {release['tag_name']} ({arch})")


if __name__ == "__main__":
    main()
