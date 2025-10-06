#!/usr/bin/env bash
set -Eeuo pipefail

source "$(dirname "${0}")/lib/common.sh"

: "${KUBE_VERSION:=1.33.4}"
: "${SECRET_DOMAIN:=example.com}"
: "${PORTFOLIO_DOMAIN:=portfolio.example.com}"
export SECRET_DOMAIN PORTFOLIO_DOMAIN

check_cli git kustomize kubeconform envsubst yq

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "${ROOT_DIR}"

# Guidance for contributors/agents
log info "Guideline: Co-locate chart sources with HelmReleases (HelmRepository/OCIRepository) in app/helmrelease.yaml unless a central shared repo already exists."
log info "See AGENTS.md (Helm chart source placement policy) and CONTRIBUTING.md for details."

IGNORE_FILE=".kubeconformignore"

OVERLAYS=($(
  git ls-files \
    | grep -E '/kustomization\.ya?ml$' \
    | xargs -n1 dirname \
    | sort -u \
    | grep -F -v -f <(sed 's#\*\*/##g; s#/\*\*##g' "${IGNORE_FILE}")
))
if [ "${#OVERLAYS[@]}" -eq 0 ]; then
  log error "No kustomize overlays found"
fi

SKIP_KINDS="HelmRepository,Bucket,HelmChart,ImageRepository,ImagePolicy,ImageUpdateAutomation,InfisicalSecret"

for overlay in "${OVERLAYS[@]}"; do
  log info "Validate ${overlay}"
  if ! kustomize build "${overlay}" | envsubst | yq eval 'del(.sops)' - | kubeconform -strict -summary -kubernetes-version "${KUBE_VERSION}" \
    -schema-location default \
    -schema-location "${ROOT_DIR}/schemas/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json" \
    -schema-location "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json" \
    -skip "${SKIP_KINDS}"; then
    log error "Validation failed" "overlay=${overlay}"
  fi
  echo

done

log info "Validated ${#OVERLAYS[@]} overlays"
