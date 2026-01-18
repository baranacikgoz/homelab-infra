---
description: Deploy a new production application to the homelab cluster
---

# Deploy Application Workflow

This workflow guides you through deploying a new production-grade application to the homelab cluster following all governance standards.

## Prerequisites Checklist

Before starting, verify:
- [ ] Application Docker image supports `linux/arm64` architecture
- [ ] You have determined the appropriate T-Shirt size (Micro/Small/Medium/Large)
- [ ] You know if the app requires persistent storage (PVC)
- [ ] You know if the app needs external access (Ingress)
- [ ] You have identified all required secrets/credentials
- [ ] **Vault Users**: If using HashiCorp Vault for secrets, see [Vault Sidecar Injection](./vault-sidecar-injection.md)

## Step 1: Plan Resource Allocation

Determine the T-Shirt size based on the application type:
- **Micro (128Mi)**: Operators, exporters, sidecars
- **Small (256-512Mi)**: Web APIs, stateless services, Redis
- **Medium (1Gi)**: Kafka, RabbitMQ, Kibana, stateful services
- **Large (1.5Gi MAX)**: Elasticsearch, heavy JVM apps

**CRITICAL**: If the app is Java/JVM-based, you MUST set JVM heap to 50-75% of memory limit.

## Step 2: Create Application Directory Structure

// turbo
```bash
mkdir -p clusters/mac-mini/apps/<app-name>
```

Replace `<app-name>` with your application name (lowercase, hyphens for spaces).

## Step 3: Create Kubernetes Manifests

Create the following files in `clusters/mac-mini/apps/<app-name>/`:

### 3.1: Deployment (`deployment.yaml`)

**MANDATORY REQUIREMENTS**:
- ✅ Resource requests AND limits defined
- ✅ `livenessProbe` configured
- ✅ `readinessProbe` configured
- ✅ `strategy.type: RollingUpdate` (if replicas=1)
- ✅ Secrets referenced via `existingSecret` (NO hardcoded passwords)
- ✅ Config via `ConfigMap` or env vars (NO baked-in config)

**Template**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: <app-name>
  labels:
    app: <app-name>
spec:
  replicas: 1  # Use 2 if RAM permits and app is stateless
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0
      maxSurge: 1
  selector:
    matchLabels:
      app: <app-name>
  template:
    metadata:
      labels:
        app: <app-name>
    spec:
      containers:
        - name: <app-name>
          image: <image>:<tag>
          ports:
            - containerPort: <port>
          env:
            # Reference secrets, NOT hardcoded values
            - name: SECRET_VAR
              valueFrom:
                secretKeyRef:
                  name: <app-name>-secret
                  key: <key>
          resources:
            requests:
              cpu: <cpu-request>
              memory: <memory-request>
            limits:
              cpu: <cpu-limit>
              memory: <memory-limit>
          livenessProbe:
            httpGet:
              path: /health  # or /healthz, /live
              port: <port>
            initialDelaySeconds: 30
            periodSeconds: 10
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /ready  # or /healthz, /health
              port: <port>
            initialDelaySeconds: 10
            periodSeconds: 5
            failureThreshold: 3
```

### 3.2: Service (`service.yaml`)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: <app-name>
spec:
  selector:
    app: <app-name>
  ports:
    - protocol: TCP
      port: 80
      targetPort: <container-port>
```

### 3.3: Ingress (OPTIONAL - `ingress.yaml`)

**ONLY if the app needs external HTTPS access.**

**MANDATORY ANNOTATIONS** (to prevent redirect loops):
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: <app-name>
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "false"
    # Add this if app inspects X-Forwarded-Proto:
    nginx.ingress.kubernetes.io/configuration-snippet: |
      proxy_set_header X-Forwarded-Proto https;
spec:
  rules:
    - host: <subdomain>.baranacikgoz.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: <app-name>
                port:
                  number: 80
```

### 3.4: PersistentVolumeClaim (OPTIONAL - `pvc.yaml`)

**ONLY if the app requires persistent storage.**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: <app-name>-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: <size>Gi
  storageClass: local-path  # OrbStack default
```

### 3.5: ConfigMap (OPTIONAL - `configmap.yaml`)

**For non-sensitive configuration.**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: <app-name>-config
data:
  key: value
