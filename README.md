# 🏠 Homelab Kubernetes Infrastructure

![kubeconform](https://img.shields.io/badge/kubeconform-pass-brightgreen)

Welcome to my personal homelab Kubernetes infrastructure repository! This is a production-ready, GitOps-managed Kubernetes cluster built on Talos Linux with Flux for continuous deployment. The cluster demonstrates enterprise-grade reliability and security features in a home environment.

## 🏗️ Architecture Overview

### Cluster Infrastructure
- **Kubernetes Version**: v1.33.4
- **Talos Linux Version**: v1.10.6
- **Cluster Type**: 3-node control plane (highly available)
- **Network**: 192.168.121.0/24 subnet with static IP addressing
- **Load Balancer**: VIP at 192.168.121.10 for control plane access

### Core Components
- **Flux**: GitOps operator for continuous deployment
- **Cilium**: CNI with eBPF-based networking and security policies
- **Longhorn**: Distributed block storage for persistent volumes
- **cert-manager**: Automated TLS certificate management
- **Tailscale**: Secure VPN access and load balancer functionality
- **Cloudflare Tunnel**: Secure external access and DNS management

## 🚀 Deployed Applications

### System Components (`kube-system`)
- **Cilium**: Network CNI with eBPF acceleration
- **CoreDNS**: Cluster DNS resolution
- **Metrics Server**: Kubernetes metrics aggregation
- **Reloader**: Automatic configuration reloading
- **Spegel**: Container image mirroring
- **Generic Device Plugin**: Hardware device exposure for Tailscale

### Network Services (`network`)
- **Cloudflare DNS**: External DNS record management
- **Cloudflare Tunnel**: Secure external access tunnel
- **k8s Gateway**: Kubernetes Gateway API implementation
- **Tailscale Operator**: VPN and load balancer integration

### Storage (`storage`)
- **Longhorn**: Distributed block storage with replication
- **Storage Classes**: Automated volume provisioning

### Applications (`default`)
- **Echo**: HTTP echo service for testing and health checks
- **PostgreSQL**: Database with persistent storage

### Security (`cert-manager`)
- **Cluster Issuer**: Let's Encrypt certificate automation
- **Wildcard Certificates**: Automatic TLS for all subdomains

## 🛠️ Development Environment

### Prerequisites
- **Mise**: Tool version management (`mise install`)
- **Talhelper**: Talos configuration generation
- **SOPS**: Secret encryption/decryption with AGE
- **kubectl**: Kubernetes CLI
- **flux**: Flux CLI for GitOps operations

### Key Commands
```bash
# Install development tools
mise trust
mise install

# Validate manifests locally (uses the mise-managed toolchain)
bash scripts/validate.sh

# Generate Talos configuration
task talos:generate-config

# Bootstrap cluster components
task bootstrap:talos
task bootstrap:apps

# Force Flux reconciliation
task reconcile
```

## ✅ Continuous Integration

This repo enforces schema validation in CI using Kubeconform v0.7.0 in strict mode against Kubernetes 1.33.4. All Kustomize overlays must render valid Kubernetes objects before merge. Encrypted secrets are sanitized to remove SOPS metadata before validation. Cert-manager CRD schemas are sourced from Datree's catalog and vendored locally as a fallback.

## 🔐 Security Features

### Secret Management
- **SOPS Encryption**: All secrets encrypted with AGE encryption
- **Infisical Integration**: Centralized secret management with Kubernetes operator
- **Namespace-Level Secrets**: App-specific secret scoping with principle of least privilege
- **GitOps Security**: No secrets stored in plain text
- **Certificate Automation**: Automatic TLS certificate renewal

#### Namespace-Level Secrets Pattern

This repository implements an enterprise-grade **namespace-level secrets architecture** that eliminates bootstrap dependency issues while enforcing the principle of least privilege:

```
kubernetes/apps/<namespace>/
├── secrets/                    # Centralized namespace secrets
│   ├── ks.yaml                # Secrets Kustomization (deployed first)
│   ├── kustomization.yaml     # Manages all namespace secrets
│   ├── app1-secrets.yaml      # App-specific InfisicalSecret
│   └── app2-secrets.yaml      # App-specific InfisicalSecret
├── app1/
│   └── ks.yaml               # Depends on 'secrets' Kustomization
└── app2/
    └── ks.yaml               # Depends on 'secrets' Kustomization
```

**Key Benefits:**
- 🚫 **No Bootstrap Issues**: Secrets always created before apps need them
- 🔒 **App-Specific Scoping**: Each app only gets secrets it actually uses (87% reduction in exposure)
- 📈 **Scalable**: Easy to add new apps without secret conflicts
- 🧹 **Maintainable**: Single source of truth for namespace secrets
- 🛡️ **Secure**: Principle of least privilege enforced automatically

**Example Implementation (AI Namespace):**
- Resume Assistant: Only gets `OPENAI_API_KEY` + `SECRET_TAILNET`
- Dify: Only gets `DIFY_SECRET_KEY` + `SECRET_TAILNET`
- Deployment Order: `secrets` → `app1` + `app2` (parallel)

### Network Security
- **Cilium Policies**: Network policy enforcement
- **Tailscale Integration**: Secure VPN access
- **Cloudflare Tunnel**: Encrypted external access

### Access Control
- **RBAC**: Role-based access control
- **Service Accounts**: Least privilege principle
- **Security Contexts**: Non-root container execution

## 🌐 Networking Architecture

### Internal Network
- **CIDR**: 10.42.0.0/16 (pods), 10.43.0.0/16 (services)
- **Gateway**: Internal gateway for local network access
- **DNS**: k8s-gateway for internal DNS resolution

### External Access
- **Cloudflare Tunnel**: Secure external access
- **Tailscale LoadBalancer**: VPN-based load balancing
- **External DNS**: Automatic DNS record management

### Load Balancing
- **Type**: LoadBalancer with Tailscale integration
- **Gateway**: Cilium Gateway API implementation
- **TLS**: Automatic certificate management

## 💾 Storage Architecture

### Longhorn Storage
- **Type**: Distributed block storage
- **Replication**: Multi-node data replication
- **Storage Classes**: Automated volume provisioning
- **Backup**: Snapshot and backup capabilities

### Persistent Volumes
- **Default Class**: Longhorn for all persistent storage
- **Dynamic Provisioning**: Automatic volume creation
- **Data Protection**: Built-in replication and snapshots

## 🔧 Cluster Management

### GitOps Workflow
1. **Configuration Changes**: Edit YAML files in Git
2. **Automatic Deployment**: Flux detects and applies changes
3. **Health Monitoring**: Continuous health checks and reconciliation
4. **Rollback**: Git-based rollback capabilities

### Maintenance Operations
```bash
# Check cluster health
flux check
kubectl get pods -A

# Force reconciliation
task reconcile

# View application status
flux get ks -A
flux get hr -A
```

### Troubleshooting
```bash
# Check pod status
kubectl get pods -A --field-selector=status.phase!=Running

# View logs
kubectl logs <pod-name> -n <namespace>

# Check events
kubectl get events -n <namespace> --sort-by='.metadata.creationTimestamp'
```

## 📊 Monitoring & Observability

### Metrics Collection
- **Metrics Server**: Kubernetes resource metrics
- **Service Monitors**: Prometheus-compatible monitoring
- **Health Checks**: Liveness and readiness probes

### Logging
- **Structured Logging**: JSON-formatted application logs
- **Centralized Collection**: Ready for log aggregation systems

## 🚀 Getting Started

### 1. Prerequisites
- 3 physical or virtual machines with minimum 4 cores, 16GB RAM, 256GB storage
- Static IP addresses on your network
- Cloudflare account with domain and API token
- Tailscale account for VPN access

### 2. Initial Setup
```bash
# Clone and configure
git clone <your-repo>
cd homelab

# Install tools
mise trust
mise install

# Generate configuration
task init
# Edit talos/talconfig.yaml and talos/nodes.yaml
task configure
```

### 3. Bootstrap Cluster
```bash
# Install Talos Linux
task bootstrap:talos

# Deploy applications
task bootstrap:apps

# Verify deployment
flux check
kubectl get pods -A
```

## 🔄 Updates & Maintenance

### Talos Updates
```bash
# Update node configuration
task talos:generate-config
task talos:apply-node IP=<node-ip> MODE=auto

# Upgrade Talos version
task talos:upgrade-node IP=<node-ip>
```

### Kubernetes Updates
```bash
# Upgrade cluster version
task talos:upgrade-k8s
```

### Application Updates
- **Update Schedule**: Renovate checks for updates daily
- **Helm Charts**: Automatic updates via Renovate
- **Container Images**: Automated image updates
- **Configuration**: Git-based configuration management

## 🆘 Support & Troubleshooting

### Common Issues
1. **Network Connectivity**: Check Cilium status and network policies
2. **Storage Issues**: Verify Longhorn status and volume health
3. **Certificate Problems**: Check cert-manager logs and cluster issuer status
4. **Flux Sync Issues**: Run `task reconcile` and check Flux status

### Debugging Commands
```bash
# Check component status
cilium status
kubectl -n longhorn-system get pods
kubectl -n cert-manager get certificates

# Verify network connectivity
kubectl get networkpolicies -A
kubectl get gateways -A
```

## 📚 Additional Resources

### Documentation
- [Talos Linux Documentation](https://www.talos.dev/)
- [Flux Documentation](https://fluxcd.io/)
- [Cilium Documentation](https://cilium.io/)
- [Longhorn Documentation](https://longhorn.io/)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Note**: This is my personal homelab environment built for learning and experimentation. The infrastructure demonstrates enterprise-grade Kubernetes practices in a home setting, showcasing skills in GitOps, infrastructure as code, and cloud-native technologies.
