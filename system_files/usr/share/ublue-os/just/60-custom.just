# Enable Sendspin CLI as its dedicated, unprivileged system service.
cleav-enable-sendspin:
    #!/usr/bin/env bash
    set -euo pipefail

    sudo systemd-sysusers
    sudo systemctl daemon-reload
    if sudo systemctl is-enabled --quiet sendspin.service; then
        sudo systemctl disable --now sendspin.service
    fi
    sudo systemctl enable --now sendspin-cli.service

# Install Orca's AppImage and let Gear Lever manage its integration.
cleav-install-orca:
    #!/usr/bin/env bash
    set -euo pipefail

    if ! flatpak info it.mijorus.gearlever >/dev/null 2>&1; then
        echo "Gear Lever Flatpak (it.mijorus.gearlever) is not installed." >&2
        exit 1
    fi

    temp_dir="$(mktemp -d)"
    trap 'rm -rf "$temp_dir"' EXIT

    appimage="$temp_dir/orca-linux.AppImage"
    curl --fail --location --silent --show-error \
        https://github.com/stablyai/orca/releases/latest/download/orca-linux.AppImage \
        --output "$appimage"
    chmod +x "$appimage"
    printf 'y\n' | flatpak run it.mijorus.gearlever --integrate "$appimage"
