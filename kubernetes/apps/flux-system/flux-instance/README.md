# Flux Instance (Kubernetes App)

Concise documentation for deploying the Flux Instance via Helm, including a GitHub webhook receiver exposed through Gateway API.

## Quick links

- Namespace: `flux-system`
- Flux Kustomization: `kubernetes/apps/flux-system/flux-instance/ks.yaml`
- HelmRelease: `kubernetes/apps/flux-system/flux-instance/app/helmrelease.yaml`
- Values: `kubernetes/apps/flux-system/flux-instance/app/helm/values.yaml`
- Receiver: `kubernetes/apps/flux-system/flux-instance/app/receiver.yaml`
- HTTPRoute: `kubernetes/apps/flux-system/flux-instance/app/httproute.yaml`
- Webhook secret (Infisical): `kubernetes/apps/flux-system/flux-instance/app/secrets.infisical.yaml`

## Overview

Installs a Flux Instance using the controlplaneio-fluxcd Helm chart and exposes a GitHub webhook Receiver over HTTPS on `flux-webhook.${SECRET_DOMAIN}` via Gateway API.

## Workload

- Chart: `flux-instance` from OCI `ghcr.io/controlplaneio-fluxcd/charts/flux-instance` tag `0.28.0`
- Receiver: notification.toolkit.fluxcd.io/v1 Receiver listening for GitHub `ping` and `push` events
- Depends on: `flux-operator` HelmRelease

## Networking and exposure

- Gateway API HTTPRoute at `flux-webhook.${SECRET_DOMAIN}`
- ParentRef: `external` Gateway in `kube-system`, section `https`
- Backend: Service `webhook-receiver` in `flux-system` on port 80
- TLS is terminated at the external Gateway; the receiver serves HTTP behind the gateway.

## Image automation

Not applicable.

## Monitoring

No ServiceMonitor included by default for the receiver. The Flux controllers may expose metrics depending on the chart values.

## Dependencies

- Flux (Helm controller)
- Gateway API with an external Gateway (`kube-system/external`, section `https`)
- GitHub webhook token Secret (`github-webhook-token-secret`) encrypted with SOPS

Substitutions:
- `${SECRET_DOMAIN}` provided via Flux postBuild substitutions.

## Operations

- Reconcile:

  ```sh
  flux reconcile kustomization flux-instance -n flux-system
  ```

- Inspect:

  ```sh
  kubectl -n flux-system get helmrelease,receiver,svc,httproute,pod
  ```

- Configure GitHub webhook:
  - URL: `https://flux-webhook.${SECRET_DOMAIN}/hook/`
  - Content type: application/json
  - Secret: matches `github-webhook-token-secret`

## File map

- Kustomization (Flux): `kubernetes/apps/flux-system/flux-instance/ks.yaml`
- App manifests: `kubernetes/apps/flux-system/flux-instance/app/`
  - HelmRelease: `helmrelease.yaml`
  - Values: `helm/values.yaml` (+ `helm/kustomizeconfig.yaml` if present)
  - Receiver: `receiver.yaml`
  - HTTPRoute: `httproute.yaml`
  - Secret (Infisical): `secrets.infisical.yaml`
  - Kustomization (kustomize): `kustomization.yaml`
