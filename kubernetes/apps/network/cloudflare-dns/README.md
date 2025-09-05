# Cloudflare DNS (ExternalDNS)

This directory contains the HelmRelease for deploying [ExternalDNS](https://github.com/kubernetes-sigs/external-dns) configured to manage DNS records in Cloudflare for the cluster.

## What it does

- Uses the `external-dns` Helm chart (version 1.18.0)
- Updates Cloudflare DNS records for `${SECRET_DOMAIN}`
- Sources records from Gateway `HTTPRoute` resources and `DNSEndpoint` CRDs
- Publishes TXT ownership records with the `k8s.` prefix and `default` owner ID
- Exposes metrics via a `ServiceMonitor`

## Secrets

ExternalDNS requires a Cloudflare API token stored in the encrypted secret at `app/secret.sops.yaml`:

- **Secret name:** `cloudflare-dns-secret`
- **Key:** `api-token`

Ensure the secret is encrypted with SOPS before committing changes.

## Monitoring

Prometheus metrics are enabled through the `ServiceMonitor` configuration, allowing visibility into sync status and errors.
