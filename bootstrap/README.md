# Bootstrap Guide

This directory contains the necessary components to bootstrap the homelab cluster.

## Prerequisites

Before running the bootstrap process, you need to create two credential files:

### 1. Create Universal Auth Credentials

Copy the template and fill in your actual Infisical credentials:

```bash
cp universal-auth-credentials.yaml.template universal-auth-credentials.yaml
```

Edit `universal-auth-credentials.yaml` and replace the placeholder values:
- `YOUR_INFISICAL_CLIENT_ID_HERE` - Your Infisical Universal Auth Client ID
- `YOUR_INFISICAL_CLIENT_SECRET_HERE` - Your Infisical Universal Auth Client Secret

### 2. Create GitHub App Credentials

Copy the template and fill in your actual GitHub App credentials:

```bash
cp github-app-credentials.yaml.template github-app-credentials.yaml
```

Edit `github-app-credentials.yaml` and replace the placeholder values:
- `YOUR_GITHUB_APP_ID_HERE` - Your GitHub App ID
- `YOUR_GITHUB_APP_INSTALLATION_ID_HERE` - Your GitHub App Installation ID
- `YOUR_GITHUB_APP_PRIVATE_KEY_HERE` - Your GitHub App Private Key (including the full PEM content)

> **⚠️ Important**: Both credential files are gitignored and should never be committed to the repository.

### 3. Getting Infisical Universal Auth Credentials

To obtain these credentials:

1. Go to your Infisical project settings
2. Navigate to "Access Control" → "Machine Identities"
3. Create or use an existing Universal Auth identity
4. Copy the Client ID and Client Secret

### 4. Getting GitHub App Credentials

To obtain these credentials:

1. Go to your GitHub App settings (GitHub → Settings → Developer settings → GitHub Apps)
2. Find your app and note the App ID
3. Go to "Install App" and note the Installation ID from the URL
4. Generate and download a private key from the app settings

### 5. Bootstrap the Cluster

Once both credential files are created, run the bootstrap:

```bash
task bootstrap:apps
```

## Files

- `helmfile.yaml` - Core infrastructure Helm releases
- `universal-auth-credentials.yaml.template` - Template for Infisical credentials
- `github-app-credentials.yaml.template` - Template for GitHub App credentials
- `universal-auth-credentials.yaml` - Your actual Infisical credentials (gitignored)
- `github-app-credentials.yaml` - Your actual GitHub App credentials (gitignored)
- `README.md` - This documentation