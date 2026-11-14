#!/usr/bin/env bash
set -euo pipefail

cp -avf /ctx/system_files/. /
printf '\nimport "/usr/share/ublue-os/just/60-custom.just"\n' >> /usr/share/ublue-os/justfile
