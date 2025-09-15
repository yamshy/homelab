# App Documentation Conventions

This repository standardizes per-app documentation to make it easy for humans and automation (e.g., LLMs) to consume. Each app directory under `kubernetes/apps/**` should contain a concise README following the same structure.

## Goals

- Consistent, scannable docs across apps
- Accurate and source-of-truth aligned with manifests
- Minimal but sufficient operational guidance
- AI-friendly section headers and ordering

## Standard sections

Every app README should use these sections in this order:

1) Quick links
   - Namespace, Flux Kustomization path
   - Primary manifests (HelmRelease, values, CRDs, secrets)
2) Overview
   - What the app does and how it’s managed (Helm/Kustomize)
3) Workload
   - Key settings: image/chart, ports, probes, resources, persistence
4) Networking and exposure
   - Only document the current exposure method (IngressClass, Gateway HTTPRoute, LoadBalancerClass)
   - State where TLS terminates if applicable
5) Image automation
   - Describe Flux image automation if used; otherwise “Not applicable”
6) Monitoring
   - ServiceMonitor/PodMonitor state and key metrics ports
7) Dependencies
   - CRDs, other apps, secrets, storage classes
   - Any Flux postBuild substitutions (e.g., `${SECRET_DOMAIN}`)
8) Operations
   - `flux reconcile` and `kubectl get` commands
   - Any app-specific operational notes
9) File map
   - Where manifests and values live

A reusable template is provided at:
- `docs/app-readme-template.md`

## Authoring tips

- Keep it concise and factual; prefer bullets over prose.
- Reflect actual values from manifests (images, ports, hostnames).
- Avoid “future” or “optional switch” instructions; document the current state.
- When exposure or configuration changes, update the README in the same PR.

## Validation in CI

The CI pipeline runs kubeconform with strict mode. Custom CRDs used by example manifests should have schemas under `schemas/<group>/<Kind>_<version>.json`.

Example added:
- `schemas/secrets.infisical.com/InfisicalSecret_v1alpha1.json`

Add more schemas as needed to keep validation strict and green.