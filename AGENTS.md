# Repository Guidelines

## Project Structure & Module Organization
Use the GitOps layout to keep apps isolated and reproducible.
- `kubernetes/` holds manifests; apps live under `kubernetes/apps/<namespace>/<app>/` following the Helm + Kustomize scaffold (`app/helm/values.yaml`, `app/kustomization.yaml`, `ks.yaml`).
- Shared building blocks sit in `kubernetes/components/`, while Flux bootstrap configs are under `kubernetes/flux/`.
- Talos machine config lives in `talos/`, scripts in `scripts/`, and vendored CRD schemas in `schemas/`. Task automation is namespaced in `.taskfiles/`.

## Build, Test, and Development Commands
- `mise trust && mise install` installs pinned tooling and wires `KUBECONFIG`, `TALOSCONFIG`, `SOPS_AGE_KEY_FILE`.
- `task bootstrap:talos` provisions Talos configs and bootstraps the cluster.
- `task bootstrap:apps` applies namespaces, secrets, CRDs, then syncs apps.
- `task reconcile` forces Flux to reapply the desired state from this repo.
- `bash scripts/validate.sh` runs kustomize build plus strict kubeconform over all overlays.
- `docker run --rm -v "${PWD}:/workspace" ghcr.io/allenporter/flux-local:v7.10.0 test --enable-helm --all-namespaces --path /workspace/kubernetes/flux/cluster -v` mirrors CI’s diff/tests before pushing.

## Coding Style & Naming Conventions
Follow `.editorconfig`: YAML/JSON two spaces, shells four, Markdown four, LF endings. Use lower-kebab file and directory names (`cloudflare-tunnel`, `k8s-gateway`). Keep Helm values exclusively in `app/helm/values.yaml`, reference via `valuesFrom`, and co-locate chart sources with the `HelmRelease` unless the app already uses the shared `app-template` OCI repository.

## Testing Guidelines
Prefer additive patches and validate locally before every PR. Run `bash scripts/validate.sh` for schema compliance and `flux-local` to catch drift. Inspect rendered manifests with `kustomize build <overlay> | yq e 'del(.sops)' -`. Ensure zero kubeconform errors and clean Flux diffs; rerun after modifying secrets or chart values.

## Commit & Pull Request Guidelines
Commits follow Conventional Commits (`feat(network): add k8s-gateway`). PRs must describe changes, list impacted paths (`kubernetes/apps/...`), explain rationale, link issues, and include relevant screenshots or logs. Require green CI and passing local validation before requesting review.

## Security & Configuration Tips
Commit only SOPS-encrypted secrets (`*.sops.yaml`); keep AGE keys, kubeconfigs, and Talos credentials local. Use the namespace-level secrets pattern: manage shared secrets via `kubernetes/apps/<namespace>/secrets/`, deploy secrets Kustomizations first, and add `spec.dependsOn` from each app to `secrets`. Let Flux orchestrate ordering and avoid plaintext secrets in the repo.

## Operational Notes
- **Storage secrets bundle:** The storage namespace now mirrors the shared-secret pattern (`kubernetes/apps/storage/secrets`). When adding storage apps, depend on that kustomization and reference the rendered secrets via `postBuild.substituteFrom` rather than embedding values directly.
- **Longhorn UI exposure:** Longhorn’s Helm values create a Tailscale ingress (`https://longhorn.${SECRET_TAILNET}`) backed by the shared storage secrets. If the tailnet hostname changes, rotate the value in Infisical so Flux re-renders the ingress and TLS secret reference.
- **Recreate for RWO workloads:** Apps that mount ReadWriteOnce PVCs (e.g., `resume-assistant`) must use the `Recreate` rollout strategy to avoid multi-attach failures during upgrades.
