#!/usr/bin/env bash
set -Eeuo pipefail

source "$(dirname "${0}")/lib/common.sh"

: "${KUBE_VERSION:=1.33.4}"

check_cli git kustomize kubeconform yq

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "${ROOT_DIR}"

IGNORE_FILE=".kubeconformignore"
# Convert ignore file patterns to a regex like 'crds|templates|charts|testdata|examples'
IGNORE_REGEX=$(sed 's#\*\*/##g; s#/\*\*##g' "${IGNORE_FILE}" | paste -sd '|' -)

mapfile -t OVERLAYS < <(git ls-files | grep -E '/kustomization\.ya?ml$' | grep -Ev "${IGNORE_REGEX}" | xargs -n1 dirname | sort -u)
if [ "${#OVERLAYS[@]}" -eq 0 ]; then
  log error "No kustomize overlays found"
fi

SKIP_KINDS="Kustomization,HelmRelease,GitRepository,OCIRepository,HelmRepository,Bucket,HelmChart,ImageRepository,ImagePolicy,ImageUpdateAutomation"

for overlay in "${OVERLAYS[@]}"; do
  log info "Validate ${overlay}"
  if ! kustomize build "${overlay}" | yq eval 'del(.sops)' - | kubeconform -strict -summary -kubernetes-version "${KUBE_VERSION}" -schema-location default -skip "${SKIP_KINDS}"; then
    log error "Validation failed" "overlay=${overlay}"
  fi
  echo

done

log info "Validated ${#OVERLAYS[@]} overlays"