```

## Step 4: Create ArgoCD Application Manifest

Create `clusters/mac-mini/apps/<app-name>.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: <app-name>
  namespace: argocd
spec:
  project: default
  source:
    repoURL: git@github.com:baranacikgoz/homelab-infra.git
    targetRevision: main
    path: clusters/mac-mini/apps/<app-name>
  destination:
    server: https://kubernetes.default.svc
    namespace: <namespace>  # Create a dedicated namespace per app
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

## Step 5: Secrets Management

### Option A: Standard Kubernetes Secrets
**NEVER commit secrets to Git.**
If your app uses standard secrets, create them manually:

```bash
kubectl create secret generic <app-name>-secret \
  -n <namespace> \
  --from-literal=key1=value1 \
  --from-literal=key2=value2
```

**OR** add to `scripts/setup-secrets.sh` for automation.

### Option B: Vault-Native Secrets (Recommended Extension)
If this application will consume secrets from HashiCorp Vault (e.g. for .NET WebAPIs), complete the basic deployment here, then follow the **[/vault-sidecar-injection](./vault-sidecar-injection.md)** workflow as a secondary step to enable sidecar injection.

## Step 6: Commit and Push

// turbo
```bash
git add clusters/mac-mini/apps/<app-name>.yaml clusters/mac-mini/apps/<app-name>/
git commit -m "feat: deploy <app-name> to production"
git push origin main
```

## Step 7: Verify Deployment in ArgoCD

1. Open ArgoCD UI: `http://argocd.baranacikgoz.com`
2. Find your application in the list
3. Click **"Sync"** if not auto-synced
4. Wait for **"Healthy"** status

## Step 8: Verify Pod Health

```bash
kubectl get pods -n <namespace>
kubectl describe pod -n <namespace> <pod-name>
kubectl logs -n <namespace> <pod-name>
```

**Expected**:
- Status: `Running`
- Ready: `1/1` (or `N/N` if multiple containers)
- Restarts: `0`

## Step 9: Test Application

### If Ingress is configured:
```bash
curl -I https://<subdomain>.baranacikgoz.com
```

### If internal only:
```bash
kubectl port-forward -n <namespace> svc/<app-name> 8080:80
curl http://localhost:8080
```

## Step 10: Monitor Resource Usage

```bash
kubectl top pod -n <namespace>
```

**If memory usage is near the limit**, increase the limit and redeploy.

## Troubleshooting Guide

### Pod is `Pending`
- **Check**: `kubectl describe pod -n <namespace> <pod-name>`
- **Common causes**: PVC not found, insufficient resources, node selector mismatch

### Pod is `CrashLoopBackOff`
- **Check**: `kubectl logs -n <namespace> <pod-name> --previous`
- **Common causes**: 
  - Exit code 137 = OOMKilled (increase memory limit)
  - Missing environment variables
  - Secret not found

### Pod is `Running` but not `Ready`
- **Check**: Readiness probe is failing
- **Fix**: Adjust `readinessProbe.initialDelaySeconds` or fix the health endpoint

### Ingress returns 502/503
- **Check**: Service selector matches pod labels
- **Check**: `targetPort` matches container port
- **Check**: Pod is `Ready`

### Ingress redirect loop (Safari error)
- **Check**: Ingress annotations include `ssl-redirect: "false"`

## Production Checklist

Before marking deployment as complete:
- [ ] Pod is `Running` and `Ready`
- [ ] Liveness probe is passing
- [ ] Readiness probe is passing
- [ ] Resource limits are set and appropriate
- [ ] No secrets are hardcoded in Git
- [ ] Ingress (if used) is accessible via HTTPS
- [ ] Application logs are clean (no errors)
- [ ] Memory usage is < 80% of limit
- [ ] CPU usage is reasonable
- [ ] ArgoCD shows "Healthy" and "Synced"

## Post-Deployment

1. **Document**: Add application to README or internal docs
2. **Monitor**: Check Grafana dashboards for metrics
3. **Alert**: Configure alerts if critical
4. **Backup**: Ensure PVC backup strategy if stateful

---

**Remember**: This is a PRODUCTION environment. Every deployment must meet the Zero-Tolerance Policies:
1. No Data Loss
2. No Downtime Deployments
3. No Blind Spots
