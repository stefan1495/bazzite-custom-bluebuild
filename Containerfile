# Build-time context, excluded from the final image.
FROM scratch AS ctx
COPY build_files /
COPY system_files /system_files
COPY cosign.pub /cosign.pub

FROM ghcr.io/ublue-os/bazzite-nvidia-open:stable

# RPMs that write under /opt need a real directory, not Bazzite's /var/opt symlink.
RUN rm /opt && mkdir /opt

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

RUN bootc container lint
