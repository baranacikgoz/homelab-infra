# Contributing to Homelab Infrastructure

First off, thank you for considering contributing to this project! 🎉

This document provides guidelines for contributing to the homelab infrastructure repository. Following these guidelines helps maintain the production-grade quality standards and ensures your contributions can be easily reviewed and merged.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Submission Guidelines](#submission-guidelines)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)

---

## Code of Conduct

This project adheres to a simple principle: **Be respectful and constructive**. We welcome contributions from everyone, regardless of experience level.

---

## How Can I Contribute?

### 🐛 Reporting Bugs

Before creating a bug report, please check existing issues to avoid duplicates.

**When reporting a bug, include**:
- **Environment**: Kubernetes platform/version, OS, cluster distribution
- **Architecture**: CPU architecture (amd64/arm64) if relevant
- **Reproduction steps**: Clear steps to reproduce the issue
- **Expected behavior**: What should happen
- **Actual behavior**: What actually happens
- **Logs**: Relevant kubectl logs or ArgoCD screenshots

**Example**:
```
**Bug**: Redis pod crashes on ARM64 with "exec format error"

**Environment**:
- OrbStack: 1.5.0
- Kubernetes: v1.29.0
- macOS: 14.2 (Sonoma)

**Steps to Reproduce**:
1. Deploy Redis using clusters/mac-mini/apps/redis.yaml
2. Check pod status: kubectl get pods -n database

**Expected**: Pod status "Running"
**Actual**: Pod status "CrashLoopBackOff"

**Logs**:
```
exec /usr/local/bin/redis-server: exec format error
```

**Root Cause**: Image does not support linux/arm64
```

### 💡 Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues.

**When suggesting an enhancement, include**:
- **Use case**: What problem does this solve?
- **Proposed solution**: How would you implement it?
- **Alternatives considered**: Other approaches you've thought about
- **Resource impact**: Memory/CPU implications (critical for this constrained cluster)

### 📝 Pull Requests

Pull requests are the best way to propose changes to the codebase.

**Good PRs**:
- ✅ Follow the [GitOps governance rules](.agent/rules/00-devops-governance.md)
- ✅ Verify image architecture compatibility for your platform
- ✅ Add resource limits to all new deployments
- ✅ Update documentation (README, comments)
- ✅ Test in a Kubernetes cluster
- ✅ Include clear commit messages

---

## Development Setup

### Prerequisites

1. **Kubernetes Cluster** (any distribution: K3s, OrbStack, kind, minikube, cloud managed K8s)
2. **kubectl** CLI tool
3. **Git** configured with SSH keys
4. **Sufficient resources** for testing (8GB+ RAM recommended)

### Fork & Clone

```bash
# Fork the repository on GitHub, then:
git clone git@github.com:YOUR_USERNAME/homelab-infra.git
cd homelab-infra

# Add upstream remote
git remote add upstream git@github.com:baranacikgoz/homelab-infra.git
```

### Create a Feature Branch

```bash
git checkout -b feature/my-awesome-feature
```

### Test Your Changes Locally

```bash
# Apply your changes to your local cluster
kubectl apply -f clusters/mac-mini/apps/your-new-app.yaml

# Verify deployment
kubectl get pods -n your-namespace -w

# Check resource usage
kubectl top pods -n your-namespace
```

---

## Submission Guidelines

### Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature (e.g., new application deployment)
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring without functional changes
- `perf`: Performance improvements
- `chore`: Maintenance tasks (dependency updates, etc.)

**Examples**:
```
feat(kafka): add Strimzi operator for ARM64

- Updated to Strimzi 0.45.0 for M4 compatibility
- Set resource limits to 1Gi memory
- Added health checks with 30s initialDelay

Closes #42
```

```
fix(ingress): resolve Safari redirect loop on MinIO

- Added ssl-redirect: false annotation
- Added X-Forwarded-Proto header configuration snippet

Fixes #38
```

### Pull Request Checklist

Before submitting a PR, ensure:

- [ ] **Follows Governance**: Adheres to [00-devops-governance.md](.agent/rules/00-devops-governance.md)
- [ ] **Image Compatibility**: Docker images support your cluster's architecture
- [ ] **Resource Limits Set**: Every container has `resources.requests` and `resources.limits`
- [ ] **Health Checks**: All deployments have `livenessProbe` and `readinessProbe`
- [ ] **No Secrets in Git**: Credentials use `existingSecret` pattern
- [ ] **Ingress Annotations**: If adding Ingress, includes anti-loop annotations
- [ ] **Testing Done**: Tested in a Kubernetes cluster
- [ ] **Documentation Updated**: README, comments, or workflow docs updated
- [ ] **Conventional Commits**: Commit messages follow the format
- [ ] **No Merge Conflicts**: Rebased on latest `main` branch

### PR Template

When opening a PR, use this template:

```markdown
## Description
Brief description of what this PR does.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Motivation
Why is this change needed? What problem does it solve?

## Testing
How did you test this change?

```bash
# Example commands used
kubectl apply -f ...
kubectl get pods -n ...
```

## Resource Impact
- **Memory**: +/- XXX Mi
- **CPU**: +/- XXX m
- **Storage**: +/- XXX Gi

## Screenshots (if applicable)
[ArgoCD UI, Grafana dashboards, etc.]

## Checklist
- [ ] Tested on target Kubernetes platform
- [ ] Resource limits defined
- [ ] Health checks configured
- [ ] No secrets committed
- [ ] Documentation updated
- [ ] Follows governance rules
```

---

## Coding Standards

### YAML Formatting

- **Indentation**: 2 spaces (no tabs)
- **Key order**: `apiVersion`, `kind`, `metadata`, `spec`
- **Comments**: Use `#` for explanations of non-obvious configurations

**Example**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  labels:
    app: my-app
spec:
  replicas: 1
  strategy:
    type: RollingUpdate  # Zero-downtime deployments
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: my-app:v1.0.0
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            memory: 256Mi  # T-Shirt: Small
```

### Resource Limits

Use the T-Shirt sizing model defined in governance:

| Size | Use Case | Memory Limit |
|------|----------|--------------|
| Micro | Operators, exporters | 128Mi |
| Small | Web APIs, stateless apps | 256-512Mi |
| Medium | Kafka, RabbitMQ, stateful services | 1Gi |
| Large | Elasticsearch, heavy JVM apps | 1.5Gi (MAX) |

### Health Checks

**Every deployment MUST have**:

```yaml
livenessProbe:
  httpGet:
    path: /health  # or /healthz, /live
    port: 8080
  initialDelaySeconds: 30  # Allow startup time
  periodSeconds: 10
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /ready  # or /healthz
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 5
  failureThreshold: 3
```

### Secrets

**NEVER commit secrets to Git.**

Instead:
1. Add secret generation to `scripts/setup-secrets.sh`
2. Reference the secret in your deployment:
   ```yaml
   env:
   - name: PASSWORD
     valueFrom:
       secretKeyRef:
         name: my-app-secret
         key: password
   ```

---

## Testing

### Manual Testing Checklist

Before submitting a PR, test your changes:

1. **Apply the manifest**:
   ```bash
   kubectl apply -f clusters/mac-mini/apps/your-app.yaml
   ```

2. **Verify pod status**:
   ```bash
   kubectl get pods -n your-namespace -w
   # Wait for "Running" and "1/1 Ready"
   ```

3. **Check logs**:
   ```bash
   kubectl logs -n your-namespace deployment/your-app
   # No errors or warnings
   ```

4. **Test health checks**:
   ```bash
   kubectl describe pod -n your-namespace <pod-name>
   # Liveness: Healthy
   # Readiness: Healthy
   ```

5. **Verify resource usage**:
   ```bash
   kubectl top pod -n your-namespace
   # Memory < 80% of limit
   ```

6. **Test Ingress** (if applicable):
   ```bash
   curl -I https://your-app.baranacikgoz.com
   # HTTP 200 OK (no redirect loops)
   ```

7. **Test rolling update**:
   ```bash
   kubectl set image deployment/your-app your-app=your-app:v2.0.0 -n your-namespace
   kubectl rollout status deployment/your-app -n your-namespace
   # No downtime during update
   ```

### Image Architecture Verification

```bash
# Check image architecture support
docker pull your-image:tag
docker inspect your-image:tag | grep Architecture

# Expected output depends on your cluster:
# "Architecture": "amd64"  (most common)
# "Architecture": "arm64"  (Apple Silicon, Raspberry Pi, etc.)
```

**If the image doesn't support your cluster's architecture**:
1. Find an alternative image that supports your architecture
2. Use a multi-arch image (supports both amd64 and arm64)
3. Document the architecture requirement/limitation in the PR

---

## Documentation

### What to Document

When adding a new feature, update:

1. **README.md**: Add new services to "Deployed Applications" and ensure the "Big Tech Simulation" narrative remains accurate.
2. **Inline comments**: Explain non-obvious configurations.
3. **Workflow docs**: If introducing a new pattern, add to `.agent/workflows/`.

### Documentation Style

- **Be concise**: Short, clear sentences
- **Use examples**: Show, don't just tell
- **Include commands**: Provide copy-paste-able CLI examples
- **Explain why**: Not just what, but why this approach

---

## Questions?

If you have questions about contributing, feel free to:
- Open a GitHub Discussion
- Open an issue with the `question` label
- Reach out via the contact methods in the README

---

**Thank you for contributing! 🚀**
