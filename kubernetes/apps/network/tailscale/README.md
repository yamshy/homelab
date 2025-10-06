# Tailscale Operator (Kubernetes App)

Concise documentation for deploying the Tailscale Operator via Helm. Enables Tailscale Ingress/LoadBalancer and ProxyClass patterns.

## Quick links

- Namespace: `network`
- Flux Kustomization: `kubernetes/apps/network/tailscale/ks.yaml`
- HelmRelease: `kubernetes/apps/network/tailscale/app/helmrelease.yaml`
- ProxyClass (CR): `kubernetes/apps/network/tailscale/app/proxyclass.yaml`
- Secret (Infisical OAuth creds): `kubernetes/apps/network/tailscale/app/secrets.infisical.yaml`

## Overview

Installs Tailscale Operator and configures OAuth credentials via a mounted secret to enable Tailscale-provisioned resources (IngressClass, LoadBalancerClass, and ProxyClass).

## Workload

- Chart: `tailscale-operator` 1.86.5 from HelmRepository `tailscale`
- Resources tuned for homelab; runs as non-root (65534).

## Networking and exposure

- Provides:
  - IngressClass "tailscale" (for HTTP(S) ingress)
  - LoadBalancerClass "tailscale" (for L4 services)
- Optional ProxyClass `tailscale-tun` grants containers access to TUN device on Talos via generic-device-plugin.

## Image automation

Not applicable.

## Monitoring

If the chart exposes metrics, enable via values and ensure your Prometheus stack scrapes them.

## Dependencies

- Flux (Helm controller)
- OAuth client secret `tailscale-oauth-secret` with:
  - TAILSCALE_OAUTH_CLIENT_ID
  - TAILSCALE_OAUTH_CLIENT_SECRET
- Generic Device Plugin and ProxyClass `tailscale-tun` for TUN access (Talos)

## Operations

- Reconcile:

  ```sh
  flux reconcile kustomization tailscale -n network
  ```

- Inspect:

  ```sh
  kubectl -n network get helmrelease,deploy,svc,pod,proxyclass
  ```

## File map

- Kustomization (Flux): `kubernetes/apps/network/tailscale/ks.yaml`
- App manifests: `kubernetes/apps/network/tailscale/app/`
  - HelmRelease: `helmrelease.yaml`
  - ProxyClass: `proxyclass.yaml`
  - Secret (Infisical): `secrets.infisical.yaml`
  - Kustomization (kustomize): `kustomization.yaml`
