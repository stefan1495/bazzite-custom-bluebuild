#!/usr/bin/env bash
set -oue pipefail

# Install required tools if not present
if ! command -v checkmodule &>/dev/null; then
    dnf install -y checkpolicy policycoreutils-python-utils
fi

# Create and enter a temp directory
TMPDIR="$(mktemp -d)"
cd "$TMPDIR"

# Write the SELinux type enforcement policy
cat > sendspin.te << 'EOF'
module sendspin 1.0;

require {
    type initrc_t;
    type ldconfig_t;
    class process2 nnp_transition;
}

#============= initrc_t ==============
allow initrc_t ldconfig_t:process2 nnp_transition;
EOF

# Compile, package, and install the policy module
checkmodule -M -m -o sendspin.mod sendspin.te
semodule_package -o sendspin.pp -m sendspin.mod
semodule -X 300 -i sendspin.pp

# Cleanup
rm -rf "$TMPDIR"

echo 'SELinux policy module sendspin installed successfully.'
