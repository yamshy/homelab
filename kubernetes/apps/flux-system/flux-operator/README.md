# Flux Operator (Kubernetes App)

Concise documentation for deploying the Flux Operator via Helm.

## Quick links

- Namespace: `flux-system`
- Flux Kustomization: `kubernetes/apps/flux-system/flux-operator/ks.yaml`
- HelmRelease: `kubernetes/apps/flux-system/flux-operator/app/helmrelease.yaml`
- Values: `kubernetes/apps/flux-system/flux-operator/app/helm/values.yaml`

## Overview

Installs the Flux Operator using the controlplaneio-fluxcd `flux-operator` Helm chart. This operator manages Flux Instances in the cluster.

## Workload

- Chart: `flux-operator` from OCI `ghcr.io/controlplaneio-fluxcd/charts/flux-operator` tag `0.28.0`
- Typically deployed before any Flux Instance and referenced via `dependsOn`

## Networking and exposure

No user-facing service exposure; the operator runs in-cluster.

## Image automation

Not applicable.

## Monitoring

Metrics exposure depends on chart values; ServiceMonitor can be enabled via values if supported.

## Dependencies

- Flux (Helm controller)

## Operations

- Reconcile:

  ```sh
  flux reconcile kustomization flux-operator -n flux-system
  ```

- Inspect:

  ```sh
  kubectl -n flux-system get helmrelease,deploy,svc,pod
  ```

## File map

- Kustomization (Flux): `kubernetes/apps/flux-system/flux-operator/ks.yaml`
- App manifests: `kubernetes/apps/flux-system/flux-operator/app/`
  - HelmRelease: `helmrelease.yaml`
  - Values: `helm/values.yaml` (+ `helm/kustomizeconfig.yaml` if present)
  - Kustomization (kustomize): `kustomization.yaml`