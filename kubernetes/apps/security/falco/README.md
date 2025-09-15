# Falco (Kubernetes App)

Concise documentation for deploying Falco via Helm for runtime security detection.

## Quick links

- Namespace: `security`
- Flux Kustomization: `kubernetes/apps/security/falco/ks.yaml`
- HelmRelease: `kubernetes/apps/security/falco/app/helmrelease.yaml`
- Chart values: `kubernetes/apps/security/falco/app/helm/values.yaml`

## Overview

Installs Falco using the upstream Helm chart with the modern eBPF driver. Falcosidekick and its Web UI are enabled and exposed via Tailscale Ingress.

## Workload

- Chart: `falco` 6.2.5 from HelmRepository `falcosecurity`
- Driver: modern_ebpf
- Falcosidekick Web UI:
  - Service: ClusterIP
  - Ingress: class `tailscale`, host `falco-ui`

## Networking and exposure

- Falcosidekick UI available at `https://falco-ui` within the tailnet (Tailscale Ingress terminates TLS).
- Falco itself runs as a DaemonSet and does not expose a user-facing service.

## Image automation

Not applicable.

## Monitoring

Falco can export events to multiple backends via falcosidekick. Enable any additional output integrations as needed in values.

## Dependencies

- Flux (Helm controller)
- Tailscale IngressClass/controller (for falcosidekick UI exposure)
- Linux nodes with eBPF support

## Operations

- Reconcile:

  ```sh
  flux reconcile kustomization falco -n security
  ```

- Inspect:

  ```sh
  kubectl -n security get helmrelease,ds,deploy,svc,ingress,pod
  ```

## File map

- Kustomization (Flux): `kubernetes/apps/security/falco/ks.yaml`
- App manifests: `kubernetes/apps/security/falco/app/`
  - HelmRelease: `helmrelease.yaml`
  - Values: `helm/values.yaml` (+ `helm/kustomizeconfig.yaml`)
  - Kustomization (kustomize): `kustomization.yaml`