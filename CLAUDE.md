# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a BlueBuild custom OS image repository based on Bazzite-DX with NVIDIA support. It builds a custom Fedora Atomic (ostree) container image named "cleav-os" that extends the Universal Blue ecosystem.

## Architecture

### Build System
- **BlueBuild Framework**: Uses the BlueBuild template system for declarative OS image configuration
- **Base Image**: Built on `ghcr.io/ublue-os/bazzite-dx-nvidia:stable`
- **Build Process**: GitHub Actions builds the image on schedule (06:00 UTC daily) and on push/PR
- **Image Signing**: Uses Sigstore cosign for image verification with `cosign.pub`

### Configuration Files
- `recipes/recipe.yml`: Main recipe defining the image name, base image, and module imports
- `recipes/common-modules.yml`: Contains all module definitions (packages, repos, fonts, etc.)
- `.github/workflows/build.yml`: CI/CD pipeline using `blue-build/github-action@v1.11`

### Module System
The image is built using BlueBuild modules executed in order from `common-modules.yml`:
1. **signing**: Enables image signing
2. **files**: Copies files from `files/system/` to `/` in the image
3. **fonts**: Installs Nerd Fonts (FiraCode) and Google Fonts (Noto Color Emoji)
4. **bling**: Installs 1Password via BlueBuild's bling module
5. **rpm-ostree**: Manages package installation with custom repos:
   - LibreWolf browser from librewolf.net repo
   - CoolerControl and liquidctl from COPR repo
   - ProtonMail desktop (via direct RPM URL)
   - syncthing
6. **default-flatpaks**: Installs Discover Overlay flatpak

### Directory Structure
- `files/system/etc/`: System configuration files (1password, coolercontrol, modules-load.d, pipewire)
- `files/system/usr/`: User-space files (currently empty)
- `files/rpm-ostree/`: Repository files (vscode.repo)
- `files/scripts/`: Build-time scripts (example.sh demonstrates pattern)
- `modules/`: Custom BlueBuild modules (currently empty)

## Common Commands

### Building Locally
```bash
# Build the image using BlueBuild CLI
bluebuild build recipes/recipe.yml
```

### Testing the Image
```bash
# Rebase to unsigned image (for testing)
rpm-ostree rebase ostree-unverified-registry:ghcr.io/stefan1495/cleav-os:latest

# Rebase to signed image (production)
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/stefan1495/cleav-os:latest
```

### Verifying the Image
```bash
# Verify image signature
cosign verify --key cosign.pub ghcr.io/stefan1495/cleav-os
```

## Development Workflow

### Adding Packages
1. Edit `recipes/common-modules.yml`
2. Add packages under the appropriate module type:
   - Use `rpm-ostree` for system packages
   - Use `bling` for supported applications
   - Use `default-flatpaks` for flatpak applications

### Adding Custom Repositories
Add repos in the `rpm-ostree` module's `repos:` section. Use `%OS_VERSION%` placeholder for Fedora version.

### Adding System Files
Place files in `files/system/` matching the target filesystem structure (e.g., `files/system/etc/` maps to `/etc/`)

### Adding Build Scripts
1. Create executable shell scripts in `files/scripts/`
2. Always include `set -oue pipefail` for proper error handling
3. Reference scripts in recipe modules using the `script` module type

## Important Notes

- The image rebuilds daily at 06:00 UTC to pick up upstream updates
- Changes to `*.md` files do not trigger rebuilds
- The build uses `maximize_build_space: true` for larger images
- Image is published to `ghcr.io/stefan1495/cleav-os`
- The `latest` tag always points to the latest build of the configured Fedora version
