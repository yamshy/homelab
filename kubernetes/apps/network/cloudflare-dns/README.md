# Cloudflare DNS (ExternalDNS)

Concise documentation for managing DNS via ExternalDNS with Cloudflare.

## Quick links

- Namespace: `network`
- Flux Kustomization: `kubernetes/apps/network/cloudflare-dns/ks.yaml`
- HelmRelease: `kubernetes/apps/network/cloudflare-dns/app/helmrelease.yaml`
- Secret (Infisical): `kubernetes/apps/network/cloudflare-dns/app/secrets.infisical.yaml`

## Overview

Deploys ExternalDNS configured for Cloudflare to manage DNS for `${SECRET_DOMAIN}`. Records are sourced from Gateway HTTPRoutes and DNSEndpoint CRDs. TXT ownership is prefixed with `k8s.` and owner ID `default`.

## Networking and exposure

No service exposure; ExternalDNS reconciles DNS records against Cloudflare.

## Image automation

Not applicable.

## Monitoring

- ServiceMonitor is enabled for metrics scraping.

## Dependencies

- Flux (Helm controller)
- Cloudflare API token Secret:
  - name: `cloudflare-dns-secret`
  - key: `api-token`
- ExternalDNS CRDs and Gateway API (for HTTPRoute sources)

Substitutions:
- `${SECRET_DOMAIN}` injected via Flux postBuild.

## Operations

- Reconcile:

  ```sh
  flux reconcile kustomization cloudflare-dns -n network
  ```

- Inspect:

  ```sh
  kubectl -n network get helmrelease,svc,pod
  ```

## File map

- Kustomization (Flux): `kubernetes/apps/network/cloudflare-dns/ks.yaml`
- App manifests: `kubernetes/apps/network/cloudflare-dns/app/`
  - HelmRelease: `helmrelease.yaml`
  - Secret (Infisical): `secrets.infisical.yaml`
  - Kustomization (kustomize): `kustomization.yaml`
