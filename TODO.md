# TODO

## Infrastructure Tasks

### Storage & Synchronization
- [ ] **Implement Syncthing with Synology CSI Storage**
  - Create Syncthing application in `kubernetes/apps/default/syncthing/`
  - Configure HelmRelease with OCI repository source
  - Set up persistent storage using Synology CSI driver
  - Configure ingress and external access via Cloudflare Tunnel
  - Add appropriate RBAC and security contexts

### Monitoring & Logging
- [ ] **Implement Loki for Log Aggregation**
  - Create Loki application in `kubernetes/apps/monitoring/loki/`
  - Configure HelmRelease with Grafana Loki chart
  - Set up persistent storage for log retention
  - Configure log shipping from cluster components
  - Integrate with existing Grafana instance for log visualization
