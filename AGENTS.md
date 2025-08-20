# AGENTS.md - Homelab Kubernetes Infrastructure

## Repository Overview

This is a **homelab Kubernetes infrastructure** repository that uses GitOps principles with Flux to manage a Talos Linux-based Kubernetes cluster. The repository follows a declarative infrastructure approach where all cluster configuration is stored as code and automatically applied through Flux.

## 🏗️ Architecture & Structure

### Core Components

- **Talos Linux**: Minimal, immutable Linux distribution for Kubernetes
- **Flux**: GitOps operator for continuous deployment
- **Cilium**: CNI and network policy enforcement
- **cert-manager**: Certificate management for TLS
- **External-DNS**: DNS record management
- **Cloudflare Tunnel**: Secure external access

### Directory Structure

```bash
homelab/
├── bootstrap/           # Initial cluster bootstrap configuration
├── kubernetes/          # Main cluster configuration (Flux-managed)
│   ├── apps/           # Application deployments
│   └── components/     # Shared components and secrets
├── talos/              # Talos Linux configuration
├── scripts/            # Bootstrap and utility scripts
└── .taskfiles/         # Task definitions for common operations
```

## 🚀 Development Environment

### Prerequisites

- **Mise**: Tool version management (`mise install`)
- **Talhelper**: Talos configuration generation
- **SOPS**: Secret encryption/decryption
- **kubectl**: Kubernetes CLI
- **flux**: Flux CLI for GitOps operations

### Key Tools & Commands

```bash
# Install development tools
mise trust
mise install

# Generate Talos configuration
task talos:generate-config

# Bootstrap cluster
task bootstrap:talos
task bootstrap:apps

# Force Flux reconciliation
task reconcile
```

## 📝 Contribution Guidelines

### Code Style & Standards

- **YAML**: Use consistent indentation (2 spaces), follow Kubernetes resource conventions
- **Helm**: Prefer HelmReleases over raw manifests when possible
- **Secrets**: Always encrypt with SOPS using age encryption
- **Documentation**: Update README.md and relevant docs when adding new components

### File Naming Conventions

- **Kubernetes resources**: Use kebab-case (e.g., `my-app-deployment.yaml`)
- **Helm values**: `values.yaml` in app-specific directories
- **SOPS encrypted files**: `.sops.yaml` extension
- **Task definitions**: Use descriptive names in Taskfile.yaml

### Adding New Applications

1. Create directory structure: `kubernetes/apps/<app-name>/`
2. Add HelmRelease and Kustomization files
3. Include appropriate values.yaml if custom configuration needed
4. Update parent kustomization.yaml files
5. Test with `flux check` and `kubectl get pods`

## 🔧 Validation & Testing

### Pre-commit Checks

```bash
# Validate Kubernetes manifests
kubectl apply --dry-run=client -f kubernetes/

# Check Flux status
flux check
flux get sources git -A
flux get ks -A
flux get hr -A

# Verify SOPS encryption
sops -d kubernetes/components/common/sops/cluster-secrets.sops.yaml
```

### Cluster Health Verification

```bash
# Check node status
kubectl get nodes -o wide

# Verify core components
kubectl get pods -n kube-system
kubectl get pods -n flux-system

# Test network connectivity
cilium status
kubectl get networkpolicies -A
```

### Troubleshooting Workflow

1. **Check Flux status**: `flux check` and `flux get ks -A`
2. **Verify resource existence**: `kubectl get <resource> -n <namespace>`
3. **Check pod logs**: `kubectl logs <pod-name> -n <namespace>`
4. **Describe resources**: `kubectl describe <resource> <name> -n <namespace>`
5. **Check events**: `kubectl get events -n <namespace> --sort-by='.metadata.creationTimestamp'`

## 🔐 Security & Secrets Management

### SOPS Configuration

- **Encryption**: Use age encryption for all secrets
- **Key management**: Store age keys securely, never commit unencrypted secrets
- **File patterns**: All `.sops.yaml` files must be encrypted before committing

### Secret Rotation

