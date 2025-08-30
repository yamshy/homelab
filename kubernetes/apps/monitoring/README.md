# Monitoring Stack

This directory contains the monitoring and observability components for the homelab Kubernetes cluster.

## Components

### Kube Prometheus Stack

The [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) provides a complete monitoring solution including:

- **Prometheus**: Metrics collection and storage
- **Grafana**: Metrics visualization and dashboards
- **Alertmanager**: Alert routing and notification
- **Prometheus Operator**: Kubernetes-native monitoring
- **Node Exporter**: Host metrics collection
- **Kube State Metrics**: Kubernetes cluster metrics

## Configuration

### Storage

All components use Longhorn for persistent storage:
- Prometheus: 50Gi for metrics storage
- Grafana: 10Gi for dashboards and configuration
- Alertmanager: 10Gi for alert history

### Resource Limits

Components are configured with appropriate resource limits for homelab environments:
- Prometheus: 256Mi-1Gi memory, 100m-500m CPU
- Grafana: 128Mi-512Mi memory, 100m-300m CPU
- Alertmanager: 64Mi-256Mi memory, 50m-200m CPU

### Monitoring

The stack automatically discovers and monitors:
- Kubernetes system components
- Applications with ServiceMonitor annotations
- Node metrics via Node Exporter
- Kubelet metrics

## Access

### Grafana

Grafana is accessible via port-forward:
```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
```

Default credentials:
- Username: `admin`
- Password: `admin`

### Prometheus

Prometheus is accessible via port-forward:
```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
```

## Service Discovery

To enable monitoring for your applications, add these annotations to your services:

```yaml
metadata:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8080"
    prometheus.io/path: "/metrics"
```

## Dashboards

The stack includes pre-configured dashboards for:
- Kubernetes cluster overview
- Node metrics
- Pod metrics
- Cluster capacity planning

## Alerts

Default alerting rules are configured for:
- High resource usage
- Pod restart frequency
- Node availability
- Storage capacity

## Troubleshooting

### Check Component Status

```bash
# Check all monitoring components
kubectl get pods -n monitoring

# Check HelmRelease status
flux get hr -n monitoring

# Check Kustomization status
flux get ks -n monitoring
```

### View Logs

```bash
# Prometheus logs
kubectl logs -n monitoring -l app.kubernetes.io/name=prometheus

# Grafana logs
kubectl logs -n monitoring -l app.kubernetes.io/name=grafana

# Alertmanager logs
kubectl logs -n monitoring -l app.kubernetes.io/name=alertmanager
```

### Storage Issues

If you encounter storage issues:
1. Check Longhorn volume status
2. Verify PVC bindings
3. Check storage class configuration

## Upgrades

The stack is managed by Flux and will automatically upgrade when:
1. New chart versions are available
2. Values are updated in the repository
3. Flux reconciliation runs

Monitor upgrades with:
```bash
flux get hr kube-prometheus-stack -n monitoring
kubectl get pods -n monitoring -w
```
