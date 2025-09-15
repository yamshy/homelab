# Echo (Kubernetes App)

Concise documentation for deploying a simple HTTP echo service via Flux and the bjw-s/app-template Helm chart.

## Quick links

- Namespace: `default`
- Flux Kustomization: `kubernetes/apps/default/echo/ks.yaml`
- HelmRelease: `kubernetes/apps/default/echo/app/helmrelease.yaml`
- Chart values: `kubernetes/apps/default/echo/app/helm/values.yaml`

## Overview

Deploys `ghcr.io/mendhak/http-https-echo:37` with basic probes and a minimal resource footprint.

## Workload

- Controller: `echo`
- Image: `ghcr.io/mendhak/http-https-echo:37`
- Ports:
  - Container/Service: 80 (HTTP)
- Probes: HTTP GET `/healthz` on port 80 (liveness/readiness)
- Resources:
  - requests: 10m CPU
  - limits: 64Mi memory
- Security:
  - runAsNonRoot: true
  - runAsUser/group: 65534
  - readOnlyRootFilesystem: true
  - allowPrivilegeEscalation: false
  - capabilities: drop ALL

## Networking and exposure

- Ingress (internal): Tailscale IngressClass, host `https://echo`
- Gateway API (external): HTTPRoute at `echo.${SECRET_DOMAIN}` using the external Gateway (`kube-system/external`, section `https`)

TLS is handled by the respective ingress/gateway component; the service listens on HTTP port 80.

## Image automation

Not configured; the image tag is pinned in values.

## Monitoring

- ServiceMonitor is enabled to scrape metrics from the `http` port.

## Dependencies

- Flux (Kustomize and Helm controllers)
- Tailscale IngressClass/controller
- Gateway API and an external Gateway (`kube-system/external`)

Substitutions:
- `${SECRET_DOMAIN}` provided via Flux postBuild substitutions.

## Operations

- Reconcile this app:

  ```sh
  flux reconcile kustomization echo -n default
  ```

- Inspect status and resources:

  ```sh
  kubectl -n default get kustomization/echo
  kubectl -n default get deploy,svc,ingress,httproute,pod
  ```

## File map

- Kustomization (Flux): `kubernetes/apps/default/echo/ks.yaml`
- App manifests: `kubernetes/apps/default/echo/app/`
  - HelmRelease: `helmrelease.yaml`
  - Values: `helm/values.yaml` (+ `helm/kustomizeconfig.yaml`)
  - Kustomization (kustomize): `kustomization.yaml`

