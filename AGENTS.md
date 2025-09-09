# Repository Guidelines

## Project Structure & Module Organization
- `kubernetes/` — GitOps manifests
  - `apps/<namespace>/<app>/` — app units (e.g., `kubernetes/apps/default/echo/{ks.yaml,app/helmrelease.yaml}`)
  - `components/` — shared Kustomize bits (common config, SOPS)
  - `flux/` — Flux sources and `Kustomization` for bootstrap
- `talos/` — Talos cluster config (`talconfig.yaml`, `talsecret.sops.yaml`, `clusterconfig/`)
- `scripts/` — utilities (`bootstrap-apps.sh`, `validate.sh`)
- `schemas/` — vendored CRD schemas for kubeconform
- `.taskfiles/` — namespaced Taskfile tasks; top‑level `Taskfile.yaml` aggregates

## Build, Test, and Development Commands
- Setup tools: `mise trust && mise install` (installs pinned CLIs; sets `KUBECONFIG`, `TALOSCONFIG`, `SOPS_AGE_KEY_FILE`).
- Cluster lifecycle:
  - `task bootstrap:talos` — generate/apply Talos and bootstrap cluster
  - `task bootstrap:apps` — apply namespaces, SOPS secrets, CRDs, then Helmfile sync
  - `task reconcile` — force Flux to sync this repo
- Validate manifests locally: `bash scripts/validate.sh` (kustomize build + strict kubeconform across overlays).

## Coding Style & Naming Conventions
- Indentation via `.editorconfig`: YAML/JSON 2 spaces; Shell 4; Markdown 4; LF line endings.
- Kubernetes layout: use `ks.yaml` per app for Flux; `app/kustomization.yaml` for inner Kustomize.
- Names: lower‑kebab for files/dirs (e.g., `cloudflare-tunnel`, `k8s-gateway`).
- Secrets: commit only `*.sops.yaml`; never plaintext. SOPS config in `.sops.yaml`.

## Testing Guidelines
- Local: run `bash scripts/validate.sh`; ensure zero kubeconform errors.
- Optional sanity: `kustomize build <overlay> | yq e 'del(.sops)' -` to inspect rendered YAML.
- CI: PRs run strict kubeconform and flux‑local diff/tests; fix all diffs/violations.

## Commit & Pull Request Guidelines
- Conventional Commits: `type(scope): subject` (e.g., `feat(network): add k8s-gateway`, `fix(agixt): expose web port 3437`).
- PRs must include: clear description, impacted paths (e.g., `kubernetes/apps/...`), rationale; screenshots/logs when relevant; linked issues; green CI; passing local validation.

## Security & Configuration Tips
- Keep `age.key`, kubeconfig, and Talos creds local; do not commit secrets.
- Required CLIs are managed by `mise` (`task`, `kubectl`, `kustomize`, `sops`, `yq`, `flux`, `talhelper`).
- Prefer additive Kustomize patches over in‑place edits to ease diffs.

