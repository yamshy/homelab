# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a production-ready homelab Kubernetes cluster built on Talos Linux with Flux for GitOps continuous deployment. The cluster runs Kubernetes v1.33.4 on Talos Linux v1.10.6 with a 3-node highly-available control plane.

## Essential Commands

### Validation & Testing
```bash
# Validate all Kubernetes manifests locally (uses kubeconform)
mise run validate
# Or directly: bash scripts/validate.sh

# Install development tools
mise trust
mise install
```

### Flux GitOps Operations
```bash
# Force Flux to reconcile changes from Git
task reconcile
# Or: flux --namespace flux-system reconcile kustomization flux-system --with-source

# Check Flux status
flux check
flux get sources git -A
flux get ks -A
flux get hr -A
```

### Talos Cluster Management
```bash
# Generate Talos configuration
task talos:generate-config

# Apply config to a specific node
task talos:apply-node IP=192.168.121.X MODE=auto

# Upgrade Talos on a specific node
task talos:upgrade-node IP=192.168.121.X

# Upgrade Kubernetes version
task talos:upgrade-k8s
```

### Bootstrap Operations
```bash
# Bootstrap Talos cluster from scratch
task bootstrap:talos

# Bootstrap applications with Flux
task bootstrap:apps
```

### Cluster Health Checks
```bash
# Check pod status across all namespaces
kubectl get pods -A

# Check for non-running pods
kubectl get pods -A --field-selector=status.phase!=Running

# View application events
kubectl get events -n <namespace> --sort-by='.metadata.creationTimestamp'
```

## Architecture & Structure

### Directory Organization
```
homelab/
├── kubernetes/
│   ├── apps/              # Application deployments by category
│   │   ├── cert-manager/  # Certificate management
│   │   ├── kube-system/   # Core system components (Cilium, CoreDNS, etc.)
│   │   ├── flux-system/   # Flux operator and instance
│   │   ├── network/       # Networking services (Tailscale, Cloudflare, k8s-gateway)
│   │   ├── storage/       # Storage solutions (Longhorn, Synology CSI)
│   │   ├── security/      # Security tools (Falco)
│   │   ├── infisical-system/  # Infisical operator
│   │   ├── default/       # User applications
│   │   ├── media/         # Media applications
│   │   └── ...other categories
│   ├── components/        # Reusable Kustomize components
│   │   └── common/        # Common resources (SOPS secrets, namespaces, repos)
│   └── flux/              # Flux cluster configuration
├── talos/                 # Talos Linux configuration
│   ├── talconfig.yaml     # Main Talos configuration
│   ├── talenv.yaml        # Version definitions
│   └── patches/           # Configuration patches
├── bootstrap/             # Cluster bootstrap manifests
└── scripts/               # Automation scripts
```

### Standard Application Structure
Every application follows this consistent pattern:
```
kubernetes/apps/<category>/<app-name>/
├── app/
│   ├── helm/
│   │   ├── values.yaml           # Helm configuration values
│   │   └── kustomizeconfig.yaml  # ConfigMap name references
│   ├── helmrelease.yaml          # Flux HelmRelease + OCI Repository
│   ├── kustomization.yaml        # App-level kustomization
│   └── (other resources)         # Additional Kubernetes resources
└── ks.yaml                       # Flux Kustomization for GitOps
```

### Flux Kustomization Pattern
Each app has a `ks.yaml` that:
- Defines the Flux Kustomization resource
- Sets `prune: true` for automatic cleanup
- Includes health checks and intervals
- Specifies dependencies using `dependsOn`

### HelmRelease Pattern
Applications use:
- **OCI Repository**: Modern chart source approach (co-located with HelmRelease in `app/helmrelease.yaml`)
- **ConfigMap values**: Values stored in generated ConfigMaps
- **Remediation**: Retry policies and cleanup on failure
- **Intervals**: Appropriate reconciliation timing

## Namespace-Level Secrets Architecture

This repository uses an **enterprise-grade namespace-level secrets pattern** with **Infisical** for centralized secret management:

```
kubernetes/apps/<namespace>/
├── secrets/                    # Centralized namespace secrets (deployed first)
│   ├── ks.yaml                # Secrets Kustomization
│   ├── kustomization.yaml     # Manages all namespace secrets
│   ├── app1-secrets.yaml      # App-specific InfisicalSecret
│   └── app2-secrets.yaml      # App-specific InfisicalSecret
├── app1/
│   └── ks.yaml               # Depends on 'secrets' Kustomization
└── app2/
    └── ks.yaml               # Depends on 'secrets' Kustomization
```

**Key Benefits:**
- No bootstrap dependency issues (secrets created before apps need them)
- App-specific scoping with principle of least privilege (87% reduction in secret exposure)
- Single source of truth per namespace
- Easy to add new apps without conflicts

**Implementation:** Each app's `ks.yaml` includes `dependsOn` referencing the namespace's `secrets` Kustomization.

## Secret Management

### Infisical (Primary Method)
**Almost all secrets in this cluster are managed through Infisical.** The Infisical Kubernetes Operator syncs secrets from Infisical cloud into Kubernetes secrets.

**InfisicalSecret Pattern:**
```yaml
apiVersion: secrets.infisical.com/v1alpha1
kind: InfisicalSecret
metadata:
  name: app-secrets
  namespace: app-namespace
spec:
  hostAPI: https://app.infisical.com/api
  authentication:
    universalAuth:
      secretsScope:
        projectSlug: homelab
        envSlug: prod
        secretsPath: /app-name
      credentialsRef:
        secretName: universal-auth-credentials
        secretNamespace: infisical-system
  managedSecretReference:
    secretName: app-secrets
    secretType: Opaque
```