1. Update secret values in SOPS files
2. Re-encrypt with current age key
3. Commit and push changes
4. Flux will automatically apply updated secrets

## 🚀 Deployment Workflow

### Initial Setup

1. Configure `talconfig.yaml` and `nodes.yaml`
2. Run `task init` to generate configuration files
3. Run `task configure` to template configurations
4. Bootstrap with `task bootstrap:talos`
5. Deploy applications with `task bootstrap:apps`

### Ongoing Changes

1. Modify configuration files in appropriate directories
2. Commit and push changes to Git
3. Flux automatically detects and applies changes
4. Monitor deployment with `flux get ks -A` and `kubectl get pods`

### Rollback Strategy

- **Flux rollback**: `flux rollback kustomization <name>`
- **Helm rollback**: `flux rollback helmrelease <name>`
- **Git revert**: Revert commit and push to trigger Flux reconciliation

## 📚 Documentation Standards

### Required Documentation

- **README.md**: High-level overview and setup instructions
- **Component docs**: Document complex configurations or customizations
- **Troubleshooting**: Common issues and solutions
- **Architecture**: System design and component interactions

### Documentation Updates

- Update relevant docs when adding new components
- Include configuration examples and use cases
- Document any breaking changes or migration steps
- Keep troubleshooting guides current

## 🔍 Code Review Guidelines

### Review Checklist

- [ ] Kubernetes resources follow best practices
- [ ] SOPS encryption is properly configured
- [ ] Helm values are appropriately configured
- [ ] Kustomization files are updated
- [ ] Documentation is updated
- [ ] No hardcoded secrets or sensitive data
- [ ] Resource limits and requests are defined
- [ ] Network policies are considered

### Common Issues to Watch For

- **Resource conflicts**: Check for duplicate resource names
- **Dependency order**: Ensure proper Helm chart dependencies
- **Secret references**: Verify SOPS files are encrypted
- **Namespace consistency**: Ensure resources are in correct namespaces
- **Resource limits**: Check for appropriate CPU/memory limits

## 🛠️ Maintenance & Updates

### Regular Tasks

- **Security updates**: Monitor and update base images and Helm charts
- **Dependency updates**: Use Renovate for automated dependency management
- **Backup verification**: Ensure cluster state is properly backed up in Git
- **Performance monitoring**: Monitor resource usage and optimize as needed

### Update Procedures

1. **Talos updates**: Use `task talos:upgrade-node` for individual nodes
2. **Kubernetes updates**: Use `task talos:upgrade-k8s` for cluster upgrades
3. **Helm chart updates**: Update versions in values.yaml and commit
4. **Flux updates**: Update Flux operator and instance versions

## 🚨 Emergency Procedures

### Cluster Recovery

- **Node failure**: Use `task talos:reset` to reset failed nodes
- **Configuration corruption**: Restore from Git history
- **Secret compromise**: Rotate age keys and re-encrypt all secrets
- **Network issues**: Check Cilium status and network policies

### Contact Information

- **Community support**: GitHub Discussions and Discord
- **Documentation**: Check README.md and component-specific docs
- **Issues**: Create GitHub issues for bugs or feature requests

## 📋 Best Practices

### Infrastructure as Code

- **Version control**: All configuration must be in Git
- **Declarative**: Use declarative resources over imperative commands
- **Immutable**: Avoid in-place modifications, use GitOps workflow
- **Documentation**: Document all customizations and configurations

### Security

- **Principle of least privilege**: Use RBAC and network policies
- **Secret rotation**: Regular secret rotation and key management
- **Network segmentation**: Implement appropriate network policies
- **Access control**: Limit cluster access and use proper authentication

### Monitoring & Observability

- **Resource monitoring**: Monitor CPU, memory, and storage usage
- **Application health**: Use health checks and readiness probes
- **Logging**: Centralize logs and implement log rotation
- **Alerting**: Set up alerts for critical issues

---

**Remember**: This is a production-like environment. Always test changes in a safe manner and maintain proper backups of your cluster state through Git.
