# Reloader (Kubernetes App)

Concise documentation for deploying Stakater Reloader via Helm.

## Quick links

- Namespace: `kube-system`
- Flux Kustomization: `kubernetes/apps/kube-system/reloader/ks.yaml`
- HelmRelease: `kubernetes/apps/kube-system/reloader/app/helmrelease.yaml`

## Overview

Installs Reloader to automatically restart pods when ConfigMaps or Secrets they mount change.

## Workload

- Chart: `reloader` from OCI `ghcr.io/stakater/charts/reloader` tag `2.2.2`
- `fullnameOverride: reloader`
- PodMonitor enabled in values

## Networking and exposure

No user-facing exposure.

## Image automation

Not applicable.

## Monitoring

PodMonitor enabled; ensure your Prometheus stack discovers it.

## Dependencies

- Flux (Helm controller)
- Prometheus stack (to scrape PodMonitor)

## Operations

- Reconcile:

  ```sh
  flux reconcile kustomization reloader -n kube-system
  ```

- Inspect:

  ```sh
  kubectl -n kube-system get helmrelease,deploy,svc,pod,podmonitor
  ```

## File map

- Kustomization (Flux): `kubernetes/apps/kube-system/reloader/ks.yaml`
- App manifests: `kubernetes/apps/kube-system/reloader/app/helmrelease.yaml`