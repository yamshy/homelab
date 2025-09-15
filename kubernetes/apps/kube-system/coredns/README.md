# CoreDNS (Kubernetes App)

Concise documentation for deploying CoreDNS via Helm.

## Quick links

- Namespace: `kube-system`
- Flux Kustomization: `kubernetes/apps/kube-system/coredns/ks.yaml`
- HelmRelease: `kubernetes/apps/kube-system/coredns/app/helmrelease.yaml`
- Values: `kubernetes/apps/kube-system/coredns/app/helm/values.yaml`

## Overview

Installs CoreDNS from the upstream OCI Helm chart.

## Workload

- Chart: `coredns` from `ghcr.io/coredns/charts/coredns` tag `1.43.3`
- Values provided via ConfigMap `coredns-values` (generated in kustomization)

## Networking and exposure

ClusterDNS component; no user-facing service exposure beyond kube-dns service.

## Image automation

Not applicable; chart version pinned via OCI tag.

## Monitoring

Enable metrics via chart values if required by your monitoring stack.

## Dependencies

- Flux (Helm controller)

## Operations

- Reconcile:

  ```sh
  flux reconcile kustomization coredns -n kube-system
  ```

- Inspect:

  ```sh
  kubectl -n kube-system get helmrelease,deploy,svc,pod
  ```

## File map

- Kustomization (Flux): `kubernetes/apps/kube-system/coredns/ks.yaml`
- App manifests: `kubernetes/apps/kube-system/coredns/app/`
  - HelmRelease: `helmrelease.yaml`
  - Values: `helm/values.yaml` (+ `helm/kustomizeconfig.yaml` if present)
  - Kustomization (kustomize): `kustomization.yaml`