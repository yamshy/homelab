# Generic Device Plugin (Kubernetes App)

Concise documentation for deploying the Generic Device Plugin to expose /dev/net/tun for Talos + Tailscale.

## Quick links

- Namespace: `kube-system`
- Flux Kustomization: `kubernetes/apps/kube-system/generic-device-plugin/ks.yaml`
- DaemonSet: `kubernetes/apps/kube-system/generic-device-plugin/daemonset.yaml`

## Overview

Deploys the `ghcr.io/squat/generic-device-plugin` as a privileged DaemonSet to advertise the `/dev/net/tun` device to the kubelet for workloads (e.g., Tailscale operator on Talos).

## Workload

- Kind: DaemonSet
- Container image: `ghcr.io/squat/generic-device-plugin:latest`
- Device group:
  - name: `tun`
  - count: 1000
  - path: `/dev/net/tun`
- Priority class: `system-node-critical`
- Tolerations: schedules onto all nodes

## Networking and exposure

Not applicable.

## Image automation

Not applicable.

## Monitoring

Not configured.

## Dependencies

- Talos Linux nodes exposing `/dev/net/tun`
- Flux Kustomization to apply manifests

## Operations

- Reconcile:

  ```sh
  flux reconcile kustomization generic-device-plugin -n kube-system
  ```

- Inspect:

  ```sh
  kubectl -n kube-system get ds/generic-device-plugin pod
  ```

## File map

- Kustomization (Flux): `kubernetes/apps/kube-system/generic-device-plugin/ks.yaml`
- App manifests: `kubernetes/apps/kube-system/generic-device-plugin/daemonset.yaml`