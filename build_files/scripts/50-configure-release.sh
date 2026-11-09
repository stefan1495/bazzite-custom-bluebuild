#!/usr/bin/env bash
set -euo pipefail

sed -i \
  -e 's/^NAME=.*/NAME="CleavOS"/' \
  -e 's/^PRETTY_NAME=.*/PRETTY_NAME="CleavOS"/' \
  /usr/lib/os-release
