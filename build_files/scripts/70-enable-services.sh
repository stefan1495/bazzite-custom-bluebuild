#!/usr/bin/env bash
set -euo pipefail

systemctl enable \
  sendspin.service \
  docker.socket \
  podman.socket \
  cleav-docker-groups.service \
  cleav-flatpaks.timer
systemctl --global enable cleav-default-web-browser.service
