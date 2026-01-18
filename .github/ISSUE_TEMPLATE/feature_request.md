---
name: Feature Request
about: Suggest a new application or enhancement for the homelab
title: '[FEATURE] '
labels: enhancement
assignees: ''
---

## Feature Description
<!-- A clear and concise description of what you want to add or change -->



## Use Case
<!-- What problem does this solve? Why is this useful for the homelab? -->



## Proposed Solution
<!-- How would you implement this feature? -->



## Alternative Solutions
<!-- What other approaches have you considered? -->



## Resource Impact Analysis
<!-- How will this affect the constrained 16GB RAM cluster? -->

### Estimated Resource Requirements
- **Memory Request**: XXX Mi
- **Memory Limit**: XXX Mi (T-Shirt size: Micro/Small/Medium/Large)
- **CPU Request**: XXX m
- **Storage**: XXX Gi (if applicable)

### Impact on Cluster
- [ ] Low impact (< 256Mi memory)
- [ ] Medium impact (256Mi - 1Gi memory)
- [ ] High impact (> 1Gi memory - requires justification)

## Dependencies
<!-- List any dependencies or prerequisites -->

- [ ] Requires new Kubernetes operator
- [ ] Requires external service (e.g., Cloudflare, DNS)
- [ ] Requires persistent storage (PVC)
- [ ] Requires Ingress (external HTTPS access)
- [ ] Requires secrets/credentials
- [ ] Other: _______________

## ARM64 Compatibility
<!-- Has this been verified to work on Apple Silicon? -->

- **Docker Image**: [link to Docker Hub/GHCR]
- **ARM64 Support**: Yes / No / Unknown
- **Alternative ARM64 Image** (if official doesn't support): _______________

## Implementation Checklist
<!-- What steps are needed to implement this? -->

- [ ] Create Kubernetes manifests (Deployment, Service, Ingress, PVC)
- [ ] Define resource limits (following T-Shirt sizing)
- [ ] Configure health checks (liveness + readiness probes)
- [ ] Set up secrets (add to `scripts/setup-secrets.sh`)
- [ ] Create ArgoCD Application manifest
- [ ] Test on ARM64 (Apple Silicon)
- [ ] Add monitoring/dashboards (if applicable)
- [ ] Update README.md documentation

## Example Configuration
<!-- If applicable, provide example YAML or configuration -->

```yaml
# Example deployment snippet
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 1
  # ...
```

## Additional Context
<!-- Add any other context, screenshots, or references -->



## Priority
<!-- How important is this feature to you? -->

- [ ] Nice to have
- [ ] Would be useful
- [ ] Important for my workflow
- [ ] Critical missing functionality

---
**Willingness to Contribute**:
- [ ] I am willing to submit a PR for this feature
- [ ] I need help implementing this
- [ ] I'm just suggesting the idea
