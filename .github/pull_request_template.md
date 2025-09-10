## PR Title Format

**⚠️ IMPORTANT**: Your PR title must follow conventional commit format as it becomes the squash commit message:

```
type(scope): short imperative summary
```

- **type**: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
- **scope**: optional, e.g., `(network)`, `(storage)`, `(flux)`, `(apps/monitoring)`
- **summary**: lowercase, under 72 chars, imperative mood (e.g., "add", not "adds")

**Examples:**
- `feat(network): add k8s-gateway for DNS resolution`
- `fix(storage): resolve Longhorn volume mount issues`
- `docs(flux): update GitOps deployment guide`
- `chore(deps): bump Cilium to v1.14.5`

## Summary

Describe the change and why it is needed.

## Breaking Changes

If this introduces breaking changes, describe them here and prefix with `BREAKING CHANGE:`:

```
BREAKING CHANGE: description of the breaking change
```

## Checklist

- [ ] PR title follows conventional commit format (validated by CI)
- [ ] I ran `bash scripts/validate.sh` locally from repo root and it passed
- [ ] I updated docs/configuration as needed (including CI) for this change
- [ ] I validated that this change does not break existing behavior
- [ ] Breaking changes are documented above if applicable

## How to test

Provide clear steps or commands for reviewers to reproduce the test results locally.

```bash
# repo-local validation
bash scripts/validate.sh

# flux validation (if applicable)
flux diff --path ./kubernetes/apps/<namespace>/<app>
```

## Additional context

Anything else reviewers should know.
