# n8n Deployment

This directory contains the n8n workflow automation tool deployment using the 8gears n8n Helm chart.

## Overview

n8n is a powerful workflow automation tool that allows you to connect and automate tasks between various applications and services. This deployment uses:

- **8gears n8n Helm chart** (version 1.107.4)
- **SQLite database** for data persistence (no external database required)
- **Queue mode with scaling** - 2 worker instances + dedicated webhook instance
- **Internal Redis (Valkey)** for task queuing and coordination
- **Synology CSI storage** for persistent volumes
- **Tailscale LoadBalancer** for secure access within your tailnet

## Configuration

### Required Secrets

Before deploying, you must configure the following secrets in `app/secret.sops.yaml`:

1. **Encrypt the secret file**:

   ```bash
   sops --encrypt -i kubernetes/apps/default/n8n/app/secret.sops.yaml
   ```

2. **Set the required values**:
   - `N8N_ENCRYPTION_KEY`: A secure random string for encrypting n8n data (REQUIRED)

### Optional Configuration

You can also configure:

- Database settings (if using external PostgreSQL instead of SQLite)
- `WEBHOOK_URL`: If using webhooks
- `N8N_BASIC_AUTH_ACTIVE`: Enable basic authentication
- `N8N_BASIC_AUTH_USER`: Basic auth username
- `N8N_BASIC_AUTH_PASSWORD`: Basic auth password

## Architecture

### Scaling Components

This deployment includes n8n's **queue mode** for better performance and scalability:

- **Main Instance**: Handles the web UI and workflow management
- **Worker Instances**: 2 dedicated workers for processing workflow executions
- **Webhook Instance**: Dedicated instance for processing webhooks
- **Redis (Valkey)**: Internal Redis server for task queuing and coordination

## Database Setup

n8n uses **SQLite by default** (no external database required). The data is stored in the persistent volume.

If you want to use PostgreSQL instead:

1. **Use an existing PostgreSQL instance** - Uncomment and configure the database settings in the secret
2. **Deploy PostgreSQL separately** - Consider using a PostgreSQL operator or Helm chart

## Accessing n8n

### Via Tailscale

The n8n web UI is exposed through the Tailscale Kubernetes Operator:

1. **Ensure Tailscale is connected** to your tailnet
2. **Access the service** at: `http://n8n.your-tailnet.ts.net`
3. **MagicDNS** will automatically resolve the hostname

### Service Details

- **Service Type**: LoadBalancer with Tailscale
- **Hostname**: `n8n` (customizable via annotations)
- **Port**: 80
- **Tags**: `tag:automation,tag:internal`

## Storage

- **Storage Class**: `synology-iscsi-delete`
- **Volume Size**: 10Gi
- **Access Mode**: ReadWriteOnce
- **Fallback**: If Synology CSI is unavailable, the chart will use Longhorn

## Resource Limits

- **CPU Limit**: 1000m
- **Memory Limit**: 2Gi
- **CPU Request**: 100m
- **Memory Request**: 512Mi

## Security

- **Non-root execution**: Runs as user 1000
- **Read-only root filesystem**: Disabled (required for n8n)
- **Capabilities**: All capabilities dropped
- **Security context**: Configured for minimal privileges

## Monitoring

The deployment includes health checks:

- **Liveness probe**: `/healthz` endpoint
- **Readiness probe**: `/healthz` endpoint
- **Initial delay**: 30 seconds
- **Check interval**: 10 seconds

## Troubleshooting

### Check Deployment Status

```bash
kubectl get pods -n default -l app.kubernetes.io/name=n8n
kubectl describe pod -n default -l app.kubernetes.io/name=n8n
```

### View Logs

```bash
kubectl logs -n default -l app.kubernetes.io/name=n8n
```

### Check Service

```bash
kubectl get svc -n default n8n
kubectl describe svc -n default n8n
```

### Verify Tailscale Exposure

```bash
kubectl get svc -n default n8n -o yaml | grep -A 5 annotations
```

## Customization

### Modify Hostname

Update the `tailscale.com/hostname` annotation in `helm/values.yaml`:

```yaml
annotations:
  tailscale.com/hostname: "my-custom-n8n"
```

### Add Tags

Update the `tailscale.com/tags` annotation:

```yaml
annotations:
  tailscale.com/tags: "tag:automation,tag:internal,tag:production"
```

### Scale Resources

Modify the resource limits in `helm/values.yaml`:

```yaml
resources:
  limits:
    cpu: 2000m
    memory: 4Gi
  requests:
    cpu: 200m
    memory: 1Gi
```

## Maintenance

### Updates

The deployment will automatically update when:

- The Helm chart version is updated in `helmrelease.yaml`
- The 8gears HelmRepository detects new chart versions

### Backups

- **Database**: SQLite database is stored in the persistent volume
- **Workflows**: n8n workflows are stored in the SQLite database
- **Files**: Any uploaded files are stored in the persistent volume

## References

- [n8n Documentation](https://docs.n8n.io/)
- [8gears n8n Helm Chart](https://github.com/8gears/n8n-helm-chart)
- [Tailscale Kubernetes Operator](https://tailscale.com/kb/1236/kubernetes-operator)
