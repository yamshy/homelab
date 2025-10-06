# Synology CSI (Kubernetes App)

Concise documentation for deploying the Synology CSI driver via Helm.

## Quick links

- Namespace: `storage`
- Flux Kustomization: `kubernetes/apps/storage/synology-csi/ks.yaml`
- HelmRelease: `kubernetes/apps/storage/synology-csi/app/helmrelease.yaml`
- StorageClasses: `kubernetes/apps/storage/synology-csi/app/storageclasses.yaml`
- InfisicalSecret (client info): `kubernetes/apps/storage/secrets/synology-csi-infisical.yaml`

## Overview

Installs the Synology CSI driver (Talos-compatible distribution) and defines StorageClasses for both iSCSI and NFS protocols.

## Workload

- Chart: `synology-csi` 0.9.5-pre.4 (CSI v1.2.0) from HelmRepository `synology-csi-chart`
- Client info secret: `client-info-secret` (managed by Infisical)
- StorageClasses (manual CRs):
  - synology-iscsi-delete (default=true, protocol: iscsi)
  - synology-iscsi-retain (default=false, protocol: iscsi)
  - synology-nfs-delete (default=false, protocol: nfs)

## Networking and exposure

No service exposure; CSI driver components run in-cluster.

## Image automation

Not applicable.

## Monitoring

Enable metrics via chart values if supported.

## Dependencies

- Flux (Helm controller)
- Infisical secrets operator (for client-info-secret)
- Synology DSM reachable at 192.168.121.239-240 (as configured in client-info.yml)
- NFS enabled on Synology for NFS protocol support

## Important Notes

### NFS Version Requirements

- **CSI v1.2.0+ required** for NFS protocol support (chart 0.9.5-pre.4+)
- Earlier versions (v1.1.3) only support iSCSI protocol

### client-info.yml Format

CSI v1.2.0 requires strict YAML formatting for client-info.yml:
- The `-` in YAML arrays **must start at column 0** (no indentation)
- Incorrect formatting causes: `yaml: block sequence entries are not allowed in this context`

Example correct format:
```yaml
clients:
- host: "192.168.121.239"
  port: 5001
  https: true
  username: "csi-user"
  password: "..."
```

### Mounting Same PVC Multiple Times

**Known Issue:** Mounting the same NFS PVC multiple times in a pod (as separate volume definitions) causes pods to get stuck in `ContainerCreating` state with `PodReadyToStartContainers: False`.

**Solution:** Use `subPath` with a single volume definition. See media apps for example:

```yaml
persistence:
  media-storage:
    enabled: true
    type: persistentVolumeClaim
    existingClaim: media-storage
    globalMounts:
      - path: /media
        subPath: media
      - path: /downloads
        subPath: downloads
```

Reference: [Kubernetes Issue #127004](https://github.com/kubernetes/kubernetes/issues/127004)

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
