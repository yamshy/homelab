# cert-manager (Kubernetes App)

Concise documentation for deploying cert-manager via Flux and Helm.

## Quick links

- Namespace: `cert-manager` (ClusterIssuer is cluster-scoped; HelmRelease does not set namespace explicitly and is reconciled by the Flux Kustomization targeting this app’s namespace)
- Flux Kustomization: `kubernetes/apps/cert-manager/cert-manager/ks.yaml`
- HelmRelease: `kubernetes/apps/cert-manager/cert-manager/app/helmrelease.yaml`
- Chart values: `kubernetes/apps/cert-manager/cert-manager/app/helm/values.yaml`
- ClusterIssuer: `kubernetes/apps/cert-manager/cert-manager/app/clusterissuer.yaml`
- Secret (SOPS for Cloudflare token): `kubernetes/apps/cert-manager/cert-manager/app/secret.sops.yaml`

## Overview

Installs cert-manager from Jetstack’s OCI chart and configures a production Let’s Encrypt ClusterIssuer using Cloudflare DNS-01.

## Workload

- Chart: `cert-manager` from OCI `quay.io/jetstack/charts/cert-manager` tag `v1.18.2`
- CRDs: enabled (managed by chart values)
- Replica count: 1 (tunable in values)
- Prometheus ServiceMonitor: enabled

## Networking and exposure

cert-manager doesn’t expose an application service. It watches Kubernetes resources cluster-wide and solves ACME challenges via Cloudflare DNS-01.

## Image automation

Not applicable; chart and version are pinned via OCI tag in the OCIRepository. Renovate can update the tag.

## Monitoring

- Prometheus ServiceMonitor is enabled through chart values.

## Dependencies

- Flux (Helm controller)
- Cloudflare API token Secret for DNS-01:
  - Secret name: `cert-manager-secret`
  - key: `api-token`
- Cluster-wide permissions for cert-manager (handled by the chart’s CRDs/manifests)
- SOPS/Age for secret encryption

Substitutions:
- `${SECRET_DOMAIN}` is injected via Flux postBuild for the dnsZones selector.

## Operations

- Reconcile this app:

  ```sh
  flux reconcile kustomization cert-manager -n cert-manager
  ```

- Inspect status and resources:

  ```sh
  kubectl -n cert-manager get helmrelease,deploy,svc,servicemonitor,pod
  kubectl get clusterissuer
  ```

- Issue a test certificate (optional):

  ```sh
  kubectl -n default apply -f - &lt;&lt;'EOF'
  apiVersion: cert-manager.io/v1
  kind: Certificate
  metadata:
    name: demo-cert
  spec:
    secretName: demo-cert-tls
    issuerRef:
      name: letsencrypt-production
      kind: ClusterIssuer
    dnsNames:
      - demo.${SECRET_DOMAIN}
  EOF
  ```

## File map

- Kustomization (Flux): `kubernetes/apps/cert-manager/cert-manager/ks.yaml`
- App manifests: `kubernetes/apps/cert-manager/cert-manager/app/`
  - HelmRelease: `helmrelease.yaml`
  - Values: `helm/values.yaml` (+ `helm/kustomizeconfig.yaml`)
  - ClusterIssuer: `clusterissuer.yaml`
  - Secret (SOPS): `secret.sops.yaml`
  - Kustomization (kustomize): `kustomization.yaml`