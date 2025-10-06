#!/usr/bin/env bash
set -Eeuo pipefail

source "$(dirname "${0}")/lib/common.sh"

: "${KUBE_VERSION:=1.33.4}"
: "${SECRET_DOMAIN:=example.com}"
: "${PORTFOLIO_DOMAIN:=portfolio.example.com}"
export SECRET_DOMAIN PORTFOLIO_DOMAIN

check_cli git kustomize kubeconform envsubst yq python3

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "${ROOT_DIR}"

# Guidance for contributors/agents
log info "Guideline: Co-locate chart sources with HelmReleases (HelmRepository/OCIRepository) in app/helmrelease.yaml unless a central shared repo already exists."
log info "See AGENTS.md (Helm chart source placement policy) and CONTRIBUTING.md for details."

IGNORE_FILE=".kubeconformignore"

validate_readme_references() {
  log info "Validate README quick links and file maps"
  if python3 <<'PY'
import os
import re
import sys
from pathlib import Path

root_dir = Path(os.environ.get("ROOT_DIR", Path.cwd()))
apps_dir = root_dir / "kubernetes" / "apps"

if not apps_dir.exists():
    sys.exit(0)

pattern = re.compile(r"kubernetes/[A-Za-z0-9._@+\-/]+")
target_headers = {"## quick links", "## file map"}
errors = []

for readme in sorted(apps_dir.rglob("README.md")):
    section = None
    for line_no, raw_line in enumerate(readme.read_text(encoding="utf-8").splitlines(), start=1):
        stripped = raw_line.strip()
        if stripped.lower().startswith("## "):
            header = stripped.lower()
            if header in target_headers:
                section = header
            else:
                section = None
            continue

        if section is None:
            continue

        for match in pattern.finditer(raw_line):
            raw_path = match.group(0)
            normalized = raw_path.rstrip("/")
            candidate = root_dir / normalized
            if not candidate.exists():
                errors.append(
                    f"{readme.relative_to(root_dir)}:{line_no}: referenced path '{raw_path}' does not exist"
                )

if errors:
    print("README reference validation failed:", file=sys.stderr)
    for msg in errors:
        print(f"  - {msg}", file=sys.stderr)
    sys.exit(1)

sys.exit(0)
PY
  then
    log info "Validated README quick links and file maps"
  else
    log error "README quick links and file maps validation failed"
  fi
}

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

validate_readme_references
