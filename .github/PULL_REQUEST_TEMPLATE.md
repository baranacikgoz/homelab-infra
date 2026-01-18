## Description
<!-- Provide a brief description of what this PR does -->



## Type of Change
<!-- Mark with an 'x' the type(s) that apply -->

- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📚 Documentation update
- [ ] 🔧 Configuration/Infrastructure change
- [ ] ♻️ Refactoring (no functional changes)

## Motivation
<!-- Why is this change needed? What problem does it solve? -->



## Testing
<!-- Describe the testing you've done. Include commands used and results -->

### Commands Used
```bash
# Example:
# kubectl apply -f clusters/mac-mini/apps/my-app.yaml
# kubectl get pods -n my-namespace
```

### Test Results
<!-- What was the outcome? -->
- [ ] Pod status: Running
- [ ] Readiness: 1/1
- [ ] Health checks: Passing
- [ ] No errors in logs
- [ ] Ingress accessible (if applicable)

## Resource Impact
<!-- How does this change affect cluster resources? -->

- **Memory**: +/- XXX Mi (or N/A)
- **CPU**: +/- XXX m (or N/A)
- **Storage**: +/- XXX Gi (or N/A)

## Screenshots
<!-- If applicable, add screenshots of ArgoCD UI, Grafana dashboards, application UI, etc. -->



## Pre-Submission Checklist
<!-- Mark with an 'x' all completed items -->

### Governance Compliance
- [ ] Follows [GitOps governance rules](.agent/rules/00-devops-governance.md)
- [ ] No secrets committed to Git (uses `existingSecret` pattern)
- [ ] Resource limits defined for all containers
- [ ] Health checks configured (`livenessProbe` + `readinessProbe`)
- [ ] Rolling update strategy configured (if applicable)

### ARM64 Compatibility
- [ ] All Docker images support `linux/arm64` architecture
- [ ] Tested on Apple Silicon (M1/M2/M3/M4)
- [ ] No amd64-only dependencies

### Networking (if applicable)
- [ ] Ingress includes anti-loop annotations:
  - `nginx.ingress.kubernetes.io/ssl-redirect: "false"`
  - `nginx.ingress.kubernetes.io/force-ssl-redirect: "false"`
- [ ] Service selectors match pod labels
- [ ] Service `targetPort` matches container port

### Documentation
- [ ] README.md updated (if adding new application)
- [ ] Inline YAML comments added for non-obvious configurations
- [ ] CONTRIBUTING.md updated (if introducing new patterns)
- [ ] Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/)

### Testing
- [ ] Tested in local OrbStack cluster
- [ ] Pod starts successfully
- [ ] Health checks pass
- [ ] Resource usage verified (`kubectl top pod`)
- [ ] No merge conflicts with `main` branch

## Additional Notes
<!-- Any additional information, context, or considerations for reviewers -->



---
**By submitting this PR, I confirm that**:
- [ ] I have read and followed the [CONTRIBUTING.md](CONTRIBUTING.md) guidelines
- [ ] I have tested these changes in a production-like environment (OrbStack on ARM64)
- [ ] I understand this is a production homelab with 99.9% availability goals
