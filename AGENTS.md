<general_rules>
## YAML Conventions
- **Use YAML anchors (`&name`) only within the same document** - anchors cannot cross document boundaries separated by `---`
- **Use anchors only when values are repeated multiple times** within the same document - avoid unnecessary anchors for single-use values
- **Follow EditorConfig standards**: 2-space indentation, LF line endings, UTF-8 encoding
- **Include yaml-language-server schemas** for proper validation in YAML files

## Secret Management
- **Encrypt all secrets using SOPS** with age keys defined in `.sops.yaml`
- **Never commit unencrypted secrets** - all sensitive data must be encrypted before committing
- **Use consistent SOPS patterns**: `*.sops.yaml` for encrypted files, store age key in `age.key` file

## Task Automation
- **Use Task for all automation** - run `task --list` to see available commands
- **Key bootstrap commands**:
  - `task bootstrap:talos` - Bootstrap the Talos cluster
  - `task bootstrap:apps` - Deploy applications via helmfile and Flux
  - `task reconcile` - Force Flux to sync from Git repository
- **Talos operations**:
  - `task talos:generate-config` - Generate Talos configuration
  - `task talos:apply-node IP=<node-ip>` - Apply config to specific node
  - `task talos:upgrade-node IP=<node-ip>` - Upgrade Talos on a node

## Validation and Quality
- **Always validate YAML before committing** using `scripts/validate.sh`
- **Run kubeconform validation** for Kubernetes resource validation
- **Check Flux status** with `flux check` before making changes
- **Use pre-commit hooks** if `.pre-commit-config.yaml` exists
</general_rules>

<repository_structure>
## GitOps Architecture
This repository implements a GitOps workflow using Flux for continuous deployment to a Talos Linux Kubernetes cluster.

## Directory Structure
- **`kubernetes/apps/`** - Applications organized by namespace (cert-manager, default, flux-system, kube-system, monitoring, network, portfolio, storage, util)
- **`kubernetes/flux/`** - Flux configuration for GitOps (cluster and meta configurations)
- **`kubernetes/components/`** - Shared Kubernetes components and common resources
- **`talos/`** - Talos Linux cluster configuration managed by talhelper
  - `talconfig.yaml` - Main cluster configuration
  - `patches/` - Node-specific and global configuration patches
  - `clusterconfig/` - Generated Talos configuration files
- **`scripts/`** - Automation scripts for validation and bootstrapping
- **`.taskfiles/`** - Task runner definitions for bootstrap and Talos operations
- **`bootstrap/`** - Initial cluster bootstrap configuration with helmfile
- **`schemas/`** - Custom Kubernetes resource schemas for validation

## Key Technologies
- **Talos Linux** - Immutable Kubernetes OS with 3-node control plane
- **Flux** - GitOps operator for continuous deployment
- **Cilium** - CNI with eBPF networking and security policies
- **Longhorn** - Distributed block storage
- **Tailscale** - Secure VPN access and load balancing
- **Cloudflare Tunnel** - External access and DNS management
</repository_structure>

<dependencies_and_installation>
## Tool Management
- **Mise** manages all development tools and their versions
- **Installation**: Run `mise trust && mise install` to install all required tools
- **Configuration**: `.mise.toml` defines all tool versions and environment variables

## Required Tools
Essential tools automatically installed by Mise:
- **kubectl** (1.33.2) - Kubernetes CLI
- **flux** (2.6.4) - Flux CLI for GitOps operations
- **talosctl** (1.11.0) - Talos Linux CLI
- **sops** (3.10.2) - Secret encryption/decryption
- **helmfile** (1.1.6) - Helm release management
- **kustomize** (5.7.0) - Kubernetes configuration management
- **kubeconform** (0.7.0) - Kubernetes YAML validation
- **talhelper** (3.0.34) - Talos configuration helper
- **yq** (4.47.1) - YAML processing tool

## Environment Setup
- **KUBECONFIG** - Set to `{{config_root}}/kubeconfig`
- **SOPS_AGE_KEY_FILE** - Set to `{{config_root}}/age.key`
- **TALOSCONFIG** - Set to `{{config_root}}/talos/clusterconfig/talosconfig`

## Verification
After installation, verify tools are available:
```bash
which kubectl flux talosctl sops helmfile kustomize kubeconform
```
</dependencies_and_installation>

<testing_instructions>
## YAML Validation
- **Local validation**: Run `scripts/validate.sh` to validate all Kubernetes YAML files
- **Kubeconform**: Validates Kubernetes resources against schemas with strict mode
- **Automated validation**: GitHub Actions run kubeconform on all pull requests
- **Ignored files**: Check `.kubeconformignore` for validation exclusions

## GitOps Testing
- **Flux-local**: GitHub Actions use flux-local for GitOps testing and diff generation
- **Test command**: `flux-local test --enable-helm --all-namespaces --path kubernetes/flux/cluster`
- **Diff generation**: Automatically generates diffs for HelmReleases and Kustomizations in PRs

## Manual Testing Commands
- **Cluster health**: `flux check` - Verify Flux components are healthy
- **Pod status**: `kubectl get pods -A` - Check all pods across namespaces
- **Flux sync status**: `flux get kustomizations` - Check GitOps sync status
- **Talos health**: `talosctl health` - Verify Talos cluster health
- **Network validation**: `cilium status` - Check Cilium CNI status

## Validation Workflow
1. Run `scripts/validate.sh` locally before committing
2. GitHub Actions automatically validate on pull requests
3. Flux-local tests GitOps configurations
4. Manual verification after deployment using health check commands

## Testing Scope
- **Kubernetes YAML validation** against schemas and CRDs
- **Flux GitOps configuration** testing with flux-local
- **Helm chart validation** through helmfile and Flux
- **Network policy and security** validation through Cilium
</testing_instructions>

<pull_request_formatting>
</pull_request_formatting>
