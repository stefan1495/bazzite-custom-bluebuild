ARG SYSTEM_BRIDGE_VERSION=5.28.3

FROM archlinux:base-20260419.0.517065@sha256:5ba8bb318666baef4d33afefc0e65db80f38b23503cb8e7b150d315cc2d4d5da AS system-bridge-source
ARG SYSTEM_BRIDGE_VERSION
COPY build_files/helpers/build-system-bridge-source.sh /usr/local/bin/build-system-bridge-source
WORKDIR /src
RUN bash /usr/local/bin/build-system-bridge-source "${SYSTEM_BRIDGE_VERSION}"

FROM ghcr.io/ublue-os/bazzite-nvidia-open:stable AS system-bridge-rpm
ARG SYSTEM_BRIDGE_VERSION
COPY --from=system-bridge-source /src /src
COPY build_files/helpers/package-system-bridge-rpm.sh /usr/local/bin/package-system-bridge-rpm
WORKDIR /src
RUN bash /usr/local/bin/package-system-bridge-rpm "${SYSTEM_BRIDGE_VERSION}"

# Build-time context, excluded from the final image.
FROM scratch AS ctx
COPY build_files /
COPY system_files /system_files
COPY cosign.pub /cosign.pub

FROM ghcr.io/ublue-os/bazzite-nvidia-open:stable

# RPMs that write under /opt need a real directory, not Bazzite's /var/opt symlink.
RUN rm /opt && mkdir /opt

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=bind,from=system-bridge-rpm,source=/out/system-bridge.rpm,target=/run/system-bridge.rpm \
    --mount=type=cache,dst=/var/cache \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

RUN bootc container lint
