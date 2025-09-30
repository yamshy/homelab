#!/usr/bin/env bash
set -Eeuo pipefail

echo "🚀 Setting up Conductor workspace for homelab..."

# Trust mise configuration (required before installing tools)
echo "📝 Trusting mise configuration..."
if ! mise trust; then
  echo "❌ Failed to trust mise configuration"
  exit 1
fi

# Install all development tools via mise
echo "📦 Installing development tools (this may take a few minutes)..."
if ! mise install; then
  echo "❌ Failed to install mise tools"
  exit 1
fi

# Copy essential config files from root repo if they exist
if [ -z "${CONDUCTOR_ROOT_PATH:-}" ]; then
  echo "⚠️  CONDUCTOR_ROOT_PATH not set - skipping config file copying"
  echo "   (This is expected when testing outside of Conductor)"
else
  echo "📋 Copying configuration files from root repository..."

  # Copy age.key for SOPS encryption/decryption
  if [ -f "$CONDUCTOR_ROOT_PATH/age.key" ]; then
    cp "$CONDUCTOR_ROOT_PATH/age.key" ./age.key
    echo "✅ Copied age.key"
  else
    echo "⚠️  age.key not found in root repository (required for SOPS operations)"
  fi

  # Copy kubeconfig for kubectl access
  if [ -f "$CONDUCTOR_ROOT_PATH/kubeconfig" ]; then
    cp "$CONDUCTOR_ROOT_PATH/kubeconfig" ./kubeconfig
    echo "✅ Copied kubeconfig"
  else
    echo "⚠️  kubeconfig not found in root repository (required for kubectl operations)"
  fi

  # Copy talosconfig for Talos operations
  if [ -f "$CONDUCTOR_ROOT_PATH/talos/clusterconfig/talosconfig" ]; then
    mkdir -p talos/clusterconfig
    cp "$CONDUCTOR_ROOT_PATH/talos/clusterconfig/talosconfig" ./talos/clusterconfig/talosconfig
    echo "✅ Copied talosconfig"
  else
    echo "⚠️  talosconfig not found in root repository (required for Talos operations)"
  fi
fi

echo ""
echo "✨ Workspace setup complete!"
echo ""
echo "📚 Available commands:"
echo "  mise run validate  - Validate all Kubernetes manifests"
echo "  task --list        - List all available tasks"
echo "  flux check         - Check Flux status"
echo "  kubectl get pods -A - List all pods"
echo ""
