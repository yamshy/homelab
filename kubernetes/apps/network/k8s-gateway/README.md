# k8s-gateway (Kubernetes App)

Concise documentation for running the k8s-gateway CoreDNS-based DNS front for the cluster.

## Quick links

- Namespace: `network`
- Flux Kustomization: `kubernetes/apps/network/k8s-gateway/ks.yaml`
- HelmRelease: `kubernetes/apps/network/k8s-gateway/app/helmrelease.yaml`

## Overview

Deploys `k8s-gateway` to resolve DNS for `${SECRET_DOMAIN}` to in-cluster services and HTTPRoutes. Exposes UDP/TCP 53 via a LoadBalancer with a fixed IP.

## Workload

- Chart: `k8s-gateway` from OCI `ghcr.io/k8s-gateway/charts/k8s-gateway` tag `3.2.7`
- Domain: `${SECRET_DOMAIN}`
- TTL: 1
- Service: LoadBalancer on port 53 with annotation `lbipam.cilium.io/ips: "192.168.121.11"`

## Networking and exposure

- Type: LoadBalancer (Cilium LBIPAM provides the address)
- Upstreams: watches HTTPRoute and Service resources (values.watchedResources)

## Image automation

Not applicable.

## Monitoring

If needed, enable metrics via chart values.

## Dependencies

- Flux (Helm controller)
- Cilium LB IPAM for assigning the advertised IP

## Operations

- Reconcile:

  ```sh
  flux reconcile kustomization k8s-gateway -n network
  ```

- Inspect:

  ```sh
  kubectl -n network get helmrelease,svc,pod
  ```

## File map

- Kustomization (Flux): `kubernetes/apps/network/k8s-gateway/ks.yaml`
- App manifests: `kubernetes/apps/network/k8s-gateway/app/helmrelease.yaml`