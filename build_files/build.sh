#!/usr/bin/env bash
set -oue pipefail

# Run the numbered build steps in a predictable order. Helpers are deliberately
# separate files so package, signing, OS, and service changes stay easy to review.
for step in /ctx/scripts/[0-9][0-9]-*.sh; do
  [[ -f "$step" ]] || continue
  printf 'Running build step: %s\n' "${step##*/}"
  bash "$step"
done
