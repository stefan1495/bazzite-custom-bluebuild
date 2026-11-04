# CLAUDE.md

Guidance for working in this repository.

## Project Overview

CleavOS is a custom Fedora Atomic/bootc image based on `ghcr.io/ublue-os/bazzite-nvidia-open:stable`, published as `ghcr.io/stefan1495/cleav-os`.

## Build Structure

- `Containerfile`: container image build entrypoint, based on the pinned template structure.
- `image-template.env`: image name, registry organization, metadata, and default tag.
- `build_files/build.sh`: runs numbered build steps from `build_files/scripts/` in lexical order.
- `build_files/scripts/`: separate steps for copied system files, signing policy, repositories, packages, fonts, OS metadata, Flatpaks, services, and cleanup.
- `system_files/`: files copied into the image root filesystem.
- `Justfile`: local build and helper commands from `ublue-os/image-template` revision `72e9b7c2fc9bf5a1ba642f99b6d12d7e70de96d9`.
- `.github/workflows/build.yml`: builds the image, publishes on scheduled/main-branch/manual runs, and signs published images with `SIGNING_SECRET`. Pull requests build without publishing.
- `cosign.pub`: public key used to verify this image's signatures.
- `renovate.json`: updates Proton Pass, Orca IDE, and System Bridge declarations in `build_files/scripts/30-install-packages.sh`.

## Common Commands

```bash
# Validate Justfile syntax
just check

# Build locally without publishing
just build localhost/cleav-os test

# Verify a published image
cosign verify --key cosign.pub ghcr.io/stefan1495/cleav-os
```

Do not publish, rebase a daily-use installation, or change remote state as part of local validation.

## Making Changes

- Add or update RPM packages in `build_files/scripts/30-install-packages.sh`; use the corresponding numbered script for repositories, fonts, Flatpaks, services, or release metadata.
- Keep the numbered build-step order stable. `build_files/build.sh` executes matching scripts in lexical order.
- Put files intended for `/etc`, `/usr`, or other image paths in `system_files/` using the matching path beneath that directory.
- Keep system service units under `system_files/usr/lib/systemd/system/` and user service units under `system_files/usr/lib/systemd/user/`.
- Direct RPM URLs should be reviewed for architecture, update strategy, and signature verification. Avoid placing secrets in the build context or logs.
- Validate shell syntax for each helper (`for f in build_files/build.sh build_files/scripts/*.sh; do bash -n "$f"; done`), Just syntax (`just check`), workflow YAML, Renovate JSON, and a local image build before publishing.

The workflow runs daily at 06:17 UTC, on pushes to `main`, and on manual dispatch. Pull-request builds do not publish production tags.
