# Temporal (Kubernetes App)

Lightweight Temporal deployment that backs the Resume Assistant workflows.

## Quick links

- Namespace: `resume-assistant`
- Flux Kustomization: `kubernetes/apps/resume-assistant/temporal/ks.yaml`
- HelmRelease: `kubernetes/apps/resume-assistant/temporal/app/helmrelease.yaml`
- Chart values: `kubernetes/apps/resume-assistant/temporal/app/helm/values.yaml`

## Overview

This release installs the official Temporal Helm chart with a single replica
and in-cluster PostgreSQL to serve development-grade workflow orchestration for
Resume Assistant. Cassandra is disabled and the Postgres PVC is trimmed to
10Gi to minimise the footprint.

## Operations

- Trigger a reconcile:

  ```sh
  flux reconcile kustomization temporal -n resume-assistant
  ```

- Inspect workloads:

  ```sh
  kubectl -n resume-assistant get helmrelease,pods,svc,ingress
  ```

- Edit chart values and rerun validation:

  ```sh
  $EDITOR kubernetes/apps/resume-assistant/temporal/app/helm/values.yaml
  bash scripts/validate.sh
  ```
