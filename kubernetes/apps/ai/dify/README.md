# Dify (Kubernetes App)

Concise documentation for deploying Dify via Flux and Helm.

## Quick links

- Namespace: `ai`
- Flux Kustomization: `kubernetes/apps/ai/dify/ks.yaml`
- HelmRelease: `kubernetes/apps/ai/dify/app/helmrelease.yaml`
- Chart values: `kubernetes/apps/ai/dify/app/helm/values.yaml`
- Secret: `kubernetes/apps/ai/dify/app/secret.sops.yaml`

## Overview

Deploys the Dify application using the upstream dify Helm chart from the `borispolonsky/dify-helm` repo. Reconciliation is handled by Flux; values are provided via a generated ConfigMap.

## Workload

- Chart: `dify` version `0.29.0` from HelmRepository `dify` (namespace `ai`)
- Resources (from values):
  - Dify API: requests 500m CPU / 1Gi; limits 1000m CPU / 2Gi
  - Web: requests 250m CPU / 512Mi; limits 500m CPU / 1Gi
  - Worker: requests 500m CPU / 1Gi; limits 1000m CPU / 2Gi
- Persistence:
  - PostgreSQL: 20Gi, storageClass `longhorn`
  - Redis: 5Gi, storageClass `longhorn`
  - Weaviate: 32Gi, storageClass `longhorn`
  - Dify API: 10Gi, storageClass `longhorn`
  - Worker: 10Gi, storageClass `longhorn`
  - Plugin Daemon: 5Gi, storageClass `longhorn`

## Networking and exposure

- Ingress: enabled
- Class: `tailscale`
- Host: `dify.${SECRET_TAILNET}`
- TLS: secret `dify-tls` for `dify.${SECRET_TAILNET}`

TLS is terminated by the Tailscale ingress controller.

## Image automation

Not currently managed via Flux Image Automation for this chart (version pinning of the chart is done in HelmRelease; app container tags are managed by the chart defaults unless overridden in values).

## Monitoring

No ServiceMonitor configured by default in values. If the chart supports it and you want metrics, enable it in values and ensure Prometheus can scrape the Service.

## Dependencies

- Flux (Kustomize and Helm controllers)
- Tailscale IngressClass/controller
- Longhorn storage class available in the cluster
- SOPS/Age for secret decryption (secret `dify-env`)

Secrets and substitutions:
- `SECRET_TAILNET` is substituted via Flux postBuild from `cluster-secrets`.
- Sensitive values (e.g., `SECRET_KEY`) are stored in `secret.sops.yaml` and must be encrypted with SOPS.

## Operations

- Reconcile this app:

  ```sh
  flux reconcile kustomization dify -n ai
  ```

- Inspect status and resources:

  ```sh
  kubectl -n ai get kustomization/dify
  kubectl -n ai get helmrelease,dply,sts,svc,ing,pod
  ```

- Edit values:

  - Update `kubernetes/apps/ai/dify/app/helm/values.yaml`
  - Flux packages them via ConfigMapGenerator as `dify-values`

- Secrets (encrypt in-place with SOPS):

  ```sh
  sops -e -i kubernetes/apps/ai/dify/app/secret.sops.yaml
  ```

## File map

- Kustomization (Flux): `kubernetes/apps/ai/dify/ks.yaml`
- App manifests: `kubernetes/apps/ai/dify/app/`
  - HelmRelease: `helmrelease.yaml`
  - Values: `helm/values.yaml` (consumed via ConfigMapGenerator)
  - Kustomize config: `helm/kustomizeconfig.yaml`
  - Secret (SOPS): `secret.sops.yaml`
  - Kustomization (kustomize): `kustomization.yaml`