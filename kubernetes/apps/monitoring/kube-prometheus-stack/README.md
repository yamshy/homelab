# Kube Prometheus Stack (Kubernetes App)

Concise documentation for deploying the Prometheus and Grafana monitoring stack via Flux and the kube-prometheus-stack chart.

## Quick links

- Namespace: `monitoring`
- Flux Kustomization: `kubernetes/apps/monitoring/kube-prometheus-stack/ks.yaml`
- HelmRelease: `kubernetes/apps/monitoring/kube-prometheus-stack/app/helmrelease.yaml`
- Secret (Grafana admin creds, Infisical): `kubernetes/apps/monitoring/kube-prometheus-stack/app/secrets.infisical.yaml`

## Overview

Deploys Prometheus, Grafana, Alertmanager, kube-state-metrics, node-exporter, and Prometheus Operator with Longhorn-backed persistence and ServiceMonitors enabled.

## Workload

- Chart: `kube-prometheus-stack` from OCI `ghcr.io/prometheus-community/charts/kube-prometheus-stack` tag `77.1.1`
- Prometheus retention: 15d, retentionSize: 20GiB; scrape/evaluation interval 30s
- Storage:
  - Prometheus: 20Gi RWO, storageClass `longhorn`
  - Grafana: 10Gi, storageClass `longhorn`
  - Alertmanager: 10Gi, storageClass `longhorn`
- Resources: tuned down for homelab (see HelmRelease values)

## Networking and exposure

- Grafana: LoadBalancer with class `tailscale`, hostname `grafana` (within tailnet)
- Prometheus: ClusterIP
- Alertmanager: ClusterIP

TLS/identity for Grafana is provided by the Tailscale LB; no external gateway is used here.

## Image automation

Not applicable; chart version is pinned via OCI tag.

## Monitoring

- ServiceMonitors enabled for kube components and chart-managed apps.
- Additional scrape configs included for services annotated with prometheus.io/scrape=true.

## Dependencies

- Flux (Helm controller)
- Longhorn storage class available
- Tailscale LoadBalancerClass installed for Grafana exposure
- SOPS/Age for decrypting Grafana admin credentials secret

## Operations

- Reconcile:

  ```sh
  flux reconcile kustomization kube-prometheus-stack -n monitoring
  ```

- Inspect:

  ```sh
  kubectl -n monitoring get helmrelease,deploy,svc,servicemonitor,pod
  ```

- Access Grafana within tailnet:

  - URL: https://grafana
  - Credentials: from secret `grafana-admin-credentials` (userKey: admin-user, passwordKey: admin-password)

## File map

- Kustomization (Flux): `kubernetes/apps/monitoring/kube-prometheus-stack/ks.yaml`
- App manifests: `kubernetes/apps/monitoring/kube-prometheus-stack/app/`
  - HelmRelease: `helmrelease.yaml`
  - Grafana admin secret (Infisical): `secrets.infisical.yaml`
  - Kustomization (kustomize): `kustomization.yaml`
