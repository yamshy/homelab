# Qdrant (Kubernetes App)

Concise documentation for deploying Qdrant via Flux and Helm.

## Quick links

- Namespace: `ai`
- Flux Kustomization: `kubernetes/apps/ai/qdrant/ks.yaml`
- HelmRelease: `kubernetes/apps/ai/qdrant/app/helmrelease.yaml`
- Chart values: `kubernetes/apps/ai/qdrant/app/helm/values.yaml`
- Optional MCP sidecar HelmRelease: `kubernetes/apps/ai/qdrant/app/helmrelease-mcp.yaml` (depends on `qdrant`)

## Overview

Deploys Qdrant using the upstream qdrant Helm chart. Flux reconciles the HelmRelease; values are provided via a generated ConfigMap.

## Workload

- Chart: `qdrant` version `1.14.0` from HelmRepository `qdrant` (namespace `ai`)
- Image: `qdrant/qdrant` (tag managed by chart/appVersion by default)
- Service: ClusterIP, port 6333
- Persistence: PVC 32Gi, storageClass `longhorn`
- Resources:
  - requests: 500m CPU / 1Gi
  - limits: 2000m CPU / 4Gi

## Networking and exposure

- Ingress: enabled
- Class: `tailscale`
- Host: `qdrant.${SECRET_TAILNET}`
- TLS: secret `qdrant-tls` for `qdrant.${SECRET_TAILNET}`

TLS is terminated by the Tailscale ingress controller.

## Image automation

Not managed via Flux Image Automation for this chart; app container tags follow chart defaults unless overridden.

## Monitoring

ServiceMonitor is disabled in values; enable if the chart supports metrics and you want Prometheus scraping.

## Dependencies

- Flux (Kustomize and Helm controllers)
- Tailscale IngressClass/controller
- Longhorn storage class available
- Optional MCP HelmRelease (`qdrant-mcp`) depends on the main Qdrant release

Substitutions:
- `SECRET_TAILNET` is injected via Flux postBuild from `cluster-secrets`.

## Operations

- Reconcile this app:

  ```sh
  flux reconcile kustomization qdrant -n ai
  ```

- Inspect status and resources:

  ```sh
  kubectl -n ai get kustomization/qdrant
  kubectl -n ai get helmrelease,dply,sts,svc,ing,pod
  ```

- Edit values:

  - Update `kubernetes/apps/ai/qdrant/app/helm/values.yaml`
  - Flux packages them via ConfigMapGenerator as `qdrant-values`

## File map

- Kustomization (Flux): `kubernetes/apps/ai/qdrant/ks.yaml`
- App manifests: `kubernetes/apps/ai/qdrant/app/`
  - HelmRelease: `helmrelease.yaml`
  - Values: `helm/values.yaml` (consumed via ConfigMapGenerator)
  - Kustomize config: `helm/kustomizeconfig.yaml`
  - Optional MCP HelmRelease: `helmrelease-mcp.yaml`
  - Kustomization (kustomize): `kustomization.yaml`