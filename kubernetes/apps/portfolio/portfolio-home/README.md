# Portfolio Home (Kubernetes App)

Concise documentation for the portfolio website deployment managed by Flux and the bjw-s/app-template Helm chart.

## Quick links

- Namespace: `portfolio`
- Flux Kustomization: `kubernetes/apps/portfolio/portfolio-home/ks.yaml`
- HelmRelease: `kubernetes/apps/portfolio/portfolio-home/app/helmrelease.yaml`
- ImageRepository: `kubernetes/apps/portfolio/portfolio-home/app/imagerepository.yaml`
- ImagePolicy: `kubernetes/apps/portfolio/portfolio-home/app/imagepolicy.yaml`

## Overview

Deploys the public portfolio site using the bjw-s/app-template chart. Reconciliation and image automation are handled by Flux.

## Workload

- Controller: `portfolio`
- Container image: `ghcr.io/yamshy/portfolio` (auto-tracked via Flux ImagePolicy, semver `>=2.0.0`)
- Ports:
  - Container: 8080
  - Service: `http` on port 80 → targetPort 8080
- Probes: HTTP GET `/` on port 8080 (liveness/readiness)
- Resources:
  - requests: 50m CPU, 64Mi memory
  - limits: 128Mi memory
- Security:
  - runAsNonRoot: true
  - runAsUser/group: 1001
  - readOnlyRootFilesystem: true
  - allowPrivilegeEscalation: false
  - capabilities: drop ALL

## Networking and exposure

- Exposed via Gateway API HTTPRoute at hostname `${SECRET_DOMAIN}`.
- Gateway parentRef: `external` (namespace: `kube-system`, section: `https-root`).
- TLS is terminated at the external Gateway; backend service listens on port 80.



## Image automation

Flux tracks the container image and updates the HelmRelease `values.controllers.portfolio.containers.app.image.tag` via Image Automation:

- ImageRepository: `ghcr.io/yamshy/portfolio`
- ImagePolicy: semver range `>= 2.0.0`
- HelmRelease tag field contains the JSON annotation:
  - `{"$imagepolicy": "portfolio:portfolio-image-policy:tag"}`

New image tags that satisfy the policy are automatically rolled out.

## Monitoring

ServiceMonitor is disabled by default. To enable (compatible with kube-prometheus-stack):

```yaml
serviceMonitor:
  app:
    enabled: true
    endpoints:
      - port: http
```

## Dependencies

- Flux (Kustomize, Helm, Image Automation controllers)
- Gateway API (Gateway + HTTPRoute CRDs) and an existing external Gateway (`kube-system/external`)
- Network app `cloudflare-tunnel` (HelmRelease dependsOn)

The hostname `${SECRET_DOMAIN}` is injected via Flux postBuild substitution from the `cluster-secrets` Secret (see `ks.yaml`).

## Operations

- Reconcile this app:

  ```sh
  flux reconcile kustomization portfolio -n portfolio
  ```

- Inspect status and resources:

  ```sh
  kubectl -n portfolio get kustomization/portfolio
  kubectl -n portfolio get deploy,svc,httproute,pod
  ```

- Check image automation:

  ```sh
  flux -n portfolio get image repository
  flux -n portfolio get image policy
  ```

## File map

- Kustomization (Flux): `kubernetes/apps/portfolio/portfolio-home/ks.yaml`
- App manifests: `kubernetes/apps/portfolio/portfolio-home/app/`
  - HelmRelease: `helmrelease.yaml`
  - ImageRepository: `imagerepository.yaml`
  - ImagePolicy: `imagepolicy.yaml`
  - Kustomization (kustomize): `kustomization.yaml`
