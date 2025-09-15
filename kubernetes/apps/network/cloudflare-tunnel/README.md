# Cloudflare Tunnel (Kubernetes App)

Concise documentation for exposing cluster services via Cloudflare Tunnel, managed with app-template.

## Quick links

- Namespace: `network`
- Flux Kustomization: `kubernetes/apps/network/cloudflare-tunnel/ks.yaml`
- HelmRelease: `kubernetes/apps/network/cloudflare-tunnel/app/helmrelease.yaml`
- DNSEndpoint: `kubernetes/apps/network/cloudflare-tunnel/app/dnsendpoint.yaml`
- Secret (SOPS): `kubernetes/apps/network/cloudflare-tunnel/app/secret.sops.yaml`

## Overview

Runs `cloudflared` as a Deployment using bjw-s/app-template. Uses a pre-created Tunnel (token in secret) to proxy HTTPS traffic to the cluster. DNS CNAMEs point your apex and external endpoints to the tunnel.

## Workload

- Image: `docker.io/cloudflare/cloudflared:2025.8.1`
- Ports:
  - Metrics: 8080 (served on /ready)
- Security:
  - runAsNonRoot: true (65534)
  - readOnlyRootFilesystem: true; drop ALL capabilities
- Resources: requests 10m CPU, limits 256Mi memory

## Networking and exposure

- DNSEndpoint defines CNAMEs:
  - external.${SECRET_DOMAIN} → <tunnel>.cfargotunnel.com
  - ${SECRET_DOMAIN} → <tunnel>.cfargotunnel.com
- Service: ClusterIP exposing metrics on port 8080
- No Gateway or Ingress exposure; Cloudflare Edge proxies to the tunnel.

## Image automation

Not applicable.

## Monitoring

- ServiceMonitor enabled for metrics on port http (8080).

## Dependencies

- Flux (Helm controller)
- Existing Cloudflare Tunnel credentials secret: `cloudflare-tunnel-secret`
- ConfigMap `cloudflare-tunnel-configmap` with config.yaml mounted at /etc/cloudflared/config.yaml
- ExternalDNS (optional) to manage DNS via DNSEndpoint

Substitutions:
- `${SECRET_DOMAIN}` injected via Flux postBuild.

## Operations

- Reconcile:

  ```sh
  flux reconcile kustomization cloudflare-tunnel -n network
  ```

- Inspect:

  ```sh
  kubectl -n network get helmrelease,deploy,svc,pod
  ```

## File map

- Kustomization (Flux): `kubernetes/apps/network/cloudflare-tunnel/ks.yaml`
- App manifests: `kubernetes/apps/network/cloudflare-tunnel/app/`
  - HelmRelease: `helmrelease.yaml`
  - DNSEndpoint: `dnsendpoint.yaml`
  - Secret (SOPS): `secret.sops.yaml`
  - Additional resources: `resources/`
  - Kustomization (kustomize): `kustomization.yaml`