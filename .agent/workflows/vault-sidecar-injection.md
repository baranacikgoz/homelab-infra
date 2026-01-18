---
description: Deploy a Vault-enabled application with Sidecar Secret Injection
---

# /vault-sidecar-injection: Vault Secret Injection

Use this workflow **after** initializing your app via `/deploy-app`. This extension adds HashiCorp Vault sidecar injection to an existing application deployment.

## Step 1: Initialize Vault Identity (Policy & Role)

Each app needs a unique identity and access policy in Vault.

```bash
# 1.1: Create Policy for the app
kubectl exec -it vault-0 -n vault -- /bin/sh -c 'vault policy write <app-name>-policy - <<EOF
path "apps/data/production/<app-name>/*" {
  capabilities = ["read"]
}
EOF'

# 1.2: Create Kubernetes Auth Role
kubectl exec -it vault-0 -n vault -- vault write auth/kubernetes/role/<app-name>-role \
    bound_service_account_names=<app-name> \
    bound_service_account_namespaces=<namespace> \
    policies=<app-name>-policy \
    ttl=24h
```

## Step 2: Provision Secrets in Vault

Add the production secrets that the app will consume.

```bash
kubectl exec -it vault-0 -n vault -- vault kv put apps/production/<app-name>/config \
    DB_CONNECTION="Host=...;Database=..." \
    API_KEY="super-secret-key"
```

## Step 3: Update Kubernetes Manifests

Add these Vault-specific resources to your `clusters/mac-mini/apps/<app-name>/` directory.

### 3.1: ServiceAccount (`serviceaccount.yaml`)
Vault handles authentication via this ServiceAccount.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: <app-name>
  namespace: <namespace>
```

### 3.2: Add Annotations to `deployment.yaml`
Update your existing `deployment.yaml` template with these annotations. Choose the pattern that matches your app logic.

**Pattern A: JSON (Best for .NET, Node.js)**:
```yaml
metadata:
  annotations:
    vault.hashicorp.com/agent-inject: "true"
    vault.hashicorp.com/role: "<app-name>-role"
    vault.hashicorp.com/agent-inject-secret-secrets.json: "apps/data/production/<app-name>/config"
    vault.hashicorp.com/agent-inject-template-secrets.json: |
      {{- with secret "apps/data/production/<app-name>/config" -}}
      {
        "Vault": {
          {{- $first := true -}}
          {{- range $k, $v := .Data.data -}}
            {{- if not $first -}},{{- end -}}
            "{{ $k }}": "{{ $v }}"
            {{- $first = false -}}
          {{- end -}}
        }
      }
      {{- end -}}
spec:
  template:
    spec:
      serviceAccountName: <app-name> # MUST match ServiceAccount name
```

**Pattern B: Dotenv (Best for Python, Go, PHP)**:
```yaml
metadata:
  annotations:
    vault.hashicorp.com/agent-inject: "true"
    vault.hashicorp.com/role: "<app-name>-role"
    vault.hashicorp.com/agent-inject-secret-config.env: "apps/data/production/<app-name>/config"
    vault.hashicorp.com/agent-inject-template-config.env: |
      {{- with secret "apps/data/production/<app-name>/config" -}}
      {{- range $k, $v := .Data.data -}}
      export {{ $k }}="{{ $v }}"
      {{- end -}}
      {{- end -}}
spec:
  template:
    spec:
      serviceAccountName: <app-name>
```

## Step 4: Configure Application Code

The secrets are mounted at `/vault/secrets/`.

- **.NET**: `builder.Configuration.AddJsonFile("/vault/secrets/secrets.json", optional: true, reloadOnChange: true);`
- **Python**: `load_dotenv("/vault/secrets/config.env")`
- **Node.js**: `const secrets = require('/vault/secrets/secrets.json');`

## Step 5: Finalize and Sync

```bash
git add .
git commit -m "feat(<app-name>): enable vault secret injection"
git push origin main
```

## Step 6: Verify Deployment

Check if the sidecars are injected and the secret file is present.

```bash
# Verify pod status
kubectl get pods -n <namespace> -l app=<app-name>

# Verify secret file content
kubectl exec -it $(kubectl get pod -n <namespace> -l app=<app-name> -o name | head -1) -c <container-name> -n <namespace> -- cat /vault/secrets/secrets.json
```
