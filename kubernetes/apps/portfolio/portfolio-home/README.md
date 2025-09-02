# Portfolio Application Deployment

This directory contains the HelmRelease and associated configurations for deploying the portfolio application using the bjw-s/app-template Helm chart.

## What it deploys

- **Container**: `ghcr.io/yamshy/portfolio` (Astro static site served by Caddy)
- **Port**: 8080 (internal), exposed on port 80 via service
- **Resources**: 50m CPU, 64Mi memory (requests), 128Mi memory (limits)
- **Security**: Runs as non-root user (65534) with read-only root filesystem

## Exposure

The application is exposed via **Gateway API HTTPRoute** at `${SECRET_DOMAIN}` (root domain) over HTTPS using the existing external gateway in the kube-system namespace.

### Switching to Tailscale LoadBalancer

To switch from Gateway API to Tailscale LoadBalancer, modify the `service` section in `helmrelease.yaml`:

```yaml
service:
  app:
    type: LoadBalancer
    loadBalancerClass: tailscale
    annotations:
      tailscale.com/hostname: portfolio
```

And remove or comment out the `route` section.

## Image Updates

Image tags are updated using **Renovate** with the `helm-values` manager. The image tag is explicitly defined in the HelmRelease values to facilitate automated updates:

```yaml
image:
  repository: ghcr.io/yamshy/portfolio
  tag: latest  # Renovate will update this
```

## Enabling ServiceMonitor

To enable monitoring via ServiceMonitor (compatible with kube-prometheus-stack), set the following in the HelmRelease values:

```yaml
serviceMonitor:
  app:
    enabled: true
    endpoints:
      - port: http
```

## Configuration

- **Namespace**: `portfolio`
- **Chart**: `app-template` from OCIRepository `app-template` (version 4.2.0)
- **Health Checks**: HTTP probes on port 8080, path `/`
- **Security Context**: Non-root user with dropped capabilities and read-only filesystem
