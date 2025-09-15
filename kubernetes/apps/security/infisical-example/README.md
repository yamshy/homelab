# Infisical Example

This is an example InfisicalSecret configuration using Machine Identity with Kubernetes Auth.

## What's Deployed

- **Service Account Token Secret**: Creates a token for the default service account
- **InfisicalSecret**: Syncs secrets from Infisical project `secret-management` (prod environment)

## Configuration

The InfisicalSecret is configured to:
- Use Machine Identity ID: `df0be54b-a540-4045-9689-df826fd4e950`
- Sync from project: `secret-management`
- Environment: `prod`
- Path: `/` (root path, all secrets)
- Create managed secret: `example-managed-secret` in `security` namespace

## Customizing for Your Use Case

To create your own InfisicalSecret:

1. **Copy this example** to a new directory (e.g., `database-secrets`)
2. **Update the configuration**:
   - Change `identityId` if using a different Machine Identity
   - Update `projectSlug` and `envSlug` for your project/environment
   - Set `secretsPath` to a specific path if needed (e.g., `/database`)
   - Change `managedSecretReference.secretName` to your desired secret name
3. **Add to kustomization**: Include the new app in `../kustomization.yaml`

## Verifying the Sync

```bash
# Check InfisicalSecret status
kubectl -n security get infisicalsecrets

# Check the managed secret
kubectl -n security get secret example-managed-secret

# View secret contents (base64 decoded)
kubectl -n security get secret example-managed-secret -o yaml
```

## Troubleshooting

If the sync fails, check:
1. Machine Identity is properly configured in Infisical
2. Kubernetes Auth method has correct cluster details
3. Service account token secret exists
4. Project slug and environment slug are correct
5. Operator logs: `kubectl -n security logs -l app.kubernetes.io/name=secrets-operator`
