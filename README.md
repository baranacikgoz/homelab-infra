# 🏡 Homelab Infrastructure: Big Tech Simulation

> **Intentional Overengineering: Enterprise-Grade GitOps Patterns for the Curious SRE**

A high-fidelity **Big Tech Stack Simulation** demonstrating enterprise-grade DevOps practices on residential hardware. This repository is intentionally overengineered (for a homelab) to practice managing production-scale complexity within the tight constraints of a home server, prioritizing **Data Integrity > Uptime > New Features**.

This repository is **platform-agnostic** - while I deployed it on a Mac Mini M4, the patterns and practices are designed to be portable to any Kubernetes environment.

[![GitOps](https://img.shields.io/badge/GitOps-Enabled-blue)](https://www.gitops.tech/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Platform_Agnostic-326CE5)](https://kubernetes.io/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 📋 Table of Contents

- [Overview](#-overview)
- [The Philosophy of Intentional Overengineering](#-the-philosophy-of-intentional-overengineering)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Getting Started](#-getting-started)
- [Deployed Applications](#-deployed-applications)
- [Governance & Standards](#-governance--standards)
- [Monitoring & Observability](#-monitoring--observability)
- [Troubleshooting](#-troubleshooting)
- [License](#-license)

---

---

## 🎯 Overview

This repository showcases **production-grade infrastructure patterns** that bring enterprise DevOps standards to homelab environments. It is more than just a setup; it is a **simulated production environment** designed for learning how to manage complex, stateful systems at scale.

### What Makes This Different?

Most homelab tutorials focus on "getting things running." This project focuses on **getting things right** by simulating the challenges of a Big Tech infrastructure:

- 🏗 **Production Patterns at Scale-Down**: Enterprise practices (GitOps, health checks, resource limits) adapted for resource-constrained environments.
- 📜 **Governance-First**: Every deployment follows documented standards (see [`.agent/rules/00-devops-governance.md`](.agent/rules/00-devops-governance.md)).
- 🔒 **Security by Design**: No secrets in Git, secrets management with external Kubernetes Secrets.
- 🎯 **Resource Management**: T-Shirt sizing system for predictable capacity planning.
- 📊 **Full Observability**: Prometheus + Grafana + ELK stack integrated from day one.
- 🚫 **Zero-Downtime Philosophy**: Rolling updates with health checks, even on single-node clusters.

## 🧠 The Philosophy of Intentional Overengineering

Why run Kafka, Elasticsearch, and a full GitOps pipeline for a handful of home services? 

1. **Exposure to Scale Concepts**: While a homelab isn't a replacement for production-at-scale, this repository provides a playground to explore concepts like Kafka partition balancing, Elasticsearch heap management, and ArgoCD sync waves—complexities and etc. rarely encountered in simpler setups.
2. **Constraint-Driven Excellence**: Running a "heavy" stack on a resource limited home server forces disciplined resource management. If it works here with tight limits, it will fly in the cloud.
3. **Infrastructure as Code (IaC) Mastery**: By treating a homelab as a mission-critical production environment, we build the muscle memory required for professional SRE roles.
4. **Learning through Complexity**: The goal isn't just to host apps; it's to learn how to fix them when they break under the weight of their own complexity.

### My Current Deployment

This infrastructure is currently running on:
- **Hardware**: Mac Mini M4 (16GB RAM, Apple Silicon/ARM64)
- **Virtualization**: OrbStack (lightweight Kubernetes for macOS)
- **External Access**: Cloudflare Tunnel (zero router port-forwarding)

**But you can deploy this on**:
- ☁️ Cloud providers (GKE, EKS, AKS, DO Kubernetes)
- 🖥 On-premise servers (bare metal, Proxmox, VMware)
- 🍓 Raspberry Pi clusters (ARM64)
- 🐧 Linux workstations (K3s, MicroK8s, kind)
- 🪟 Windows with WSL2 (Docker Desktop, Rancher Desktop)

The **practices are universal**. The manifests are adaptable.

### Key Features

- ✅ **100% GitOps**: All changes go through Git. No `kubectl apply` in production.
- ✅ **Declarative Everything**: Infrastructure, applications, and configuration as code.
- ✅ **Resource-Aware**: Designed to run efficiently on constrained hardware.
- ✅ **Zero-Downtime Deployments**: Rolling updates with health checks on all services.
- ✅ **Secure by Default**: No secrets in Git. External secret management.
- ✅ **Observable**: Full metrics, logs, and dashboards from the start.
- ✅ **Documented Governance**: Every architectural decision is documented and enforced.

---

---

## 🏗 Architecture

This is a **layered architecture** following cloud-native best practices, adaptable to any Kubernetes distribution.

```
┌─────────────────────────────────────────────────────────────┐
│                     External Access Layer                    │
│       HTTPS Ingress (Cloudflare/Nginx/LoadBalancer)         │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                        │
│                  (Any Distribution: OrbStack,                │
│                K3s, MicroK8s, GKE, EKS, etc.)                │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              GitOps Control Plane                      │  │
│  │              (ArgoCD)                                  │  │
│  │  - Declarative deployments from Git                   │  │
│  │  - Auto-sync enabled                                  │  │
│  │  - Self-healing enabled                               │  │
│  │  - App-of-Apps pattern                                │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                               │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Infrastructure Layer                      │  │
│  │  - Ingress Controller (Nginx)                         │  │
│  │  - Metrics Server                                     │  │
│  │  - External Access (Cloudflared/LoadBalancer)         │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                               │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Data Layer                                │  │
│  │  - Redis (Cache)                                      │  │
│  │  - PostgreSQL (CNPG Operator)                         │  │
│  │  - MinIO (S3-compatible Object Storage)               │  │
│  │  - Kafka (Strimzi Operator)                           │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                               │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Observability Layer                       │  │
│  │  - Prometheus (Metrics Collection)                    │  │
│  │  - Grafana (Visualization)                            │  │
│  │  - ECK Stack (Logging: Elasticsearch/Kibana)          │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                               │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Application Layer                         │  │
│  │  - Vaultwarden (Password Manager)                     │  │
│  │  - RedisInsight (Redis UI)                            │  │
│  │  - Your custom applications                           │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Traffic Flow

1. **External Request**: User → `https://app.example.com`
2. **Ingress Layer**: Terminates TLS (or receives HTTP from tunnel), routes to Service
3. **Service**: Load balances to healthy Pods
4. **Pod**: Application container responds

### My Implementation Details

In my Mac Mini M4 deployment:
- **Ingress**: Cloudflare Tunnel (HTTPS/443) → Nginx Ingress (HTTP/80)
- **Storage**: OrbStack's local-path provisioner
- **Resource Constraints**: 12-14GB RAM allocation (with aggressive limits)

**For your deployment**, adapt:
- **Ingress**: Use cloud provider LoadBalancer, cert-manager + Let's Encrypt, or NodePort
- **Storage**: Use your cluster's default StorageClass or NFS
- **Resource Constraints**: Adjust T-Shirt sizes based on your available resources

---

---

## 🛠 Tech Stack

### Core Technologies (Universal)
- **GitOps**: [ArgoCD](https://argoproj.github.io/cd/) - Declarative continuous deployment
- **Ingress**: [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/) - HTTP/HTTPS routing
- **Metrics**: [Metrics Server](https://github.com/kubernetes-sigs/metrics-server) - Resource usage (`kubectl top`)

### Data & Messaging (The Simulation Core)
These tools are chosen specifically to simulate the complexity of a Big Tech data plane, providing hands-on experience with production-grade operators.

- **Cache**: [Redis](https://redis.io/) - In-memory data store for performance critical paths.
- **Database**: [PostgreSQL](https://www.postgresql.org/) via [CloudNativePG Operator](https://cloudnative-pg.io/) - Enterprise-grade SQL management.
- **Object Storage**: [MinIO](https://min.io/) - S3-compatible storage for cloud-native applications.
- **Message Queue**: [Apache Kafka](https://kafka.apache.org/) via [Strimzi Operator](https://strimzi.io/) - The gold standard for event-driven architectures.

### Observability
- **Metrics**: [Prometheus](https://prometheus.io/) - Time-series metrics collection
- **Visualization**: [Grafana](https://grafana.com/) - Dashboards and alerting
- **Logging**: [Elastic Stack](https://www.elastic.co/elastic-stack) via [ECK Operator](https://www.elastic.co/eck) - Log aggregation

### Applications (Examples)
- **Secret Management**: [HashiCorp Vault](https://www.vaultproject.io/) - Enterprise-grade secret storage and management.
- **Password Manager**: [Vaultwarden](https://github.com/dani-garcia/vaultwarden) - Bitwarden-compatible
- **Redis GUI**: [RedisInsight](https://redis.io/insight/) - Redis management UI

### My Implementation (Mac Mini M4)

In my specific deployment, I also use:
- **Host**: macOS with [OrbStack](https://orbstack.dev/) - Lightweight Docker + K8s for Mac
- **External Access**: [Cloudflare Tunnel](https://www.cloudflare.com/products/tunnel/) - Zero-trust HTTPS without port-forwarding

**For your setup**, substitute:
- **Kubernetes**: Any distribution (K3s on Linux, managed K8s on cloud, etc.)
- **External Access**: Cloud LoadBalancer, nginx with Let's Encrypt, or port-forwarding

---

---

## ✅ Prerequisites

### Required (Platform-Agnostic)
- **Kubernetes Cluster**: Any distribution with 1.24+ (K3s, MicroK8s, kind, OrbStack, GKE, EKS, AKS, etc.)
- **kubectl**: CLI tool to interact with Kubernetes
- **Git**: Version control system
- **Minimum Resources**: 8GB RAM, 20GB disk space (adjust based on which applications you deploy)

### Optional but Recommended
- **Ingress Solution**: For external HTTPS access
  - Cloud: LoadBalancer + cert-manager
  - On-prem: Nginx Ingress + Let's Encrypt
  - Homelab: Cloudflare Tunnel (zero port-forwarding)
- **Persistent Storage**: StorageClass with dynamic provisioning (for stateful apps)
- **Git Hosting**: GitHub/GitLab account to fork and customize this repo

---

---

## 🚀 Getting Started

This guide shows the universal setup process. Platform-specific examples are provided for common environments.

### 1. Prepare Your Kubernetes Cluster

You need a running Kubernetes cluster. Choose your platform:

<details>
<summary><b>Mac (OrbStack) - My Setup</b></summary>

```bash
# Install OrbStack
brew install --cask orbstack

# Enable Kubernetes in OrbStack settings
# or via CLI:
orb k8s start

# Verify cluster
kubectl cluster-info
kubectl get nodes
```

**Configure Resources** (OrbStack Settings):
- Memory: 12-14GB (for 16GB Mac)
- CPU: 4-6 cores
- Disk: 50GB+

</details>

<details>
<summary><b>Linux (K3s) - Lightweight Production</b></summary>

```bash
# Install K3s (single node)
curl -sfL https://get.k3s.io | sh -

# Copy kubeconfig
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER ~/.kube/config

# Verify
kubectl get nodes
```

</details>

<details>
<summary><b>Cloud (GKE/EKS/AKS) - Managed Kubernetes</b></summary>

**Google Kubernetes Engine (GKE)**:
```bash
gcloud container clusters create homelab \
  --num-nodes=3 \
  --machine-type=e2-medium \
  --region=us-central1
```

**Amazon EKS**:
```bash
eksctl create cluster \
  --name homelab \
  --region us-east-1 \
  --nodegroup-name standard \
  --node-type t3.medium \
  --nodes 3
```

**Azure AKS**:
```bash
az aks create \
  --resource-group homelab-rg \
  --name homelab \
  --node-count 3 \
  --node-vm-size Standard_B2s
```

</details>

<details>
<summary><b>Windows (Docker Desktop / Rancher Desktop)</b></summary>

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) or [Rancher Desktop](https://rancherdesktop.io/)
2. Enable Kubernetes in settings
3. Verify: `kubectl get nodes`

</details>

---

### 2. Install kubectl (if not already installed)

```bash
# macOS
brew install kubectl

# Linux (Debian/Ubuntu)
sudo apt-get update && sudo apt-get install -y kubectl

# Linux (RHEL/CentOS)
sudo yum install -y kubectl

# Windows (Chocolatey)
choco install kubernetes-cli

# Or download binary directly
# https://kubernetes.io/docs/tasks/tools/
```

Verify installation:
```bash
kubectl version --client
```

---

### 3. Bootstrap ArgoCD

ArgoCD is the GitOps engine that manages all deployments.

```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD (latest stable)
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

**Access ArgoCD UI** (choose one method):

**Option A: Port Forward** (Quick Test)
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Open: http://localhost:8080
# Username: admin
# Password: <from command above>
```

**Option B: Ingress** (Production)
- Configure Ingress (see repo examples in `clusters/mac-mini/apps/argocd-config/`)
- Access via your domain (e.g., `https://argocd.baranacikgoz.com`)

---

### 4. Create Secrets

**CRITICAL**: This step must be completed before deploying applications that require credentials.

```bash
# Clone this repository (or your fork)
git clone https://github.com/baranacikgoz/homelab-infra.git
cd homelab-infra

# Generate all required secrets
chmod +x scripts/setup-secrets.sh
./scripts/setup-secrets.sh
```

This script generates strong random passwords for:
- **Redis** (`database/redis-secret`)
- **MinIO** (`minio/minio-secret`)
- **Grafana** (`monitoring/grafana-secret`)
- **Vaultwarden** (`vaultwarden/vaultwarden-secret`)

**⚠️ SAVE THE OUTPUT**: The passwords are shown only once. Store them in a password manager.

---

### 5. Deploy Applications

#### 5.1: Bootstrap the App-of-Apps Pattern

This single command deploys the entire infrastructure:

```bash
kubectl apply -f clusters/mac-mini/bootstrap-app.yaml
```

**What happens**:
1. ArgoCD reads `bootstrap-app.yaml`
2. It recursively discovers all application manifests in `clusters/mac-mini/apps/`
3. Each app is deployed in the correct order (based on `sync-wave` annotations)
4. ArgoCD continuously monitors Git for changes and auto-syncs

#### 5.2: Verify Deployment

```bash
# Watch ArgoCD sync progress
kubectl get applications -n argocd -w

# Expected output (after ~5 minutes):
# NAME                SYNC STATUS   HEALTH STATUS
# bootstrap-apps      Synced        Healthy
# ingress-nginx       Synced        Healthy
# metrics-server      Synced        Healthy
# redis               Synced        Healthy
# monitoring          Synced        Healthy
# ...
```

#### 5.3: Verify Pods

```bash
# Check all pods are running
kubectl get pods -A

# Expected: All pods in "Running" status with 0 restarts
```

---
---

## ⚠️ Security Warning: Public Endpoints

> [!CAUTION]
> **This repository exposes several administrative interfaces to the public internet by default.**
>
> While the infrastructure is defined to handle traffic routing and TLS termination, **application-level authentication is YOUR responsibility**.
>
> 1. **Zero Trust is Mandatory**: If you follow the provided Ingress patterns, you MUST protect your hostnames (e.g., `*.yourdomain.com`) using a solution like **Cloudflare Zero Trust (Email OTP / Service Tokens)** or **Authelia**.
> 2. **No Default Auth**: Some applications (like Prometheus or MinIO Console) may not have robust authentication enabled by default in their base configurations.
> 3. **API Protection**: Be careful when applying Zero Trust to API endpoints (like `minio.baranacikgoz.com`) as it may break S3 clients unless Service Tokens are used.

---

---

## 📦 Deployed Applications

| Application | Namespace | Purpose | Ingress URL |
|------------|-----------|---------|-------------|
| **ArgoCD** | `argocd` | GitOps controller | `https://argocd.baranacikgoz.com` |
| **Nginx Ingress** | `ingress` | Reverse proxy & load balancer | N/A |
| **Metrics Server** | `kube-system` | Resource metrics (kubectl top) | N/A |
| **Prometheus** | `monitoring` | Metrics collection | `https://prometheus.baranacikgoz.com` |
| **Grafana** | `monitoring` | Metrics visualization | `https://grafana.baranacikgoz.com` |
| **Redis** | `database` | In-memory cache | Internal only |
| **RedisInsight** | `database` | Redis GUI | `https://redis.baranacikgoz.com` |
| **PostgreSQL** | `database` | Relational database (CNPG) | Internal only |
| **MinIO** | `minio` | S3-compatible object storage | `https://minio.baranacikgoz.com` |
| **Kafka** | `kafka` | Event streaming (Strimzi) | Internal only |
| **Elasticsearch** | `logging` | Log aggregation (ECK) | Internal only |
| **Kibana** | `logging` | Log visualization | `https://kibana.baranacikgoz.com` |
| **Vault** | `vault` | Secret management (HashiCorp) | `https://vault.baranacikgoz.com` |
| **Vaultwarden** | `vaultwarden` | Password manager (Bitwarden compatible) | `https://passwords.baranacikgoz.com` |
| **Cloudflared** | `cloudflare` | Tunnel for external HTTPS access | N/A |

---

## 📜 Governance & Standards

This project follows strict production-grade DevOps standards documented in [`.agent/rules/00-devops-governance.md`](.agent/rules/00-devops-governance.md). These rules are not just "best practices"—they are the **guardrails of the simulation**, ensuring that we treat residential hardware with the same discipline as a multi-region cloud deployment.

### Core Principles

#### 1. GitOps is Law
- **NO** manual `kubectl apply/edit/patch` for permanent changes
- All changes must be committed to Git before deployment
- Workflow: `Modify YAML → Git Commit → ArgoCD Auto-Sync`

#### 2. Resource Management
- **Every pod MUST have resource limits** (memory & CPU)
- T-Shirt sizing for predictable capacity planning:
  - **Micro (128Mi)**: Operators, exporters, sidecars
  - **Small (256-512Mi)**: Web APIs, stateless services
  - **Medium (1Gi)**: Message queues, stateful services, Kibana
  - **Large (1.5Gi+)**: Databases, Elasticsearch, heavy JVM apps

**Adapt to your cluster**: These sizes are tuned for a 16GB single-node cluster. Scale up/down based on your resources.

#### 3. Networking & Ingress
-Standard pattern: `External TLS Termination → Nginx Ingress (HTTP) → Service → Pod (HTTP)`
- **Every Ingress should include these annotations** to prevent redirect loops:
  ```yaml
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "false"
  ```

#### 4. Platform Compatibility
- **Verify image architecture** before deployment (amd64 vs arm64)
- Platform-specific configurations documented in comments
- Example (my OrbStack setup):
  - Metrics Server: `insecureSkipVerify: true`
  - Strimzi Kafka on ARM64: Version `>= 0.45.0` or `< 0.40.0`

#### 5. Secrets Management (No-Leak Policy)
- **NEVER** commit secrets to Git
- All credentials MUST reference external Kubernetes Secrets:
  ```yaml
  ❌ password: "admin123"
  ✅ existingSecret: "app-secret"
  ```

#### 6. Production Readiness Checklist
- ✅ **Health Checks**: `livenessProbe` + `readinessProbe` on all containers
- ✅ **Rolling Updates**: `strategy.type: RollingUpdate` with `maxUnavailable: 0`
- ✅ **Resource Limits**: Defined for all containers
- ✅ **ConfigMaps**: For non-sensitive configuration
- ✅ **Persistent Storage**: PVCs for stateful apps with backup strategy

---

---

## 🆕 Deploying New Applications

Follow the step-by-step workflow in [`.agent/workflows/deploy-app.md`](.agent/workflows/deploy-app.md).

### Quick Summary

1. **Verify image compatibility** (check if your cluster architecture is supported)
2. **Create app directory**: `mkdir -p clusters/mac-mini/apps/<app-name>`
3. **Create manifests**:
   - `deployment.yaml` (with resource limits + health checks)
   - `service.yaml`
   - `ingress.yaml` (if external access needed)
   - `pvc.yaml` (if stateful)
4. **Create ArgoCD Application**: `clusters/mac-mini/apps/<app-name>.yaml`
5. **Create secrets** (if needed): Add to `scripts/setup-secrets.sh` or create manually
6. **Commit & Push**: `git add . && git commit -m "feat: deploy <app-name>" && git push`
7. **Verify in ArgoCD UI**: Wait for "Synced" + "Healthy" status

---

### Example: Deploy a Simple Web App

```bash
# 1. Create directory
mkdir -p clusters/mac-mini/apps/hello-world

# 2. Create deployment
cat > clusters/mac-mini/apps/hello-world/deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world
spec:
  replicas: 1
  strategy:
    type: RollingUpdate
  selector:
    matchLabels:
      app: hello-world
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
      - name: hello-world
        image: nginxdemos/hello:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
          limits:
            memory: 128Mi
        livenessProbe:
          httpGet:
            path: /
            port: 80
        readinessProbe:
          httpGet:
            path: /
            port: 80
EOF

# 3. Create service
cat > clusters/mac-mini/apps/hello-world/service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: hello-world
spec:
  selector:
    app: hello-world
  ports:
  - port: 80
    targetPort: 80
EOF

# 4. Create ArgoCD Application
cat > clusters/mac-mini/apps/hello-world.yaml <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: hello-world
  namespace: argocd
spec:
  project: default
  source:
    repoURL: git@github.com:baranacikgoz/homelab-infra.git
    targetRevision: main
    path: clusters/mac-mini/apps/hello-world
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF

# 5. Commit and push
git add clusters/mac-mini/apps/hello-world*
git commit -m "feat: deploy hello-world example app"
git push origin main

# 6. Verify
kubectl get pods -n default -w
```

---

## 📊 Monitoring & Observability

### Prometheus Metrics

Access Prometheus at `https://prometheus.baranacikgoz.com` (or via port-forward):

```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
# Open: http://localhost:9090
```

**Key Metrics**:
- `container_memory_usage_bytes` - Pod memory usage
- `kube_pod_container_resource_limits_memory_bytes` - Memory limits
- `node_memory_MemAvailable_bytes` - Node available memory

### Grafana Dashboards

Access Grafana at `https://grafana.baranacikgoz.com`:

**Default Credentials** (from `scripts/setup-secrets.sh`):
- Username: `admin`
- Password: Check output from setup script or run:
  ```bash
  kubectl get secret grafana-secret -n monitoring -o jsonpath="{.data.admin-password}" | base64 -d
  ```

**Pre-installed Dashboards**:
- **Kubernetes / Compute Resources / Cluster**: Overall cluster health
- **Kubernetes / Compute Resources / Namespace (Pods)**: Per-namespace resource usage
- **Node Exporter / Nodes**: Mac Mini hardware metrics

### Kibana Logs

Access Kibana at `https://kibana.baranacikgoz.com` for centralized log analysis.

---

## 🐛 Troubleshooting

### Common Issues

#### 1. Pod stuck in `Pending` state

```bash
kubectl describe pod <pod-name> -n <namespace>
```

**Common causes**:
- Insufficient resources (increase cluster resources if possible)
- PVC not bound (check `kubectl get pvc -n <namespace>`)
- Node selector mismatch

#### 2. Pod in `CrashLoopBackOff`

```bash
kubectl logs <pod-name> -n <namespace> --previous
```

**Common causes**:
- **Exit code 137**: OOMKilled → Increase memory limit
- **Missing secrets**: Create required secret
- **Missing environment variables**: Check configmap/secret references

#### 3. Ingress returning 502/503

```bash
kubectl get ingress -n <namespace>
kubectl describe ingress <ingress-name> -n <namespace>
kubectl get pods -n <namespace>
```

**Checklist**:
- [ ] Service selector matches pod labels
- [ ] Service `targetPort` matches container port
- [ ] Pod is `Ready` (1/1)
- [ ] Nginx Ingress controller is running (`kubectl get pods -n ingress`)

#### 4. Ingress redirect loop (Safari "Secure Connection" error)

**Fix**: Ensure Ingress has anti-loop annotations:
```yaml
nginx.ingress.kubernetes.io/ssl-redirect: "false"
nginx.ingress.kubernetes.io/force-ssl-redirect: "false"
```

#### 5. ArgoCD not syncing

```bash
kubectl logs -n argocd deployment/argocd-repo-server
kubectl logs -n argocd deployment/argocd-application-controller
```

**Quick fix**: Restart repo-server:
```bash
kubectl rollout restart deployment/argocd-repo-server -n argocd
```

#### 6. High memory usage (cluster OOM)

```bash
kubectl top nodes
kubectl top pods -A --sort-by=memory
```

**Mitigation**:
1. Identify top consumers
2. Reduce replicas for non-critical apps
3. Increase cluster resource limits if possible
4. Disable unused applications (move to `clusters/mac-mini/disabled/`)
5. Optimize resource requests/limits for your workload

---

---

## 🤝 Contributing

This is a personal homelab project, but contributions are welcome!

### How to Contribute

1. **Fork** this repository
2. **Create a feature branch**: `git checkout -b feature/my-improvement`
3. **Follow governance standards**: See [`.agent/rules/00-devops-governance.md`](.agent/rules/00-devops-governance.md)
4. **Test in your own cluster**: Verify changes work in your environment
5. **Submit a Pull Request**: Describe changes and rationale

### Contribution Ideas

- 🆕 Add new application deployments (with production-ready manifests)
- 📊 Create custom Grafana dashboards
- 🔧 Improve resource efficiency (memory/CPU optimizations)
- 📖 Enhance documentation
- 🐛 Fix bugs or platform compatibility issues
- 🌐 Add support for additional Kubernetes distributions

---

---

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **ArgoCD Community**: For pioneering and advancing GitOps practices
- **Kubernetes SIG**: For making cloud-native infrastructure accessible
- **Operator Ecosystem**: Strimzi, CNPG, ECK teams for production-grade operators
- **Platform Teams**: OrbStack, K3s, and all K8s distribution maintainers  
- **Homelab Community**: For inspiration, shared knowledge, and pushing boundaries on constrained hardware

---

---

## 📞 Contact & Support

- **Author**: Baran Açıkgöz
- **GitHub**: [@baranacikgoz](https://github.com/baranacikgoz)
- **Issues**: [GitHub Issues](https://github.com/baranacikgoz/homelab-infra/issues)

---

## 🗺 Roadmap

- [ ] **Automated Backups**: Velero for PVC snapshots
- [ ] **Sealed Secrets**: Replace manual secret setup with SealedSecrets operator
- [ ] **Multi-Cluster**: Expand to Raspberry Pi cluster
- [ ] **OpenTelemetry**: Distributed tracing with Jaeger
- [ ] **Service Mesh**: Istio or Linkerd for advanced traffic management
- [ ] **CI/CD**: GitHub Actions for automated testing of manifests

---

**⭐ If this project helped you, please consider starring the repository!**
