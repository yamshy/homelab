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

## Namespace-Level Secrets Pattern

This repository implements an **enterprise-grade namespace-level secrets architecture** that solves bootstrap dependency issues and enforces the principle of least privilege. Use this pattern for any namespace with multiple applications requiring different secrets.

### Pattern Structure

```
kubernetes/apps/<namespace>/
├── secrets/                           # 🆕 Centralized namespace secrets
│   ├── ks.yaml                       # Secrets Kustomization (deployed first)
│   ├── kustomization.yaml            # Manages all namespace secrets
│   ├── <app1>-secrets.yaml           # App-specific InfisicalSecret
│   └── <app2>-secrets.yaml           # App-specific InfisicalSecret
├── <app1>/
│   └── ks.yaml                      # Depends on 'secrets' Kustomization
├── <app2>/
│   └── ks.yaml                      # Depends on 'secrets' Kustomization
└── kustomization.yaml               # Includes secrets first, then apps
```

### Implementation Steps

1. **Create secrets directory structure:**
   ```bash
   mkdir kubernetes/apps/<namespace>/secrets/
   ```

2. **Create secrets Kustomization (`secrets/ks.yaml`):**
   ```yaml
   ---
   apiVersion: kustomize.toolkit.fluxcd.io/v1
   kind: Kustomization
   metadata:
     name: secrets
     namespace: <namespace>
   spec:
     dependsOn:
       - name: infisical-secrets-operator
         namespace: infisical-system
     interval: 1h
     path: ./kubernetes/apps/<namespace>/secrets
     wait: true  # Wait for secrets to be ready
   ```

3. **Create app-specific InfisicalSecrets with scoped templates:**
   ```yaml
   # secrets/<app>-secrets.yaml
   apiVersion: secrets.infisical.com/v1alpha1
   kind: InfisicalSecret
   metadata:
     name: <app>-env
   spec:
     managedSecretReference:
       secretName: "<app>-env"
       template:
         includeAllSecrets: false  # Enable scoping
         data:
           # Only include secrets this app actually needs
           APP_SPECIFIC_KEY: "{{ .APP_SPECIFIC_KEY.Value }}"
           SECRET_TAILNET: "{{ .SECRET_TAILNET.Value }}"  # Common secrets
   ```

4. **Update app Kustomizations to depend on secrets:**
   ```yaml
   # <app>/ks.yaml
   spec:
     dependsOn:
       - name: secrets
         namespace: <namespace>
   ```

5. **Update namespace kustomization.yaml:**
   ```yaml
   resources:
     - ./secrets/ks.yaml        # Deploy secrets first
     - ./<app1>/ks.yaml         # Then apps
     - ./<app2>/ks.yaml
   ```

### Key Benefits

- **🚫 No Bootstrap Issues**: Eliminates chicken-and-egg dependency cycles
- **🔒 Principle of Least Privilege**: Apps only get secrets they actually use
- **📈 Scalable**: Easy to add new apps without modifying existing secrets
- **🧹 Single Source of Truth**: All namespace secrets managed in one place
- **🛡️ Security**: Dramatic reduction in secret exposure per app (87% in AI namespace)
- **🔄 Self-Healing**: Flux handles dependency ordering automatically

### Important Notes

- **Orphan Policy**: If using `creationPolicy: "Orphan"`, delete existing secrets after template changes to force recreation
- **Template Syntax**: Use `{{ .SECRET_NAME.Value }}` for Infisical Go templates
- **Common Secrets**: Include shared secrets like `SECRET_TAILNET` in all app templates
- **Wait Policy**: Use `wait: true` on secrets Kustomization to ensure readiness before apps deploy

### Example: AI Namespace Implementation

This pattern is successfully implemented in `kubernetes/apps/ai/` with:
- **Resume Assistant**: Gets only `OPENAI_API_KEY` + `SECRET_TAILNET` (2/15 secrets)
- **Dify**: Gets only `DIFY_SECRET_KEY` + `SECRET_TAILNET` (2/15 secrets)
- **87% reduction** in secret exposure per app compared to `includeAllSecrets: true`
- **Zero bootstrap issues** - secrets always ready before apps deploy

## Per‑app Helm layout standard

Use this structure for every new app. Keep chart source references as they are today (do not change charts). Only move inline values into `app/helm/values.yaml` and wire them via `valuesFrom`. Place the Kustomize nameReference file under `app/helm/` and reference it from `app/kustomization.yaml`.

```text
kubernetes/apps/<namespace>/<app>/
  app/
    helm/
      values.yaml
      kustomizeconfig.yaml
    helmrelease.yaml
    kustomization.yaml
  ks.yaml
```

- `app/helm/values.yaml`: the only place for chart values (do not use `spec.values` inline)
- `app/helmrelease.yaml`: contains both the repository object and the `HelmRelease` (two YAML docs in one file)
- `app/kustomization.yaml`: generates a `ConfigMap` from `helm/values.yaml` and applies `helmrelease.yaml`
- `app/kustomizeconfig.yaml`: rewrites `HelmRelease.spec.valuesFrom.name` to the hashed `ConfigMap` name
- Anchors: only within a single YAML document; never across `---`
- Schemas: include yaml-language-server schema headers for validation

### Helm chart source placement policy

- Default: define the chart source object in the same file as the app’s HelmRelease (two YAML docs in `app/helmrelease.yaml`).
  - For HTTP Helm repos, co‑locate a HelmRepository alongside the HelmRelease.
  - For OCI charts, co‑locate an OCIRepository alongside the HelmRelease (unless your app already uses a central OCIRepository).
- Centralized sources: only use centralized repositories if they already exist and are intentionally shared (e.g., the common `app-template` OCIRepository under components).
  - Do not add new repo objects under `kubernetes/flux/meta/repos` unless the repo is truly cluster‑wide and shared across multiple apps.
- Namespace: put co‑located repository objects in the same namespace as the app’s HelmRelease (helps Renovate lookups and keeps ownership clear).
- Values: keep all chart values in `app/helm/values.yaml` and reference via `valuesFrom` in the HelmRelease.
- If you move a repo definition that was previously under `flux/meta`, ensure you also remove any references to it from `kubernetes/flux/meta/repos/kustomization.yaml` to keep `flux-local` happy.

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
      - values.yaml=./helm/values.yaml

generatorOptions:
  disableNameSuffixHash: false

configurations:
  - ./helm/kustomizeconfig.yaml
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

