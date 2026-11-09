#!/usr/bin/env bash
set -euo pipefail

install -D -m 0644 /ctx/cosign.pub /etc/pki/containers/cleav-os.pub
install -d /etc/containers/registries.d
jq --arg image 'ghcr.io/stefan1495/cleav-os' \
  --arg key '/etc/pki/containers/cleav-os.pub' \
  '.transports.docker[$image] = [{type: "sigstoreSigned", keyPath: $key, signedIdentity: {type: "matchRepository"}}]' \
  /etc/containers/policy.json > /tmp/cleav-policy.json
install -m 0644 /tmp/cleav-policy.json /etc/containers/policy.json
rm -f /tmp/cleav-policy.json

cat > /etc/containers/registries.d/stefan1495-cleav-os.yaml <<'EOF'
docker:
  ghcr.io/stefan1495/cleav-os:
    use-sigstore-attachments: true
EOF
