# TODO

## Refactoring Tasks

### Longhorn Storage App
- [ ] Refactor `kubernetes/apps/storage/longhorn/` to follow the same pattern as `tailscale` and `kube-prometheus-stack`
- [ ] Remove the `helm/` subfolder structure
- [ ] Move Helm values from `helm/values.yaml` directly into `helmrelease.yaml` under the `values:` section
- [ ] Update `app/kustomization.yaml` to remove ConfigMap generation and kustomizeconfig references
- [ ] This will make the structure consistent with other apps in the repository

### Current Pattern (to follow)
```
kubernetes/apps/<category>/<app-name>/
├── app/
│   ├── helmrelease.yaml          # Contains HelmRelease + OCI Repository + values
│   └── kustomization.yaml        # Simple resource list
├── ks.yaml                       # Flux Kustomization
└── kustomization.yaml            # Category level with namespace
```

### Benefits of Refactoring
- Simpler structure without unnecessary subfolders
- Values are directly visible in the HelmRelease
- Easier to maintain and review
- Consistent with repository conventions
- No need for ConfigMap generation

## Kube-Prometheus-Stack Tailscale Configuration

### Problem
- The kube-prometheus-stack Helm chart service configurations were incorrectly structured
- Original configuration had Prometheus service nested under `prometheus.prometheusSpec.service`
- Chart requires service configurations at component level (e.g., `prometheus.service`, `alertmanager.service`)
- This prevented Tailscale LoadBalancer assignment for Prometheus and Alertmanager services

### What Was Done
- Moved Prometheus service configuration to `prometheus.service` with `type: LoadBalancer` and `loadBalancerClass: tailscale`
- Moved Alertmanager service configuration to `alertmanager.service` with `type: LoadBalancer` and `loadBalancerClass: tailscale`
- Grafana was already correctly configured and working
- Committed changes and Flux reconciled successfully
- Services are now LoadBalancers, waiting for Tailscale operator to assign IPs

### Current Status
- **Grafana**: ✅ Working correctly with Tailscale IP (`100.126.134.71`) and hostname
- **Prometheus**: ❌ Still has old LoadBalancer IP (`192.168.121.2`) instead of Tailscale IP
- **Alertmanager**: ❌ Still has old LoadBalancer IP (`192.168.121.1`) instead of Tailscale IP

### What Was Learned
- The `loadBalancerClass: tailscale` configuration in the HelmRelease is not being applied to the actual services
- Even after multiple Helm upgrades, the services retain their old LoadBalancer IPs
- The kube-prometheus-stack chart may use a different service configuration structure than expected
- Grafana works because it was configured differently or the Tailscale operator automatically detected it

### Next Steps
- Investigate the correct service configuration structure for kube-prometheus-stack chart
- Check if services can be configured using annotations instead of `loadBalancerClass`
- Consider using a different approach or chart configuration method
- Verify that the Tailscale operator is properly configured and working

### What to Check Later
- Verify all services (Grafana, Prometheus, Alertmanager) have Tailscale IPs assigned
- Test accessibility via Tailscale hostnames
- Ensure services are functioning properly with Tailscale LoadBalancers
- Check Tailscale operator logs if IPs are not assigned within expected timeframe

### Login Setup Notes
- [ ] Set up login credentials for Grafana
- [ ] Set up login credentials for Prometheus (if needed)
- [ ] Set up login credentials for Alertmanager (if needed)
- [ ] Document access URLs and credentials securely
