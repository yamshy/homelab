# Falco Runtime Security

Falco is a CNCF project that provides runtime threat detection for Kubernetes. It complements policy enforcement tools like OPA Gatekeeper by monitoring system calls and Kubernetes audit events to detect suspicious behavior at run time.

## Deployment

Falco is deployed via Flux using the official Helm chart:

- Namespace: `security`
- Manifests: `kubernetes/apps/security/falco`
- Helm source: `HelmRepository` `falco` within `app/helmrelease.yaml`
- Flux Kustomization: `kubernetes/apps/security/falco/ks.yaml`
- Chart version: `6.2.5`
- Driver: `modern_ebpf` (CO-RE eBPF) to avoid kernel modules and work with Talos-style locked-down kernels.

## Validation

1. Confirm DaemonSet and Pods:

   ```sh
   kubectl -n security get ds,pods
   ```

2. Inspect recent events:

   ```sh
   kubectl -n security logs -l app.kubernetes.io/name=falco --tail=200
   ```

3. Optional safe trigger (non-disruptive):

   ```sh
   kubectl run -n default falco-test --rm -it --image=busybox -- sh -c 'cat /etc/shadow' || true
   ```

   This reads a sensitive file, generating a low-severity Falco alert.

## Tuning

- Modify `kubernetes/apps/security/falco/app/helm/values.yaml` to adjust resources, tolerations, or Falco rules.
- Custom rules can be added via `falco.rules` entries or by mounting additional rule files (see chart docs).
- Falco logs to stdout by default; integrate with existing logging stacks by updating Helm values if desired.
