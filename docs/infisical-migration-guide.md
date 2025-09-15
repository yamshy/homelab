# Infisical Migration Guide

This guide documents the process for migrating apps from SOPS-encrypted secrets to Infisical-managed secrets in the homelab.

## Overview

We're migrating from SOPS (encrypted secrets in git) to Infisical (cloud-managed secrets) using a **per-app pattern** that mirrors the existing SOPS structure.

## Architecture

### Before (SOPS)
```
kubernetes/apps/[namespace]/[app]/app/
├── secret.sops.yaml          # Encrypted secrets in git
├── helmrelease.yaml
└── kustomization.yaml
```

### After (Infisical)
```
kubernetes/apps/[namespace]/[app]/app/
├── secrets.infisical.yaml    # InfisicalSecret pointing to Infisical Cloud
├── helmrelease.yaml
└── kustomization.yaml
```

## Prerequisites

### 1. Infisical Setup
- **Project**: `homelab-0r-b1`
- **Environment**: `prod`
- **Machine Identity**: `kubernetes-homelab-secrets` (ID: `df0be54b-a540-4045-9689-df826fd4e950`)
- **Authentication**: Universal Auth (works with private clusters)

### 2. Infrastructure Credentials
Universal Auth credentials are stored in `flux-system` namespace:
```yaml
# Created manually in cluster
apiVersion: v1
kind: Secret
metadata:
  name: universal-auth-credentials
  namespace: flux-system
type: Opaque
data:
  clientId: <base64-encoded-client-id>
  clientSecret: <base64-encoded-client-secret>
```

## Migration Process

### Step 1: Add Secrets to Infisical
1. Log into Infisical Cloud
2. Navigate to project `homelab-0r-b1` → environment `prod`
3. Add the secrets that the app needs (e.g., `SECRET_DOMAIN`, `SECRET_TAILNET`, etc.)

### Step 2: Create InfisicalSecret
Create `secrets.infisical.yaml` in the app directory:

```yaml
# InfisicalSecret for [app-name] secrets in [namespace] namespace
# Reference: https://infisical.com/docs/integrations/platforms/kubernetes/infisical-secret-crd
---
apiVersion: secrets.infisical.com/v1alpha1
kind: InfisicalSecret
metadata:
  name: [secret-name]  # e.g., cluster-secrets, app-specific-secrets
  namespace: [target-namespace]  # e.g., default, network, monitoring
spec:
  resyncInterval: 60
  authentication:
    universalAuth:
      secretsScope:
        projectSlug: "homelab-0r-b1"
        envSlug: "prod"
        secretsPath: "/"
        recursive: true
      credentialsRef:
        secretName: "universal-auth-credentials"
        secretNamespace: "flux-system"  # Infrastructure credentials
  managedSecretReference:
    secretName: "[secret-name]"  # Name of resulting Kubernetes secret
    secretNamespace: "[target-namespace]"
    creationPolicy: "Orphan"  # Keep secret if InfisicalSecret is deleted
```

### Step 3: Update App Kustomization
Add the InfisicalSecret to the app's kustomization:

```yaml
# kubernetes/apps/[namespace]/[app]/app/kustomization.yaml
resources:
  - ./helmrelease.yaml
  - ./secrets.infisical.yaml  # Add this line
```

### Step 4: Remove SOPS Decryption
Remove SOPS decryption from the app's Flux kustomization:

```yaml
# kubernetes/apps/[namespace]/[app]/ks.yaml
spec:
  # Remove this entire section:
  # decryption:
  #   provider: sops
  #   secretRef:
  #     name: sops-age

  postBuild:
    substituteFrom:
      - name: [secret-name]
        kind: Secret
        # namespace: [target-namespace]  # Only if cross-namespace
```

### Step 5: Commit and Test
1. Commit all changes and push
2. Wait for Flux reconciliation (or force with `flux reconcile`)
3. Verify InfisicalSecret status: `kubectl describe infisicalsecret [name] -n [namespace]`
4. Check secret creation: `kubectl get secret [name] -n [namespace]`
5. Test app functionality

## Example Migration: Echo App

### Original Structure
```
kubernetes/apps/default/echo/
├── ks.yaml                   # Had SOPS decryption
└── app/
    ├── helmrelease.yaml
    └── kustomization.yaml
```

### Migrated Structure
```
kubernetes/apps/default/echo/
├── ks.yaml                   # SOPS decryption removed
└── app/
    ├── helmrelease.yaml
    ├── secrets.infisical.yaml # New: InfisicalSecret
    └── kustomization.yaml     # Updated: includes secrets.infisical.yaml
```

### secrets.infisical.yaml
```yaml
apiVersion: secrets.infisical.com/v1alpha1
kind: InfisicalSecret
metadata:
  name: cluster-secrets
  namespace: default
spec:
  resyncInterval: 60
  authentication:
    universalAuth:
      secretsScope:
        projectSlug: "homelab-0r-b1"
        envSlug: "prod"
        secretsPath: "/"
        recursive: true
      credentialsRef:
        secretName: "universal-auth-credentials"
        secretNamespace: "flux-system"
  managedSecretReference:
    secretName: "cluster-secrets"
    secretNamespace: "default"
    creationPolicy: "Orphan"
```

## Troubleshooting

### Common Issues

1. **Cross-namespace credential access denied**
   - Ensure `universal-auth-credentials` exists in `flux-system`
   - Check RBAC permissions for Infisical operator

2. **InfisicalSecret not creating secret**
   - Check InfisicalSecret status: `kubectl describe infisicalsecret [name]`
   - Verify secrets exist in Infisical Cloud project
   - Check operator logs: `kubectl logs -n security -l app.kubernetes.io/name=infisical-secrets-operator`

3. **App can't find secrets**
   - Verify secret name matches what app expects
   - Check secret exists: `kubectl get secret [name] -n [namespace]`
   - Ensure SOPS decryption is removed from app's kustomization

### Verification Commands
```bash
# Check InfisicalSecret status
kubectl describe infisicalsecret [name] -n [namespace]

# Verify secret creation and content
kubectl get secret [name] -n [namespace] -o yaml

# Check specific secret value
kubectl get secret [name] -n [namespace] -o jsonpath='{.data.SECRET_DOMAIN}' | base64 -d

# Force Flux reconciliation
flux reconcile kustomization [app-name] -n [namespace]
```

## Benefits of This Pattern

1. **Consistency**: Mirrors existing SOPS pattern
2. **Isolation**: Each app manages its own secrets
3. **Flexibility**: Apps can be migrated individually
4. **Security**: Infrastructure credentials separated in `flux-system`
5. **Maintainability**: Clear per-app secret ownership

## Notes

- **Private Clusters**: Universal Auth works where Kubernetes Auth doesn't (Infisical Cloud can't reach private cluster APIs)
- **Credential Sharing**: All apps share Universal Auth credentials from `flux-system`
- **Secret Persistence**: `creationPolicy: "Orphan"` ensures secrets persist if InfisicalSecret is deleted
- **Sync Frequency**: `resyncInterval: 60` syncs secrets every minute