**Creating New Secrets:**
1. Add secrets to Infisical dashboard at the appropriate path
2. Create an InfisicalSecret resource in `kubernetes/apps/<namespace>/secrets/`
3. Reference the secret in your application using `secretName` from `managedSecretReference`

### SOPS (Bootstrap Only)
SOPS with AGE encryption is **only used for a few bootstrap secrets** that are needed before Infisical is available:
- `kubernetes/components/common/sops/sops-age.sops.yaml` (Flux decryption key)
- `talos/talsecret.sops.yaml` (Talos cluster secrets)
- A few bootstrap credentials in `bootstrap/`

**Do not create new SOPS secrets.** Use Infisical for all new secrets.

## YAML Conventions

### YAML Anchors
- **Use anchors (`&name`) only when a value is repeated multiple times within the same document**
- **Never use anchors across document boundaries** (separated by `---`)
- **Don't use anchors for single-use values**
- Common anchor names: `&app` (application name), `&namespace` (namespace name)

### Examples
```yaml
# ✅ Correct - anchors within same document
---
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: &app myapp
spec:
  chart:
    spec:
      chart: *app  # References &app from same document

# ❌ Incorrect - anchors across documents
---
metadata:
  name: &repo myrepo
---
spec:
  sourceRef:
    name: *repo  # This will fail! Can't cross --- boundaries
```

## Networking Architecture

- **CNI**: Cilium with eBPF-based networking
- **Internal Gateway**: Cilium Gateway API for local network access
- **External Access**: Cloudflare Tunnel + Tailscale LoadBalancer
- **DNS**: k8s-gateway for internal DNS resolution
- **CIDRs**: 10.42.0.0/16 (pods), 10.43.0.0/16 (services), 192.168.121.0/24 (nodes)

## Storage Architecture

- **Default Storage**: Longhorn distributed block storage with multi-node replication
- **Additional Storage**: Synology CSI for NFS/iSCSI from NAS
- **Dynamic Provisioning**: Automatic volume creation via storage classes

## Key Patterns & Best Practices

### Helm Chart Source Placement
- Co-locate chart sources (HelmRepository/OCIRepository) with HelmReleases in `app/helmrelease.yaml`
- Only use central shared repos when multiple apps use the same chart repository
- See validation script guidance in `scripts/validate.sh:16-17`

### Version Pinning
- Always pin Helm chart versions for stability
- Pin container image versions in values files
- Use semantic versioning

### Resource Management
- Set appropriate resource requests and limits
- Include readiness and liveness probes
- Use proper health checks in Flux Kustomizations

### Security
- **Use Infisical for all secrets** - do not create new SOPS secrets
- Add secrets to Infisical dashboard, then create InfisicalSecret resources
- Use namespace-level secrets with app-specific scoping
- Implement appropriate RBAC and network policies
- Use non-root container execution where possible

### GitOps Workflow
1. Edit YAML files in Git repository
2. Commit and push changes
3. Flux automatically detects and applies changes
4. Monitor with `flux get ks -A` and `flux get hr -A`
5. Force immediate reconciliation with `task reconcile` if needed

## CI/CD

- **Schema Validation**: Kubeconform v0.7.0 in strict mode against Kubernetes 1.33.4
- **Kustomize Rendering**: All overlays must render valid Kubernetes objects
- **SOPS Sanitization**: Encrypted secrets have SOPS metadata removed before validation
- **Custom Schemas**: Vendored locally in `schemas/` directory

## Core Components

- **Flux**: GitOps operator for continuous deployment
- **Infisical Operator**: Centralized secret management
- **Cilium**: CNI with Gateway API implementation
- **Longhorn**: Distributed block storage
- **cert-manager**: Automated TLS certificate management
- **Tailscale Operator**: VPN access and load balancing
- **Cloudflare Tunnel**: Secure external access
- **Reloader**: Automatic configuration reloading
- **Spegel**: Container image mirroring
- **Metrics Server**: Kubernetes metrics aggregation
- **Falco**: Runtime security monitoring

## Troubleshooting

### Flux Sync Issues
```bash
# Check Kustomization status
flux describe ks <name> -n <namespace>

# Force reconciliation
flux reconcile kustomization <name> -n <namespace>

# Check HelmRelease status
flux describe hr <name> -n <namespace>
```

### Infisical Secret Issues
```bash
# Check InfisicalSecret status
kubectl get infisicalsecret -n <namespace>
kubectl describe infisicalsecret <name> -n <namespace>

# Check if managed secret was created
kubectl get secret <managed-secret-name> -n <namespace>

# Check Infisical operator logs
kubectl logs -n infisical-system -l app.kubernetes.io/name=infisical-secrets-operator
```

### Network Issues
```bash
# Check Cilium status
kubectl get pods -n kube-system -l k8s-app=cilium

# Check network policies
kubectl get networkpolicies -A

# Check Gateway resources
kubectl get gateways -A
```

### Storage Issues
```bash
# Check Longhorn status
kubectl -n longhorn-system get pods

# Check persistent volumes
kubectl get pv,pvc -A
```

## Development Notes

- Tooling managed by Mise (version management)
- Task runner for common operations (see `Taskfile.yaml`)
- Validation runs locally before CI with `bash scripts/validate.sh`
- All manifests are validated against Kubernetes schemas and CRD schemas
- **New secrets should always use Infisical** - SOPS is only for bootstrap