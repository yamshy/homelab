# Resume Assistant UI (Kubernetes App)

Concise documentation for deploying the Resume Assistant UI via Flux using the bjw-s app-template chart.

## Quick links

- Namespace: `resume-assistant`
- Flux Kustomization: `kubernetes/apps/resume-assistant/frontend/ks.yaml`
- HelmRelease: `kubernetes/apps/resume-assistant/frontend/app/helmrelease.yaml`
- Chart values: `kubernetes/apps/resume-assistant/frontend/app/helm/values.yaml`
- Image automation: `kubernetes/apps/resume-assistant/frontend/app/{imagerepository,imagepolicy}.yaml`

## Overview

This deployment serves the [`ghcr.io/yamshy/resume-assistant-ui`](https://github.com/yamshy/resume-assistant-ui/resume-assistant-ui) container, which hosts the Svelte-based web UI for the Resume Assistant backend. Runtime configuration is rendered through a ConfigMap that feeds the HelmRelease just like the API service.

## Workload

- Chart: `app-template` via the shared `app-template` OCIRepository
- Controller: single `resume-assistant-ui` deployment managed by the chart with the default rolling update strategy
- Resources (from values): requests `50m` CPU / `64Mi`, limits `200m` CPU / `256Mi`
- Persistence: ephemeral `emptyDir` mounted at `/var/cache/nginx` for Nginx temp files

## Networking and exposure

- Service: ClusterIP on port `80` targeting the container's Nginx listener
- Ingress: Tailscale IngressClass serves the UI at `https://resume-assistant-ui.${SECRET_TAILNET}`
  - API calls are directed at `https://resume-assistant.${SECRET_TAILNET}` by default; adjust the secret-substituted value if the backend is exposed differently.

## Dependencies

- Flux (Helm & Kustomize controllers)
- Infisical Secrets Operator (supplies `${SECRET_TAILNET}` via the shared `resume-assistant-env` secret)
- Tailscale operator (IngressClass `tailscale`)

## Operations

- Trigger a reconcile:

  ```sh
  flux reconcile kustomization resume-assistant-ui -n resume-assistant
  ```

- Inspect workloads:

  ```sh
  kubectl -n resume-assistant get helmrelease,deploy,svc,ing,pod
  ```

- Edit chart values and re-run validation:

  ```sh
  $EDITOR kubernetes/apps/resume-assistant/frontend/app/helm/values.yaml
  bash scripts/validate.sh
  ```

## File map

- Flux Kustomization: `kubernetes/apps/resume-assistant/frontend/ks.yaml`
- App manifests: `kubernetes/apps/resume-assistant/frontend/app/`
  - `helmrelease.yaml` – HelmRelease definition referencing the shared `app-template` chart
  - `helm/values.yaml` – chart values rendered via ConfigMapGenerator
  - `helm/kustomizeconfig.yaml` – rewrites `valuesFrom` ConfigMap names
  - `kustomization.yaml` – wires the HelmRelease, values ConfigMap, and image automation
  - `imagerepository.yaml` / `imagepolicy.yaml` – Flux image automation resources tracking `1.x` tags
