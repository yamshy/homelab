# n8n Deployment

This directory contains the n8n workflow automation tool deployment using the 8gears n8n Helm chart.

## Overview

n8n is a powerful workflow automation tool that allows you to connect and automate tasks between various applications and services. This deployment uses:

- **8gears n8n Helm chart** (version 1.0.14)
- **SQLite database** for data persistence (no external database required)
- **Queue mode with scaling** - 2 worker instances + dedicated webhook instance
- **Internal Redis (Valkey)** for task queuing and coordination
- **Synology CSI storage** for persistent volumes
- **Tailscale Ingress** for secure HTTPS access within your tailnet

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

### Via Tailscale Ingress

The n8n web UI is exposed through the Tailscale Kubernetes Operator using Ingress:

1. **Ensure Tailscale is connected** to your tailnet
2. **Access the service** at: `https://n8n.tail*.ts.net` (HTTPS enabled)
3. **MagicDNS** will automatically resolve the hostname
4. **TLS certificates** are automatically managed by Tailscale

### Service Details

- **Service Type**: ClusterIP (accessed via Ingress)
- **Ingress Class**: tailscale
- **Hostname**: `n8n` (customizable in values.yaml)
- **Ports**: 80 (HTTP), 443 (HTTPS)
- **TLS**: Automatically managed by Tailscale

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

### Check Service and Ingress

```bash
kubectl get svc -n default n8n
kubectl get ingress -n default n8n
kubectl describe ingress -n default n8n
```

### Verify Tailscale Ingress

```bash
kubectl get ingress -n default n8n -o yaml
```

### Check Flux Kustomization

```bash
kubectl get kustomization n8n -n flux-system
kubectl describe kustomization n8n -n flux-system
```

### Common Issues

#### Ingress Configuration Errors

If you see errors like "spec.rules[0].http.paths: Required value", ensure the ingress configuration in `helm/values.yaml` uses the correct format for the 8gears chart:

```yaml
ingress:
  enabled: true
  className: tailscale
  hosts:
    - host: n8n
      paths: ["/"]  # String array, not object array
  tls:
    - hosts:
        - n8n
```

#### Kustomization Stuck on Old Revision

If the kustomization is stuck on an old Git revision:

1. **Suspend the kustomization**:

   ```bash
   flux suspend kustomization n8n -n flux-system
   ```

2. **Clean up resources**:

   ```bash
   kubectl delete helmrelease n8n -n default
   kubectl delete configmap n8n-values -n default
   kubectl delete secret n8n-secrets -n default
   kubectl delete ocirepository 8gears -n default
   ```

3. **Resume the kustomization**:

   ```bash
   flux resume kustomization n8n -n flux-system
   ```

## Customization

### Modify Hostname

Update the hostname in the ingress configuration in `helm/values.yaml`:

```yaml
ingress:
  enabled: true
  className: tailscale
  hosts:
    - host: my-custom-n8n  # Change this
      paths: ["/"]
  tls:
    - hosts:
        - my-custom-n8n  # Change this too
```

### Add Tailscale Tags

Add Tailscale tags by creating a ProxyClass resource or using annotations on the Ingress:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: n8n
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
- [Flux GitOps Documentation](https://fluxcd.io/docs/)

## Deployment Notes

This deployment was successfully tested and resolved the following issues:

1. **Ingress Configuration**: The 8gears n8n Helm chart requires ingress paths to be defined as a string array (`["/"]`) rather than the standard Kubernetes object array format.

2. **Flux Kustomization Sync**: If the kustomization gets stuck on an old Git revision, suspending and resuming the kustomization can break circular dependencies and allow it to process the latest changes.

3. **Health Checks**: The kustomization includes health checks for the n8n Deployment, which ensures proper monitoring of the application status.

The application is accessible at `https://n8n.tail*.ts.net` with automatic TLS certificate management by Tailscale.
