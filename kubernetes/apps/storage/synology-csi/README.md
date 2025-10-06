# Synology CSI (Kubernetes App)

Concise documentation for deploying the Synology CSI driver via Helm.

## Quick links

- Namespace: `storage`
- Flux Kustomization: `kubernetes/apps/storage/synology-csi/ks.yaml`
- HelmRelease: `kubernetes/apps/storage/synology-csi/app/helmrelease.yaml`
- StorageClasses: `kubernetes/apps/storage/synology-csi/app/storageclasses.yaml`
- InfisicalSecret (client info): `kubernetes/apps/storage/secrets/synology-csi-infisical.yaml`

## Overview

Installs the Synology CSI driver (Talos-compatible distribution) and defines two StorageClasses for iSCSI with Delete and Retain reclaim policies.

## Workload

- Chart: `synology-csi` 0.9.4 from HelmRepository `synology-csi-chart`
- Client info secret: `client-info-secret` (referenced by chart values)
- StorageClasses (manual CRs):
  - synology-iscsi-delete (default=true)
  - synology-iscsi-retain (default=false)

## Networking and exposure

No service exposure; CSI driver components run in-cluster.

## Image automation

Not applicable.

## Monitoring

Enable metrics via chart values if supported.

## Dependencies

- Flux (Helm controller)
- Synology DSM reachable at 192.168.121.240 (as configured in StorageClasses)
- SOPS/Age for encrypting client info secret

## Operations

- Reconcile:

  ```sh
  flux reconcile kustomization synology-csi -n storage
  ```

- Inspect:

  ```sh
  kubectl -n storage get helmrelease,ds,deploy,svc,pod
  kubectl get storageclass
  ```

## File map

- Kustomization (Flux): `kubernetes/apps/storage/synology-csi/ks.yaml`
- App manifests: `kubernetes/apps/storage/synology-csi/app/`
  - HelmRelease: `helmrelease.yaml`
  - StorageClasses: `storageclasses.yaml`
  - Kustomization (kustomize): `kustomization.yaml`
- Secrets bundle: `kubernetes/apps/storage/secrets/`
  - Synology CSI InfisicalSecret: `synology-csi-infisical.yaml`
