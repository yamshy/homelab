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
- [ ] **Wire Alerting & Escalations**
  - Configure Alertmanager routes to Slack/PagerDuty equivalent
  - Define alert severity levels and ownership runbooks
  - Test notification flow during maintenance windows
- [ ] **Add Distributed Tracing Pipeline**
  - Deploy Tempo or Jaeger in `kubernetes/apps/monitoring/`
  - Instrument critical services with OpenTelemetry collectors
  - Expose traces in Grafana dashboards alongside metrics

### Security & Isolation
- [ ] **Enforce Pod Security Baselines**
  - Enable Pod Security Admission with namespace-level labels (baseline/restricted)
  - Add baseline NetworkPolicy/CiliumNetworkPolicy defaults per namespace
  - Document exemptions for system namespaces and Falco/monitoring workloads
  - Introduce Kyverno or Gatekeeper policies to prevent drift on security controls

### Resilience & Backups
- [ ] **Enable Longhorn Snapshots & NAS Backups**
  - Configure recurring Longhorn snapshots for stateful workloads
  - Point Longhorn backup target at an existing Synology share
  - Periodically verify restore of a sample PVC in a staging namespace
- [ ] **Automate Talos etcd Snapshots**
  - Schedule `talosctl snapshot etcd` via Taskfile or CronJob
  - Sync archives to NAS/offline storage with retention policy
  - Document cluster restore procedure and test quarterly
- [ ] **Deploy Velero with Restic**
  - Scaffold Velero HelmRelease under `kubernetes/apps/storage/velero/`
  - Use Synology object/NFS storage for backup repository to avoid cloud spend
  - Back up key namespaces and validate namespace-level recoveries

### Release Safety & Supply Chain
- [ ] **Add Image Scanning to CI**
  - Integrate Trivy/Grype scans in GitHub Actions before Flux deployment
  - Block merges on high-severity CVEs for application images
  - Surface results in PR comments for visibility
- [ ] **Gate Deploys with flux-local & Chaos Tests**
  - Require `flux-local test` as a pre-merge Taskfile/CI job
  - Introduce Litmus or similar chaos experiments for critical services
  - Automate rollback validation after chaos scenarios

### Platform Services & Access
- [ ] **Automate Secret Rotation Alerts**
  - Extend Infisical integrations to page on expiring/rotated secrets
  - Ensure namespace-level substituteFrom references stay in sync
  - Record rotation SOPs in `docs/`
- [ ] **Harden External Exposure**
  - Integrate external-dns/Cloudflare with WAF rules for public hosts
  - Automate cert issuance/renewal across ingress controllers
  - Audit ingress annotations for consistent security headers

### Operations & SRE Practice
- [ ] **Define SLOs and Incident Runbooks**
  - Capture availability/error budget targets per service
  - Author runbooks for common Falco/prometheus alerts
  - Store runbooks alongside app READMEs for quick access
- [ ] **Deploy Synthetic Monitoring**
  - Add Blackbox exporter or Tailscale probes for key endpoints
  - Feed probe results into Alertmanager and Grafana
  - Simulate tailnet outages to confirm alert fidelity
- [ ] **Configure Autoscaling Policies**
  - Apply HPAs for user-facing workloads based on metrics
  - Evaluate Vertical Pod Autoscaler for system services
  - Document resource tuning process in repo
