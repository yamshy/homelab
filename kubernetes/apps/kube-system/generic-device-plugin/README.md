# Generic Device Plugin (Kubernetes App)

Concise documentation for deploying the Generic Device Plugin to expose /dev/net/tun for Talos + Tailscale.

## Quick links

- Namespace: `kube-system`
- Flux Kustomization: `kubernetes/apps/kube-system/generic-device-plugin/ks.yaml`
- HelmRelease: `kubernetes/apps/kube-system/generic-device-plugin/app/helmrelease.yaml`
- Helm values: `kubernetes/apps/kube-system/generic-device-plugin/app/helm/values.yaml`

## Overview

Deploys the `generic-device-plugin` Helm chart from the `gabe565` repository to advertise the `/dev/net/tun` device to the kubelet for Talos + Tailscale workloads. The release pins chart version `0.1.3` and uses the upstream `squat/generic-device-plugin` image.

## Workload

- Kind: HelmRelease (installs DaemonSet)
- Chart: `generic-device-plugin` (version `0.1.3`)
- Container image: `squat/generic-device-plugin` (chart default tag)
- Device group:
  - name: `tun`
  - count: 1000
  - path: `/dev/net/tun`
- Tolerations: schedules onto all nodes (managed by chart)

## Networking and exposure

Not applicable.

## Image automation

Not applicable.

## Monitoring

Not configured.

## Dependencies

- Talos Linux nodes exposing `/dev/net/tun`
- Flux Kustomization to apply manifests
- HelmRepository `gabe565` in the `flux-system` namespace

## Operations

- Reconcile:

  ```sh
  flux reconcile kustomization generic-device-plugin -n kube-system
  ```

- Inspect:

  ```sh
  kubectl -n kube-system get daemonset generic-device-plugin
  ```

## File map

- Kustomization (Flux): `kubernetes/apps/kube-system/generic-device-plugin/ks.yaml`
- HelmRelease: `kubernetes/apps/kube-system/generic-device-plugin/app/helmrelease.yaml`
- Helm values: `kubernetes/apps/kube-system/generic-device-plugin/app/helm/values.yaml`
