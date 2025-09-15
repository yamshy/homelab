# Coder (Kubernetes App)

Concise documentation for deploying Coder via Flux with brokered SSH and Tailscale Ingress.

## Quick links

- Namespace: `workspaces`
- Flux Kustomization: `kubernetes/apps/workspaces/coder/ks.yaml`
- HelmRelease: `kubernetes/apps/workspaces/coder/app/helmrelease.yaml`
- Chart values: `kubernetes/apps/workspaces/coder/app/helm/values.yaml`
- RBAC: `kubernetes/apps/workspaces/coder/app/rbac.yaml`

## Overview

Deploys the Coder control plane using the official Helm chart (Community Edition). Brokered SSH is used; only the web UI is exposed via Tailscale Ingress.

## Workload

- Chart: `coder` 2.25.0 from HelmRepository `coder`
- Service: ClusterIP
- Ingress:
  - className: `tailscale`
  - host: `coder.${SECRET_TAILNET}`
  - TLS secret: `coder-tls`
- Storage:
  - Postgres PVCs use StorageClass `synology-iscsi-delete` (bundled chart DB)

## Networking and exposure

- UI exposed via Tailscale IngressClass at `https://coder.${SECRET_TAILNET}`.
- TLS is terminated by the Tailscale ingress controller.
- No NodePort/LoadBalancer; SSH is brokered through the control plane.

## Image automation

Not applicable.

## Monitoring

Enable chart metrics options if required; none enabled by default.

## Dependencies

- Flux (Helm controller)
- Tailscale Operator providing the `tailscale` IngressClass
- Synology CSI StorageClass `synology-iscsi-delete`
- Coder CLI for developer workflows (optional)

Substitutions:
- `${SECRET_TAILNET}` injected via Flux postBuild from `cluster-secrets`.

## Operations

- Reconcile:

  ```sh
  flux reconcile kustomization coder -n workspaces
  ```

- Inspect:

  ```sh
  kubectl -n workspaces get helmrelease,deploy,svc,ingress,pod
  ```

- Example CLI operations:

  ```sh
  coder list
  coder ssh <workspace-name>
  ```

## File map

- Kustomization (Flux): `kubernetes/apps/workspaces/coder/ks.yaml`
- App manifests: `kubernetes/apps/workspaces/coder/app/`
  - HelmRelease: `helmrelease.yaml`
  - Values: `helm/values.yaml` (+ `helm/kustomizeconfig.yaml`)
  - RBAC: `rbac.yaml`
  - Kustomization (kustomize): `kustomization.yaml`