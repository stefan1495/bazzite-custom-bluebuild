#!/usr/bin/env bash
set -euo pipefail

version="${1:?usage: package-system-bridge-rpm.sh VERSION}"
export HOME=/tmp/system-bridge-build-home
export XDG_CONFIG_HOME="${HOME}/.config"
mkdir -p "${XDG_CONFIG_HOME}"

dnf5 install --assumeyes rpm-build
dnf5 clean all
VERSION="${version}" .scripts/linux/create-rpm.sh
rpm_file="$(find dist -maxdepth 1 -type f -name "system-bridge-${version}-1.*.rpm" -print -quit)"
test -n "${rpm_file}"
test "$(rpm -qp --qf '%{VERSION}-%{RELEASE}' "${rpm_file}")" = "${version}-1"

package_size="$(rpm -qp --qf '%{SIZE}' "${rpm_file}")"
[[ "${package_size}" =~ ^[1-9][0-9]*$ ]]

file_sizes="$(rpm -qp --qf '[%{FILESIZES}\n]' "${rpm_file}")"
[[ -n "${file_sizes}" ]]
! grep --quiet --invert-match --extended-regexp '^[0-9]+$' <<<"${file_sizes}"
file_count="$(rpm -qp --qf '[%{FILENAMES}\n]' "${rpm_file}" | wc --lines)"
size_count="$(wc --lines <<<"${file_sizes}")"
[[ "${file_count}" -gt 0 && "${file_count}" -eq "${size_count}" ]]

mkdir -p /out
cp "${rpm_file}" /out/system-bridge.rpm
