# Homelab Infrastructure

Infrastructure as Code for my Proxmox homelab using OpenTofu and Ansible.

## Overview

This repository manages my homelab infrastructure using:

- **OpenTofu** - Infrastructure provisioning (LXC containers, VMs, networking)
- **Ansible** - Configuration management and application deployment
- **Proxmox VE** - Virtualization platform

## Quick Start

### Prerequisites

- Proxmox VE cluster with API access
- OpenTofu installed (`brew install opentofu` or see [docs](https://opentofu.org/docs/intro/install/))
- SSH key pair (`ssh-keygen -t ed25519`)

### Initial Setup

1. **Clone and configure:**

   ```bash
   git clone <repo-url> homelab
   cd homelab/terraform
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars` with your Proxmox details:**

   ```hcl
   proxmox_api_url = "https://your-proxmox-ip:8006/api2/json"
   proxmox_user    = "terraform@pve"
   proxmox_password = "your-api-token"
   proxmox_node    = "your-node-name"
   ssh_public_key  = "ssh-ed25519 AAAAC3NzaC1..."
   ```

3. **Deploy infrastructure:**

   ```bash
   tofu init
   tofu plan
   tofu apply
   ```

4. **Access your containers:**

   ```bash
   tofu output test_container_ip
   ssh root@<container-ip>
   ```

## Project Structure

```text
homelab/
├── terraform/          # Infrastructure definitions
│   ├── main.tf         # Container resources
│   ├── variables.tf    # Input variables
│   ├── outputs.tf      # Output values
│   └── versions.tf     # Provider requirements
├── ansible/            # Configuration management (coming soon)
└── docs/              # Documentation
```

## Current Services

- **Test Container** - Ubuntu LXC for testing configurations

## Planned Services

- [ ] Pi-hole (DNS filtering)
- [ ] Nginx Proxy Manager (reverse proxy)
- [ ] Grafana + Prometheus (monitoring)
- [ ] Nextcloud (file storage)
- [ ] Plex/Jellyfin (media server)

## Useful Commands

```bash
# Infrastructure
tofu plan                    # Preview changes
tofu apply                   # Apply changes
tofu destroy                 # Destroy infrastructure
tofu output                  # Show outputs

# Debugging
tofu state list             # List managed resources
tofu state show <resource>  # Show resource details
```

## Security Notes

- API tokens and private keys are gitignored
- Only public SSH keys are stored in configuration
- TLS verification disabled for self-signed certificates (homelab only)

## Contributing

This is a personal homelab, but feel free to:

- Open issues for questions or suggestions
- Submit PRs for improvements
- Use this as inspiration for your own setup

## Resources

- [OpenTofu Documentation](https://opentofu.org/docs/)
- [bpg/proxmox Provider](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
- [Proxmox VE Documentation](https://pve.proxmox.com/pve-docs/)
