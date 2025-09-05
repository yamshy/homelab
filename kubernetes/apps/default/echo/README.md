# Echo Test Service Deployment

This directory contains the HelmRelease and supporting files for deploying a simple HTTP echo service using the `app-template` Helm chart.

## What it deploys

- **Container**: `ghcr.io/mendhak/http-https-echo:37`
- **Port**: 80 (HTTP)
- **Security**: Runs as non-root user (`65534`), read-only root filesystem, all capabilities dropped
- **Health Checks**: Liveness and readiness probes on `/healthz`

## Access

- **Tailscale Ingress**: Exposed internally at `https://echo`
- **Gateway Route**: Exposed externally via HTTPRoute at `echo.${SECRET_DOMAIN}`

## Monitoring

- **ServiceMonitor**: Metrics are scraped from port `http` for Prometheus

