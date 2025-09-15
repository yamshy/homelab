# Longhorn (Kubernetes App)

Concise documentation for deploying Longhorn via Helm.

## Quick links

- Namespace: `storage`
- Flux Kustomization: `kubernetes/apps/storage/longhorn/ks.yaml`
- HelmRelease: `kubernetes/apps/storage/longhorn/app/helmrelease.yaml`
- Node labels (default disk config): `kubernetes/apps/storage/longhorn/app/node-labels.yaml`

## Overview

Installs Longhorn with metrics and ServiceMonitor enabled, non-default storage class behavior, and HA settings tuned for a small cluster.

## Workload

- Chart: `longhorn` 1.9.1 from `https://charts.longhorn.io`
- Default settings:
  - createDefaultDiskLabeledNodes: true
  - defaultReplicaCount: 2
  - defaultDataPath: /var/lib/longhorn
  - offlineReplicaRebuilding: true
  - storageOverProvisioningPercentage: 100
- CSI sidecar replicas: 3 each for attacher, provisioner, resizer, snapshotter
- UI: enabled (ClusterIP), replicas: 2
- Priority classes set for manager and driver

## Networking and exposure

- Longhorn UI is ClusterIP (internal)
- No external exposure defined

## Image automation

Not applicable.

## Monitoring

- Metrics enabled with ServiceMonitor (30s scrape interval)

## Dependencies

- Flux (Helm controller)
- Node labeling applied as in `node-labels.yaml` to create default disks
- Prometheus stack (to scrape ServiceMonitor)

## Operations

- Reconcile:

  ```sh
  flux reconcile kustomization longhorn -n storage
  ```

- Inspect:

  ```sh
  kubectl -n storage get helmrelease,deploy,ds,sts,svc,servicemonitor,pod
  ```

## File map

- Kustomization (Flux): `kubernetes/apps/storage/longhorn/ks.yaml`
- App manifests: `kubernetes/apps/storage/longhorn/app/`
  - HelmRelease: `helmrelease.yaml`
  - Node labels: `node-labels.yaml`
  - Kustomization (kustomize): `kustomization.yaml`