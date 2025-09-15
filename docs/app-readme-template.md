# <App Name> (Kubernetes App)

Concise documentation for deploying <App Name> via Flux.

## Quick links

- Namespace: `<namespace>`
- Flux Kustomization: `kubernetes/apps/<category>/<app>/ks.yaml`
- Primary manifest(s): list key files (HelmRelease, Kustomization, CRs, values)
- Secrets/Config (SOPS): list any sensitive files

## Overview

Brief purpose of the app and how it is managed (Helm/Kustomize, controllers, values source).

## Workload

- Chart/Kind and version (if Helm)
- Key runtime settings (images, ports, probes, resources, persistence)
- Notable CRDs or controllers used

## Networking and exposure

Describe the current exposure method only (IngressClass hostnames, Gateway HTTPRoutes, LoadBalancerClass, etc.). Include TLS termination point if relevant.

## Image automation

If Flux ImageRepository/ImagePolicy are used, describe the policy range and update flow. Otherwise, note N/A.

## Monitoring

Whether ServiceMonitor/PodMonitor are enabled and any key endpoints.

## Dependencies

List prerequisites (CRDs, other apps, secrets, storage classes). Note any Flux postBuild substitutions.

## Operations

- Reconcile:

  ```sh
  flux reconcile kustomization <name> -n <namespace>
  ```

- Inspect:

  ```sh
  kubectl -n <namespace> get <key resources>
  ```

Add any app-specific operational commands if useful.

## File map

List where the important manifests and values live within the repo.