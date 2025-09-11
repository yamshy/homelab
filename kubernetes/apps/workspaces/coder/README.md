# Coder on Kubernetes (brokered SSH via Tailscale Ingress)

This app deploys the Coder control plane using the official Helm chart and exposes only the web UI via the Tailscale IngressClass. Brokered SSH is used (no direct pod SSH exposure).

## Accessing the UI

1) Ensure the Tailscale operator is installed and managing the `tailscale` IngressClass (already present under apps/network/tailscale in this repo).
2) The hostname is a short name managed by Tailscale. By default this is set to:
   - `ingress.hosts[0].host: coder`
   - `ingress.tls[0].hosts[0]: coder`
   Tailscale will publish this as `coder.<your-tailnet>.ts.net`.
3) Commit and wait for Flux to reconcile.
4) Once the Tailscale operator creates the endpoint, browse to the host from a device in your tailnet.

## Creating a workspace

- Login to the UI and create a workspace from a template.
- Ensure the workspace template uses brokered SSH (default with recent templates).

## Brokered SSH

From your workstation (with the Coder CLI installed and authenticated):

- List workspaces:
  coder list

- SSH into a workspace:
  coder ssh <workspace-name>

No NodePort/LoadBalancer is used. All access is via the control plane and Tailscale ingress to the web UI.

## Notes

- The install uses minimal values and defaults to in-cluster dependencies provided by the chart (suitable for evaluation). For production, consider externalizing PostgreSQL and reviewing persistence settings.
- The service is ClusterIP; only the web UI is exposed through the Tailscale `IngressClass`.