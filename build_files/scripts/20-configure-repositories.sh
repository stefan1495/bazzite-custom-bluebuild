#!/usr/bin/env bash
set -euo pipefail

dnf5 -y copr enable codifryed/CoolerControl
dnf5 -y copr enable scottames/ghostty
dnf5 config-manager addrepo --from-repofile=/ctx/vscode.repo
dnf5 config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
rpm --import https://packages.microsoft.com/keys/microsoft.asc
