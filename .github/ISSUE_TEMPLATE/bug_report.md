---
name: Bug Report
about: Report a bug or issue with the homelab infrastructure
title: '[BUG] '
labels: bug
assignees: ''
---

## Bug Description
<!-- A clear and concise description of what the bug is -->



## Environment
<!-- Please complete the following information -->

- **Host OS**: macOS [version]
- **Hardware**: Mac Mini M4 / M3 / M2 / M1
- **OrbStack Version**: [e.g., 1.5.0]
- **Kubernetes Version**: [e.g., v1.29.0] (run: `kubectl version --short`)
- **Architecture**: ARM64

## Affected Component
<!-- Mark with an 'x' the component(s) affected -->

- [ ] ArgoCD
- [ ] Ingress (Nginx)
- [ ] Monitoring (Prometheus/Grafana)
- [ ] Database (Redis/PostgreSQL)
- [ ] Messaging (Kafka)
- [ ] Storage (MinIO)
- [ ] Logging (Elasticsearch/Kibana)
- [ ] Application deployment
- [ ] Other: _______________

## Steps to Reproduce
<!-- Provide detailed steps to reproduce the issue -->

1. 
2. 
3. 

## Expected Behavior
<!-- What should happen? -->



## Actual Behavior
<!-- What actually happens? -->



## Logs
<!-- Include relevant logs -->

### Pod Logs
```bash
# kubectl logs -n <namespace> <pod-name>
```

### Pod Description
```bash
# kubectl describe pod -n <namespace> <pod-name>
```

### Events
```bash
# kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```

## Screenshots
<!-- If applicable, add screenshots to help explain the problem -->



## Additional Context
<!-- Add any other context about the problem here -->



## Possible Solution
<!-- If you have ideas on how to fix this, please share -->



---
**Checklist**:
- [ ] I have searched existing issues to avoid duplicates
- [ ] I have included all relevant logs
- [ ] I have specified my environment details
- [ ] This issue is reproducible
