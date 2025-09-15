# Metrics Server (Kubernetes App)

Concise documentation for deploying Kubernetes Metrics Server via Helm.

## Quick links

- Namespace: `kube-system`
- Flux Kustomization: `kubernetes/apps/kube-system/metrics-server/ks.yaml`
- HelmRelease: `kubernetes/apps/kube-system/metrics-server/app/helmrelease.yaml`

## Overview

Installs Metrics Server from the upstream Helm chart with Prometheus ServiceMonitor enabled and kubelet TLS options configured.

## Workload

- Chart: `metrics-server` 3.13.0 from `kubernetes-sigs/metrics-server` HelmRepository
- Args:
  - --kubelet-insecure-tls
  - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
  - --kubelet-use-node-status-port
  - --metric-resolution=10s
  - --kubelet-request-timeout=2s

## Networking and exposure

Cluster component; exposes service for metrics scraping.

## Image automation

Not applicable.

## Monitoring

- ServiceMonitor enabled through chart values.

## Dependencies

- Flux (Helm controller)
- Prometheus stack for scraping ServiceMonitor (optional but recommended)

## Operations

- Reconcile:

  ```sh
  flux reconcile kustomization metrics-server -n kube-system
  ```

- Inspect:

  ```sh
  kubectl -n kube-system get helmrelease,deploy,svc,servicemonitor,pod
  ```

## File map

- Kustomization (Flux): `kubernetes/apps/kube-system/metrics-server/ks.yaml`
- App manifests: `kubernetes/apps/kube-system/metrics-server/app/helmrelease.yaml`