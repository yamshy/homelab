# Spegel (Kubernetes App)

Concise documentation for deploying Spegel (registry mirror/p2p distribution) via Helm.

## Quick links

- Namespace: `kube-system`
- Flux Kustomization: `kubernetes/apps/kube-system/spegel/ks.yaml`
- HelmRelease: `kubernetes/apps/kube-system/spegel/app/helmrelease.yaml`
- Values: `kubernetes/apps/kube-system/spegel/app/helm/values.yaml`

## Overview

Installs Spegel from the upstream OCI chart. Values are provided via a ConfigMap.

## Workload

- Chart: `spegel` from OCI `ghcr.io/spegel-org/helm-charts/spegel` tag `0.3.0`

## Networking and exposure

No public exposure by default.

## Image automation

Not applicable.

## Monitoring

If the chart supports ServiceMonitor/PodMonitor, enable via values.

## Dependencies

- Flux (Helm controller)

## Operations

- Reconcile:

  ```sh
  flux reconcile kustomization spegel -n kube-system
  ```

- Inspect:

  ```sh
  kubectl -n kube-system get helmrelease,deploy,ds,svc,pod
  ```

## File map

- Kustomization (Flux): `kubernetes/apps/kube-system/spegel/ks.yaml`
- App manifests: `kubernetes/apps/kube-system/spegel/app/`
  - HelmRelease: `helmrelease.yaml`
  - Values: `helm/values.yaml` (+ `helm/kustomizeconfig.yaml` if present)
  - Kustomization (kustomize): `kustomization.yaml`