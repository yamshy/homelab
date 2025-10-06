# Infisical Secrets Operator (Kubernetes App)

Concise documentation for deploying the Infisical Kubernetes Secrets Operator via Flux.

## Quick links

- Namespace: `infisical-system`
- Flux Kustomization: `kubernetes/apps/infisical-system/infisical-secrets-operator/ks.yaml`
- HelmRelease: `kubernetes/apps/infisical-system/infisical-secrets-operator/app/helmrelease.yaml`
- Chart values: `kubernetes/apps/infisical-system/infisical-secrets-operator/app/helm/values.yaml`

## Overview

Installs Infisical Secrets Operator and CRDs to sync secrets from Infisical into Kubernetes Secrets. Metrics integration is available when Prometheus Operator is present.

## Workload

- Chart: `secrets-operator` 0.7.5 from HelmRepository `infisical-helm-charts`
- CRDs: InfisicalSecret, InfisicalPushSecret, InfisicalDynamicSecret

## Networking and exposure

No user-facing services; operator runs in-cluster.

## Image automation

Not applicable.

## Monitoring

Enable ServiceMonitor via chart values if you want Prometheus to scrape operator metrics.

## Dependencies

- Flux (Helm controller)
- Access to Infisical Cloud or self-hosted API
- Kubernetes Secrets to hold tokens/credentials when using service tokens
- For kubernetesAuth, a ServiceAccount in the target namespace

## Operations

- Reconcile:

  ```sh
  flux reconcile kustomization infisical-secrets-operator -n security
  ```

- Inspect:

  ```sh
  kubectl -n security get helmrelease,deploy,svc,pod
  kubectl get crd | grep infisical
  ```

- Verify operator pods:

  ```sh
  kubectl -n security get pods -l app.kubernetes.io/name=secrets-operator
  ```

## Usage examples

Option A: Service Token

```sh
kubectl -n security create secret generic infisical-service-token \
  --from-literal=infisicalToken=<YOUR_SERVICE_TOKEN>
```

```yaml
apiVersion: secrets.infisical.com/v1alpha1
kind: InfisicalSecret
metadata:
  name: example-infisicalsecret
  namespace: security
spec:
  resyncInterval: 10
  authentication:
    serviceToken:
      serviceTokenSecretReference:
        secretName: infisical-service-token
        secretNamespace: security
  secretsScope:
    envSlug: dev
    secretsPath: "/"
  managedSecretReference:
    secretName: example-managed-secret
    secretNamespace: security
```

Option B: Kubernetes Auth with Machine Identity

```yaml
apiVersion: secrets.infisical.com/v1alpha1
kind: InfisicalSecret
metadata:
  name: example-infisicalsecret-k8sauth
  namespace: security
spec:
  resyncInterval: 10
  kubernetesAuth:
    identityId: "<machine-identity-id>"
    autoCreateServiceAccountToken: true
    serviceAccountTokenAudiences:
      - "infisical"
    serviceAccountRef:
      name: default
      namespace: security
  secretsScope:
    envSlug: dev
    secretsPath: "/"
  managedSecretReference:
    secretName: example-managed-secret
    secretNamespace: security
```

## File map

- Kustomization (Flux): `kubernetes/apps/infisical-system/infisical-secrets-operator/ks.yaml`
- App manifests: `kubernetes/apps/infisical-system/infisical-secrets-operator/app/`
  - HelmRelease: `helmrelease.yaml`
  - Values: `helm/values.yaml` (+ `helm/kustomizeconfig.yaml` if present)
  - Kustomization (kustomize): `kustomization.yaml`
