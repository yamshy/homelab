#!/usr/bin/env bash
set -Eeuo pipefail

source "$(dirname "${0}")/lib/common.sh"

APT_GET="apt-get"
if command -v sudo >/dev/null; then
    APT_GET="sudo ${APT_GET}"
fi

function install_base_packages() {
    log info "Updating apt package index"
    ${APT_GET} update
    log info "Installing base packages"
    ${APT_GET} install -y --no-install-recommends \
        ca-certificates curl git gnupg pipx python3 python3-venv
}

function install_mise() {
    if command -v mise &>/dev/null; then
        log info "mise already installed"
        return
    fi
    log info "Installing mise"
    curl https://mise.jdx.dev/install.sh | sh
    export PATH="${HOME}/.local/bin:${PATH}"
}

function install_tools() {
    log info "Installing required tools with mise"
    mise trust --yes
    mise install
}

function main() {
    install_base_packages
    install_mise
    install_tools

    check_cli git mise task kubectl kustomize kubeconform yq sops flux talhelper helm helmfile jq age
    log info "Tooling setup complete"
}

main "$@"
