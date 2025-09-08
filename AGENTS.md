# Repository Guidelines

## Project Structure & Module Organization
- `kubernetes/` — GitOps manifests
  - `apps/<namespace>/<app>/` — app units. Example: `kubernetes/apps/default/echo/{ks.yaml,app/helmrelease.yaml}`
  - `components/` — shared Kustomize pieces (e.g., common config, SOPS)
  - `flux/` — Flux `Kustomization` and sources for cluster bootstrap
- `talos/` — Talos configs (`talconfig.yaml`, `talsecret.sops.yaml`, `clusterconfig/`)
- `scripts/` — utilities (`bootstrap-apps.sh`, `validate.sh`)
- `schemas/` — vendored CRD schemas for kubeconform
- `.taskfiles/` — namespaced Taskfile tasks; top‑level `Taskfile.yaml` aggregates

## Build, Test, and Development Commands
- Setup tools (mise):
  - `mise trust && mise install` — install pinned CLIs; sets `KUBECONFIG`, `TALOSCONFIG`, `SOPS_AGE_KEY_FILE` via `.mise.toml`.
- Cluster lifecycle (task):
  - `task bootstrap:talos` — generate/apply Talos and bootstrap cluster
  - `task bootstrap:apps` — apply namespaces, SOPS secrets, CRDs, then Helmfile sync
  - `task reconcile` — force Flux sync of the repo
- Validate manifests locally:
  - `bash scripts/validate.sh` — kustomize + kubeconform (strict) across overlays

## Coding Style & Naming Conventions
- Indentation via `.editorconfig`:
  - YAML/JSON: 2 spaces; Shell: 4; Markdown: 4; LF line endings
- Kubernetes structure:
  - Use `ks.yaml` for Flux Kustomization per app; `app/kustomization.yaml` for inner Kustomize
  - File/dir names lower‑kebab (e.g., `cloudflare-tunnel`, `k8s-gateway`)
- Secrets: commit only `*.sops.yaml`; never plaintext. SOPS config in `.sops.yaml`.

## Testing Guidelines
- Local: run `bash scripts/validate.sh` before any PR; ensure zero kubeconform errors.
- CI: PRs trigger kubeconform (strict) and flux‑local diff/tests. Fix all reported diffs/violations.
- Optional sanity: `kustomize build <overlay> | yq e 'del(.sops)' -` to inspect rendered YAML.

## Commit & Pull Request Guidelines
- Conventional Commits: `type(scope): subject`. Examples:
  - `feat(network): add k8s-gateway`
  - `fix(agixt): expose web port 3437`
  - `chore(config): migrate renovate config`
- PRs must include:
  - Clear description, impacted paths (e.g., `kubernetes/apps/...`), and rationale
  - Screenshots/logs when relevant; link issues
  - Green CI and passing local validation

## Security & Configuration Tips
- Keep `age.key`, `kubeconfig`, and Talos creds local; do not commit secrets.
- Required CLIs are managed by mise (`task`/`kubectl`/`kustomize`/`sops`/`yq`/`flux`/`talhelper`).
- For app changes, prefer additive Kustomize patches over in‑place edits to ease diffs.
