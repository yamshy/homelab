# Resume Assistant (Kubernetes App)

Concise documentation for deploying the Resume Assistant service via Flux and the bjw-s app-template chart.

## Quick links

- Namespace: `ai`
- Flux Kustomization: `kubernetes/apps/ai/resume-assistant/ks.yaml`
- HelmRelease: `kubernetes/apps/ai/resume-assistant/app/helmrelease.yaml`
- Chart values: `kubernetes/apps/ai/resume-assistant/app/helm/values.yaml`
- Infisical secret: `kubernetes/apps/ai/resume-assistant/app/secrets.infisical.yaml`

## Overview

This deployment exposes the [`ghcr.io/yamshy/resume-assistant`](https://github.com/yamshy/resume-assistant) container (tag `1.4.4`)
behind Flux. Runtime configuration is supplied exclusively through the rendered ConfigMap that feeds the HelmRelease.

## Workload

- Chart: `app-template` via the shared `app-template` OCIRepository
- Controller: single `resume-assistant` deployment managed by the chart using the `Recreate` rollout
  strategy. This is required because the workload keeps a ReadWriteOnce Longhorn PVC mounted at `/data`;
  parallel pods would otherwise hit multi-attach errors during upgrades.
- Resources (from values): requests `100m` CPU / `256Mi`, limits `500m` CPU / `512Mi`
- Persistence: 5Gi `longhorn`-backed PVC mounted at `/data` for the knowledge store file

## Networking and exposure

- Service: ClusterIP on port `80` targeting the container's `8000`
- Ingress: Tailscale ingress class
  - Host: `resume-assistant.${SECRET_TAILNET}`
  - TLS: secret `resume-assistant-tls`

## Secrets & substitutions

- Application API access comes from the Infisical-managed secret `resume-assistant-env`
  (`OPENAI_API_KEY` key).
- Flux post-build substitution pulls `${SECRET_TAILNET}` from the same Infisical-managed secret so the Tailscale hostname renders correctly.

## Dependencies

- Flux (Helm & Kustomize controllers)
- Infisical Secrets Operator (manages `resume-assistant-env`)
- Tailscale operator for the `tailscale` IngressClass

## Operations

- Trigger a reconcile:

  ```sh
  flux reconcile kustomization resume-assistant -n ai
  ```

- Inspect workloads:

  ```sh
  kubectl -n ai get helmrelease,deploy,svc,ing,pod
  ```

- Edit chart values and re-run validation:

  ```sh
  $EDITOR kubernetes/apps/ai/resume-assistant/app/helm/values.yaml
  bash scripts/validate.sh
  ```

## File map

- Flux Kustomization: `kubernetes/apps/ai/resume-assistant/ks.yaml`
- App manifests: `kubernetes/apps/ai/resume-assistant/app/`
  - `helmrelease.yaml` – HelmRelease definition referencing the shared `app-template` chart
  - `helm/values.yaml` – chart values rendered via ConfigMapGenerator
  - `helm/kustomizeconfig.yaml` – rewrites `valuesFrom` ConfigMap names
  - `kustomization.yaml` – wires the HelmRelease, values ConfigMap, and Infisical secret
  - `secrets.infisical.yaml` – InfisicalSecret fetching `OPENAI_API_KEY`
