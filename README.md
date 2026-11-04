# CleavOS

CleavOS is a custom Bazzite NVIDIA Open image built with the Containerfile-based [`ublue-os/image-template`](https://github.com/ublue-os/image-template) structure. The template revision used for this migration is `72e9b7c2fc9bf5a1ba642f99b6d12d7e70de96d9`.

The image is published as `ghcr.io/stefan1495/cleav-os:latest`. Builds run daily at 06:17 UTC and on pushes to `main`; pull requests build and validate without publishing production tags. Manual workflow dispatch is also available.

## Installation

> [!WARNING]
> Rebasing an operating system image can make a system unbootable. Test on a disposable system first and keep a rollback path.

Rebase to the unsigned image to install its signing policy, then reboot:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/stefan1495/cleav-os:latest
systemctl reboot
```

After reboot, rebase to the signed image and reboot again:

```bash
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/stefan1495/cleav-os:latest
systemctl reboot
```

## Image contents

The image runs numbered build steps under [`build_files/scripts/`](build_files/scripts/), carries system configuration from [`system_files/`](system_files/), and installs these system Flatpaks after boot when networking is available:

- `one.ablaze.floorp`
- `io.github.trigg.discover_overlay`
- `com.orcaslicer.OrcaSlicer`
- `me.amankhanna.opendeck`

Proton Pass, Orca IDE, and System Bridge RPM versions are managed by Renovate in `build_files/scripts/30-install-packages.sh`, using the custom managers in [`renovate.json`](renovate.json).

## Verification

Images are signed with Sigstore Cosign. Verify a published image using the public key in this repository:

```bash
cosign verify --key cosign.pub ghcr.io/stefan1495/cleav-os
```
