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
- All commits and PR titles must follow Conventional Commits: `type(scope): subject` (e.g., `feat(network): add k8s-gateway`, `fix(agixt): expose web port 3437`).
- PRs must include: clear description, impacted paths (e.g., `kubernetes/apps/...`), rationale; screenshots/logs when relevant; linked issues; green CI; passing local validation.

## Security & Configuration Tips
- Keep `age.key`, kubeconfig, and Talos creds local; do not commit secrets.
- Required CLIs are managed by `mise` (`task`, `kubectl`, `kustomize`, `sops`, `yq`, `flux`, `talhelper`).
- Prefer additive Kustomize patches over in‑place edits to ease diffs.

## Per‑app Helm layout standard

Use this structure for every new app. Keep chart source references as they are today (do not change charts). Only move inline values into `app/helm/values.yaml` and wire them via `valuesFrom`.

```text
kubernetes/apps/<namespace>/<app>/
  app/
    helm/
      values.yaml
    helmrelease.yaml
    kustomization.yaml
    kustomizeconfig.yaml
  ks.yaml
```

- `app/helm/values.yaml`: the only place for chart values (do not use `spec.values` inline)
- `app/helmrelease.yaml`: contains both the repository object and the `HelmRelease` (two YAML docs in one file)
- `app/kustomization.yaml`: generates a `ConfigMap` from `helm/values.yaml` and applies `helmrelease.yaml`
- `app/kustomizeconfig.yaml`: rewrites `HelmRelease.spec.valuesFrom.name` to the hashed `ConfigMap` name
- Anchors: only within a single YAML document; never across `---`
- Schemas: include yaml-language-server schema headers for validation

### Template: `app/helmrelease.yaml`

Centralized chart source (preferred for `app-template`):
```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/fluxcd-community/flux2-schemas/main/helmrelease-helm-v2.json
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: <app>
  namespace: <namespace>
spec:
  interval: 1h
  chartRef:
    kind: OCIRepository
    name: app-template
  install:
    remediation:
      retries: -1
  upgrade:
    cleanupOnFail: true
    remediation:
      retries: 3
  valuesFrom:
    - kind: ConfigMap
      name: <app>-values
      valuesKey: values.yaml
```

Co‑located source (only if the app already follows this pattern):
```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/fluxcd-community/flux2-schemas/main/ocirepository-source-v1.json
---
apiVersion: source.toolkit.fluxcd.io/v1
kind: OCIRepository
metadata:
  name: <app>-repo
  namespace: <namespace>
spec:
  interval: 5m
  ref:
    tag: <chart-version>
  url: oci://example.com/org/chart
---
# yaml-language-server: $schema=https://raw.githubusercontent.com/fluxcd-community/flux2-schemas/main/helmrelease-helm-v2.json
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: <app>
  namespace: <namespace>
spec:
  interval: 1h
  chartRef:
    kind: OCIRepository
    name: <app>-repo
  valuesFrom:
    - kind: ConfigMap
      name: <app>-values
      valuesKey: values.yaml
```

### Template: `app/kustomization.yaml`
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - helmrelease.yaml

configMapGenerator:
  - name: <app>-values
    files:
      - values.yaml=helm/values.yaml

generatorOptions:
  disableNameSuffixHash: false

configurations:
  - kustomizeconfig.yaml
```

### Template: `app/kustomizeconfig.yaml`
```yaml
nameReference:
  - kind: ConfigMap
    version: v1
    fieldSpecs:
      - group: helm.toolkit.fluxcd.io
        version: v2
        kind: HelmRelease
        path: spec/valuesFrom/name
```

### Template: `app/helm/values.yaml`
```yaml
# Place all chart values here; referenced via valuesFrom
replicaCount: 1
resources:
  requests:
    cpu: 50m
    memory: 64Mi
  limits:
    cpu: 200m
    memory: 256Mi
```

### Quick checklist
- Create `kubernetes/apps/<namespace>/<app>/app/`
- Add `helm/values.yaml` and keep all values there
- Keep existing chart source untouched:
  - If using centralized `OCIRepository` (e.g., `app-template`), continue referencing it via `chartRef`.
  - If the app already co‑locates a repository object, keep it co‑located.
- Reference values via `valuesFrom` `ConfigMap` named `<app>-values`
- Include schema headers on both YAML documents
- Use anchors only within a single YAML document
- Include `kustomizeconfig.yaml` so Kustomize rewrites `spec/valuesFrom/name` to the hashed `ConfigMap` name when `disableNameSuffixHash: false`.

### Important
- Do not change which chart a service uses as part of this refactor.
- If an app uses the `app-template` chart via the centralized `OCIRepository` named `app-template`, keep that reference intact (do not add a local repo object).
- The only change is to move inline Helm values/customizations into `app/helm/values.yaml` and reference them via `valuesFrom`.

