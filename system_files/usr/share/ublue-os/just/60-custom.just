# Enable Sendspin CLI as a user service with per-user configuration.
cleav-enable-sendspin:
    #!/usr/bin/env bash
    set -euo pipefail

    config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/sendspin-cli"
    config_file="$config_dir/config"
    mkdir -p "$config_dir"
    if [[ ! -e "$config_file" ]]; then
        install -m 0644 /usr/share/doc/sendspin-cli/sendspin-cli.conf.example "$config_file"
    fi

    if sudo systemctl is-enabled --quiet sendspin-cli.service || sudo systemctl is-active --quiet sendspin-cli.service; then
        sudo systemctl disable --now sendspin-cli.service
    fi
    if sudo systemctl is-enabled --quiet sendspin.service || sudo systemctl is-active --quiet sendspin.service; then
        sudo systemctl disable --now sendspin.service
    fi

    systemctl --user daemon-reload
    systemctl --user enable --now sendspin-cli.service
    printf 'Sendspin user config: %s\n' "$config_file"

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

# Install Vesktop's AppImage and let Gear Lever manage its integration.
cleav-install-vesktop:
    #!/usr/bin/env bash
    set -euo pipefail

    if ! flatpak info it.mijorus.gearlever >/dev/null 2>&1; then
        echo "Gear Lever Flatpak (it.mijorus.gearlever) is not installed." >&2
        exit 1
    fi

    temp_dir="$(mktemp -d)"
    trap 'rm -rf "$temp_dir"' EXIT

    appimage="$temp_dir/Vesktop.AppImage"
    curl --fail --location --silent --show-error --proto-redir '=https' \
        https://vencord.dev/download/vesktop/amd64/appimage \
        --output "$appimage"
    chmod +x "$appimage"
    printf 'y\n' | flatpak run it.mijorus.gearlever --integrate "$appimage"
