# Resume Assistant (Kubernetes App)

Concise documentation for deploying the Resume Assistant service via Flux and the bjw-s app-template chart.

## Quick links

- Namespace: `resume-assistant`
- Flux Kustomization: `kubernetes/apps/resume-assistant/backend/ks.yaml`
- HelmRelease: `kubernetes/apps/resume-assistant/backend/app/helmrelease.yaml`
- Chart values: `kubernetes/apps/resume-assistant/backend/app/helm/values.yaml`
- Infisical secret: `kubernetes/apps/resume-assistant/secrets/resume-assistant-secrets.yaml`

## Overview

This deployment exposes the [`ghcr.io/yamshy/resume-assistant`](https://github.com/yamshy/resume-assistant) container (tag `1.9.1`)
behind Flux. Runtime configuration is supplied exclusively through the rendered ConfigMap that feeds the HelmRelease.
The pod now starts both the LangGraph API and Temporal worker sidecars from the same
container so Temporal workflows stay co-located with the HTTP surface.

## Workload

- Chart: `app-template` via the shared `app-template` OCIRepository
- Controller: single `resume-assistant` deployment managed by the chart using the `Recreate` rollout
  strategy. This is required because the workload keeps a ReadWriteOnce Longhorn PVC mounted at `/data`;
  parallel pods would otherwise hit multi-attach errors during upgrades.
- Resources (from values): requests `100m` CPU / `256Mi`, limits `500m` CPU / `512Mi`
- Persistence: 5Gi `longhorn`-backed PVC mounted at `/data` for the knowledge store file
- Startup command launches the LangGraph server and `python -m app.temporal.worker`
  so the Temporal worker shares the same pod as the API. `TEMPORAL_HOST`
  resolves to the in-namespace Temporal frontend service.

## Networking and exposure

- Service: ClusterIP on port `80` targeting the container's `8000`
- Access is cluster-internal. Reach the UI from outside the cluster with a temporary port-forward, for example:

  ```sh
  kubectl -n resume-assistant port-forward svc/resume-assistant 8080:80
  # Then open http://localhost:8080
  ```

## Secrets & substitutions

- Application API access comes from the Infisical-managed secret `resume-assistant-env`
  (`OPENAI_API_KEY` key).

## Dependencies

- Flux (Helm & Kustomize controllers)
- Infisical Secrets Operator (manages `resume-assistant-env`)
- Temporal HelmRelease (deployed via `kubernetes/apps/resume-assistant/temporal`)

## Operations

- Trigger a reconcile:

  ```sh
  flux reconcile kustomization resume-assistant -n resume-assistant
  ```

- Inspect workloads:

  ```sh
  kubectl -n resume-assistant get helmrelease,deploy,svc,ing,pod
  ```

- Edit chart values and re-run validation:

  ```sh
  $EDITOR kubernetes/apps/resume-assistant/backend/app/helm/values.yaml
  bash scripts/validate.sh
  ```

## File map

- Flux Kustomization: `kubernetes/apps/resume-assistant/backend/ks.yaml`
- App manifests: `kubernetes/apps/resume-assistant/backend/app/`
  - `helmrelease.yaml` – HelmRelease definition referencing the shared `app-template` chart
  - `helm/values.yaml` – chart values rendered via ConfigMapGenerator
  - `helm/kustomizeconfig.yaml` – rewrites `valuesFrom` ConfigMap names
  - `kustomization.yaml` – wires the HelmRelease, values ConfigMap, and Infisical secret
  - `secrets.infisical.yaml` – InfisicalSecret fetching `OPENAI_API_KEY`
