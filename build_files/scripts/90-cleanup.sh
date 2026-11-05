#!/usr/bin/env bash
set -euo pipefail

dnf5 -y copr disable scottames/ghostty
dnf5 clean all
rm -rf /run/dnf
rm -f /var/log/dnf5.log /tmp/FiraCode.tar.xz
