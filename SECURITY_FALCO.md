# Falco Runtime Security

## Overview

Falco is a runtime security tool that provides real-time threat detection for Kubernetes clusters. It complements static security tools like OPA Gatekeeper by monitoring system calls, Kubernetes API events, and application behavior at runtime to detect suspicious activities and potential security threats.

## What Falco Does

- **System Call Monitoring**: Tracks system calls made by applications and containers
- **Kubernetes API Auditing**: Monitors Kubernetes API events for suspicious activities
- **Rule-Based Detection**: Uses customizable rules to identify potential security threats
- **Real-time Alerting**: Provides immediate notifications when security events are detected
- **Compliance Monitoring**: Helps ensure compliance with security policies and best practices

## Repository Integration

### File Structure

The Falco deployment is organized following the repository's established patterns:

```
kubernetes/apps/security/
├── falco/
│   ├── app/
│   │   ├── helmrelease.yaml    # OCIRepository + HelmRelease definitions
│   │   └── kustomization.yaml  # App-level kustomization
│   └── ks.yaml                 # Flux Kustomization for the app
└── kustomization.yaml          # Category-level kustomization
```

### Flux Integration

- **OCIRepository**: Sources the Falco Helm chart from `oci://ghcr.io/falcosecurity/charts/falco`
- **HelmRelease**: Deploys Falco as a DaemonSet in the `security` namespace
- **Kustomization**: Managed by the main `cluster-apps` Flux Kustomization

## Driver Configuration

### eBPF CO-RE Driver

Falco is configured to use the **eBPF CO-RE (Compile Once - Run Everywhere)** driver, which is ideal for Talos Linux and other locked-down kernel environments:

```yaml
driver:
  kind: modern_bpf
  enabled: true
```

**Why eBPF CO-RE?**
- **No Kernel Modules**: Avoids the need to load kernel modules, which is restricted in Talos Linux
- **Better Performance**: Lower overhead compared to traditional eBPF or kernel module approaches
- **Cross-Kernel Compatibility**: Works across different kernel versions without recompilation
- **Security**: Runs in user space with minimal kernel privileges

## Validation Guide

### 1. Check DaemonSet Status

Verify that Falco is running on all nodes:

```bash
kubectl -n security get ds,pods
```

Expected output should show:
- DaemonSet with `DESIRED`, `CURRENT`, `READY`, and `AVAILABLE` all matching
- Pods running on each node with `STATUS: Running`

### 2. View Falco Logs

Check Falco's runtime logs for events and any issues:

```bash
# View recent logs
kubectl -n security logs -l app.kubernetes.io/name=falco --tail=200

# Follow logs in real-time
kubectl -n security logs -l app.kubernetes.io/name=falco -f
```

### 3. Test Falco Detection (Safe)

To verify Falco is working, you can trigger a benign event that generates a low-severity alert:

```bash
# Create a test pod
kubectl run test-pod --image=busybox --rm -it --restart=Never -- /bin/sh

# Inside the test pod, run a command that might trigger a Falco rule
# (This is safe and won't harm the system)
ls /proc/1/root

# Exit the pod
exit
```

Check the Falco logs to see if the event was detected:

```bash
kubectl -n security logs -l app.kubernetes.io/name=falco --tail=50 | grep -i "proc"
```

### 4. Verify eBPF Driver

Confirm that Falco is using the eBPF driver:

```bash
kubectl -n security logs -l app.kubernetes.io/name=falco | grep -i "driver\|bpf"
```

Look for messages indicating successful eBPF driver initialization.

## Configuration

### Resource Limits

Falco is configured with conservative resource limits suitable for a homelab environment:

```yaml
resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 200m
    memory: 512Mi
```

### Tolerations

Falco is configured to run on all nodes, including control plane nodes:

```yaml
tolerations:
  - key: node-role.kubernetes.io/control-plane
    operator: Exists
    effect: NoSchedule
  - key: node-role.kubernetes.io/master
    operator: Exists
    effect: NoSchedule
```

### Output Configuration

Currently configured for stdout output. To integrate with existing logging systems:

1. **Loki Integration**: Add falcosidekick with Loki output
2. **Prometheus Metrics**: Enable metrics endpoint
3. **Custom Webhooks**: Configure webhook outputs for alerting

## Rule Tuning

### Custom Rules

To add custom rules, create a ConfigMap with your rules and reference it in the HelmRelease values:

```yaml
falco:
  rules_file:
    - /etc/falco/falco_rules.yaml
    - /etc/falco/falco_rules.local.yaml
    - /etc/falco/k8s_audit_rules.yaml
    - /etc/falco/k8s_audit_rules.local.yaml
    - /etc/falco/custom_rules.yaml  # Add your custom rules here
```

### Rule Management

1. **Disable Rules**: Add rules to the `falco_rules_file` exclusion list
2. **Modify Severity**: Override rule priorities in custom rules
3. **Add Custom Rules**: Create new rules for specific use cases

## Integration with Existing Systems

### Monitoring Integration

If you have Prometheus/Grafana deployed:

1. Enable Falco metrics endpoint
2. Add Falco dashboard to Grafana
3. Configure alerting rules in Prometheus

### Logging Integration

If you have centralized logging:

1. Configure falcosidekick for your log aggregation system
2. Set up log parsing and alerting
3. Create dashboards for security events

## Troubleshooting

### Common Issues

1. **Driver Not Loading**: Check kernel compatibility and eBPF support
2. **High Resource Usage**: Adjust resource limits or rule exclusions
3. **False Positives**: Tune rules or add exclusions for known good behavior

### Debug Commands

```bash
# Check Falco configuration
kubectl -n security exec -it <falco-pod> -- falco --print-config

# Test rules
kubectl -n security exec -it <falco-pod> -- falco --list-rules

# Validate configuration
kubectl -n security exec -it <falco-pod> -- falco --validate-config
```

## Security Considerations

- Falco runs with minimal privileges using the `65534` user
- Security contexts are configured following Kubernetes best practices
- RBAC is enabled with least-privilege access
- No sensitive data is stored in plain text

## Maintenance

### Updates

Falco will be automatically updated via Flux when new chart versions are available. The current version is pinned to `3.0.0` for stability.

### Monitoring

Regular monitoring of Falco logs and resource usage is recommended to ensure optimal performance and security coverage.

## References

- [Falco Documentation](https://falco.org/docs/)
- [Falco Helm Chart](https://github.com/falcosecurity/charts/tree/master/falco)
- [eBPF CO-RE Driver](https://falco.org/docs/event-sources/drivers/)
- [Falco Rules](https://github.com/falcosecurity/falco/tree/master/rules)