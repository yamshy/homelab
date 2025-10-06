# Cilium (Kubernetes App)

Concise documentation for deploying Cilium CNI with Gateway API and monitoring enabled.

## Quick links

- Namespace: `kube-system`
- Flux Kustomization: `kubernetes/apps/kube-system/cilium/ks.yaml`
- HelmRelease: `kubernetes/apps/kube-system/cilium/app/helmrelease.yaml`
- Chart values: `kubernetes/apps/kube-system/cilium/app/helm/values.yaml`
- Gateways: `kubernetes/apps/kube-system/cilium/gateway/{external.yaml,internal.yaml,certificate.yaml}`

## Overview

Installs Cilium with kube-proxy replacement, Gateway API support, ServiceMonitor, and Hubble disabled. Also provisions two Gateways (external and internal) using the Cilium GatewayClass.

## Workload

- Chart: `cilium` 1.18.1 from `https://helm.cilium.io`
- Key values:
  - kubeProxyReplacement: true
  - gatewayAPI: enabled
  - prometheus + ServiceMonitor: enabled
  - operator replicas: 1
  - L2 announcements: enabled
  - IPv4 native routing CIDR: 10.42.0.0/16

## Networking and exposure

- Gateways:
  - external: IP 192.168.121.13
  - internal: IP 192.168.121.12
- TLS certificates referenced via Secret `${SECRET_DOMAIN_SLUG}-production-tls` for HTTPS listeners.
- Routes from namespaces are controlled via allowedRoutes in the Gateway listeners.
- ExternalDNS annotations set hostnames for external and internal gateway addresses.

## Image automation

Not applicable.

## Monitoring

- Prometheus ServiceMonitors are enabled for Cilium and operator components.
- Grafana dashboards enabled via chart values.

## Dependencies

- Flux (Kustomize and Helm controllers)
- Gateway API CRDs (installed by Cilium when enabled)
- ExternalDNS and cert-manager expected for DNS and certificates referenced by Gateways.

Substitutions:
- `${SECRET_DOMAIN}` is injected via Flux postBuild in multiple gateway fields.

## Operations

- Reconcile:

  ```sh
  flux reconcile kustomization cilium -n kube-system
  ```

- Inspect:

  ```sh
  kubectl -n kube-system get helmrelease,ciliumendpoints,ciliumnodes,svc,pod
  kubectl -n kube-system get gateway
  ```

## File map

- Kustomization (Flux): `kubernetes/apps/kube-system/cilium/ks.yaml`
- App manifests: `kubernetes/apps/kube-system/cilium/app/`
  - HelmRelease: `helmrelease.yaml`
  - Values: `helm/values.yaml` (+ `helm/kustomizeconfig.yaml`)
  - Network policies/CRs: `networks.yaml` (if used)
- Gateways: `kubernetes/apps/kube-system/cilium/gateway/`
  - `external.yaml`, `internal.yaml`, `certificate.yaml`, `kustomization.yaml`