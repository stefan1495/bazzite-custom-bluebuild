#!/usr/bin/env bash
set -euo pipefail

install -d /usr/share/cleav-os/flatpaks
cat > /usr/share/cleav-os/flatpaks/system-install <<'EOF'
one.ablaze.floorp
io.github.trigg.discover_overlay
com.orcaslicer.OrcaSlicer
me.amankhanna.opendeck
EOF

install -d /usr/lib/systemd/system /usr/libexec
cat > /usr/lib/systemd/system/cleav-flatpaks.service <<'EOF'
[Unit]
Description=Install CleavOS default system Flatpaks
Wants=network-online.target
After=network-online.target
ConditionPathExists=/usr/share/cleav-os/flatpaks/system-install

[Service]
Type=oneshot
ExecStart=/usr/libexec/cleav-install-flatpaks
EOF
cat > /usr/lib/systemd/system/cleav-flatpaks.timer <<'EOF'
[Unit]
Description=Install CleavOS default system Flatpaks after boot

[Timer]
OnBootSec=2min
Unit=cleav-flatpaks.service

[Install]
WantedBy=timers.target
EOF
cat > /usr/libexec/cleav-install-flatpaks <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
mapfile -t apps < <(grep -Ev '^[[:space:]]*(#|$)' /usr/share/cleav-os/flatpaks/system-install)
if ((${#apps[@]})); then
  flatpak install --system --noninteractive flathub "${apps[@]}"
fi
EOF
chmod 0755 /usr/libexec/cleav-install-flatpaks
