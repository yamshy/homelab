# Kube Prometheus Stack Deployment

This directory contains the HelmRelease for deploying the Prometheus and Grafana monitoring stack using the `kube-prometheus-stack` chart.

## What it deploys

- **Prometheus** with 15 day retention and Longhorn-backed persistent volumes
- **Grafana** with stored dashboards and credentials from a secret
- **Alertmanager**, **kube-state-metrics**, **node-exporter**, and **Prometheus Operator**
- Service monitors for Kubernetes system components and additional workloads

## Access

- **Grafana** is exposed via a Tailscale `LoadBalancer` at `https://grafana` within the tailnet
- **Prometheus** and **Alertmanager** are internal `ClusterIP` services

## Storage

- All components use the `longhorn` storage class for persistence
