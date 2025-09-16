#!/usr/bin/env bash
set -Eeuo pipefail

source "$(dirname "${0}")/lib/common.sh"

export LOG_LEVEL="debug"
export ROOT_DIR="$(git rev-parse --show-toplevel)"

# Talos requires the nodes to be 'Ready=False' before applying resources
function wait_for_nodes() {
    log debug "Waiting for nodes to be available"

    # Skip waiting if all nodes are 'Ready=True'
    if kubectl wait nodes --for=condition=Ready=True --all --timeout=10s &>/dev/null; then
        log info "Nodes are available and ready, skipping wait for nodes"
        return
    fi

    # Wait for all nodes to be 'Ready=False'
    until kubectl wait nodes --for=condition=Ready=False --all --timeout=10s &>/dev/null; do
        log info "Nodes are not available, waiting for nodes to be available. Retrying in 10 seconds..."
        sleep 10
    done
}

# Namespaces to be applied before the SOPS secrets are installed
function apply_namespaces() {
    log debug "Applying namespaces"

    local -r apps_dir="${ROOT_DIR}/kubernetes/apps"

    if [[ ! -d "${apps_dir}" ]]; then
        log error "Directory does not exist" "directory=${apps_dir}"
    fi

    for app in "${apps_dir}"/*/; do
        namespace=$(basename "${app}")

        # Check if the namespace resources are up-to-date
        if kubectl get namespace "${namespace}" &>/dev/null; then
            log info "Namespace resource is up-to-date" "resource=${namespace}"
            continue
        fi

        # Apply the namespace resources
        if kubectl create namespace "${namespace}" --dry-run=client --output=yaml \
            | kubectl apply --server-side --filename - &>/dev/null;
        then
            log info "Namespace resource applied" "resource=${namespace}"
        else
            log error "Failed to apply namespace resource" "resource=${namespace}"
        fi
    done
}

# Bootstrap secrets to be applied before the helmfile charts are installed
function apply_bootstrap_secrets() {
    log debug "Applying bootstrap secrets"

    local -r universal_auth_secret="${ROOT_DIR}/bootstrap/universal-auth-credentials.yaml"

    # Apply Infisical Universal Auth credentials
    if [ ! -f "${universal_auth_secret}" ]; then
        log error "Universal auth credentials file does not exist" "file=${universal_auth_secret}"
        log error "Please copy bootstrap/universal-auth-credentials.yaml.template to bootstrap/universal-auth-credentials.yaml and fill in your credentials"
        exit 1
    fi

    # Check if the secret resource is up-to-date
    if kubectl --namespace kube-system diff --filename "${universal_auth_secret}" &>/dev/null; then
        log info "Universal auth secret is up-to-date"
    else
        # Apply secret resource
        if kubectl --namespace kube-system apply --server-side --filename "${universal_auth_secret}" &>/dev/null; then
            log info "Universal auth secret applied successfully"
        else
            log error "Failed to apply universal auth secret"
        fi
    fi

    # Apply GitHub app credentials for Flux GitRepository authentication
    local -r github_app_secret="${ROOT_DIR}/bootstrap/github-app-credentials.yaml"
    if [ ! -f "${github_app_secret}" ]; then
        log error "GitHub app credentials file does not exist" "file=${github_app_secret}"
        log error "Please copy bootstrap/github-app-credentials.yaml.template to bootstrap/github-app-credentials.yaml and fill in your credentials"
        exit 1
    fi

    # Check if the GitHub app secret is up-to-date
    if kubectl --namespace flux-system diff --filename "${github_app_secret}" &>/dev/null; then
        log info "GitHub app secret is up-to-date"
    else
        # Apply GitHub app secret
        if kubectl --namespace flux-system apply --server-side --filename "${github_app_secret}" &>/dev/null; then
            log info "GitHub app secret applied successfully"
        else
            log error "Failed to apply GitHub app secret"
        fi
    fi
}

# CRDs to be applied before the helmfile charts are installed
function apply_crds() {
    log debug "Applying CRDs"

    local -r crds=(
        # renovate: datasource=github-releases depName=kubernetes-sigs/external-dns
        https://raw.githubusercontent.com/kubernetes-sigs/external-dns/refs/tags/v0.18.0/config/crd/standard/dnsendpoints.externaldns.k8s.io.yaml
        # renovate: datasource=github-releases depName=kubernetes-sigs/gateway-api
        https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/experimental-install.yaml
        # renovate: datasource=github-releases depName=prometheus-operator/prometheus-operator
        https://github.com/prometheus-operator/prometheus-operator/releases/download/v0.85.0/stripped-down-crds.yaml
    )

    for crd in "${crds[@]}"; do
        if kubectl diff --filename "${crd}" &>/dev/null; then
            log info "CRDs are up-to-date" "crd=${crd}"
            continue
        fi
        if kubectl apply --server-side --filename "${crd}" &>/dev/null; then
            log info "CRDs applied" "crd=${crd}"
        else
            log error "Failed to apply CRDs" "crd=${crd}"
        fi
    done
}

# Sync Helm releases
function sync_helm_releases() {
    log debug "Syncing Helm releases"

    local -r helmfile_file="${ROOT_DIR}/bootstrap/helmfile.yaml"

    if [[ ! -f "${helmfile_file}" ]]; then
        log error "File does not exist" "file=${helmfile_file}"
    fi

    if ! helmfile --file "${helmfile_file}" sync --hide-notes; then
        log error "Failed to sync Helm releases"
    fi

    log info "Helm releases synced successfully"
}

function main() {
    check_env KUBECONFIG TALOSCONFIG
    check_cli helmfile kubectl kustomize yq

    # Apply resources and Helm releases
    wait_for_nodes
    apply_namespaces
    apply_bootstrap_secrets
    apply_crds
    sync_helm_releases

    log info "Congrats! The cluster is bootstrapped and Flux is syncing the Git repository"
}

main "$@"
