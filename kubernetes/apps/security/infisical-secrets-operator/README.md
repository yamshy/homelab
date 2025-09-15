# Infisical Secrets Operator

This app deploys the Infisical Kubernetes Secrets Operator via a Flux HelmRelease.

What’s installed
- CRDs: InfisicalSecret, InfisicalPushSecret, InfisicalDynamicSecret
- Controller: secrets-operator (pinned app image tag v0.7.5)
- Metrics: ServiceMonitor enabled (if Prometheus Operator is present)

Next steps to start syncing secrets

Option A: Service Token (simple start)
1) Create a service token in Infisical with read access to your project/environment.
2) Create a Kubernetes Secret with the token:
   kubectl -n security create secret generic infisical-service-token --from-literal=infisicalToken=<YOUR_SERVICE_TOKEN>
3) Create an InfisicalSecret to sync into a namespaced Kubernetes Secret:
   apiVersion: secrets.infisical.com/v1alpha1
   kind: InfisicalSecret
   metadata:
     name: example-infisicalsecret
     namespace: security
   spec:
     # For Infisical Cloud, omit hostAPI. For self-hosted, set the API endpoint, e.g.:
     # hostAPI: "http://infisical-backend.infisical.svc.cluster.local:4000/api"
     resyncInterval: 10
     authentication:
       serviceToken:
         serviceTokenSecretReference:
           secretName: infisical-service-token
           secretNamespace: security
     secretsScope:
       envSlug: dev
       secretsPath: "/"
     managedSecretReference:
       secretName: example-managed-secret
       secretNamespace: security

Option B: Kubernetes Auth with Machine Identity (short‑lived tokens)
1) In Infisical, create a Machine Identity and grant it access.
2) Choose a ServiceAccount for the operator to authenticate:
   - Use an existing SA in the target namespace, or create one.
3) Create an InfisicalSecret using kubernetesAuth:
   apiVersion: secrets.infisical.com/v1alpha1
   kind: InfisicalSecret
   metadata:
     name: example-infisicalsecret-k8sauth
     namespace: security
   spec:
     resyncInterval: 10
     kubernetesAuth:
       identityId: "<machine-identity-id>"
       autoCreateServiceAccountToken: true
       serviceAccountTokenAudiences:
         - "infisical"
       serviceAccountRef:
         name: default
         namespace: security
     secretsScope:
       envSlug: dev
       secretsPath: "/"
     managedSecretReference:
       secretName: example-managed-secret
       secretNamespace: security

Verifying the deployment
- Check repo and release:
  flux get sources helm -n security
  flux get hr -n security
- Confirm CRDs:
  kubectl get crd | grep infisical
- Inspect operator:
  kubectl -n security get pods -l app.kubernetes.io/name=secrets-operator

Notes
- HelmRepository is co‑located with the HelmRelease in app/helmrelease.yaml per repo convention.
- All chart values live in app/helm/values.yaml and are wired via valuesFrom.
- If you self‑host Infisical, set spec.hostAPI accordingly in InfisicalSecret resources.
- For production, scope service tokens tightly and prefer Machine Identity (kubernetesAuth) for short‑lived credentials.