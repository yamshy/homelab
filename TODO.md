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