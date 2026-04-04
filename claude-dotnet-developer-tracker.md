# Claude .NET Developer System - Implementation Tracker

## 🏛 Architecture & Governance Context

You are tasked with building the **Claude .NET Developer** system within the homelab's Kubernetes infrastructure. This is a headless AI developer environment triggered via GitHub Actions and executed natively in the local homelab cluster (Mac Mini M4 - ARM64).

**CRITICAL: You MUST strictly obey the standards defined in:**
1. `@[.agent/rules/00-devops-governance.md]`: The overarching architectural rules.
2. `@[.agent/workflows/deploy-app.md]`: The exact workflow for defining ArgoCD applications and Kubernetes manifests.

**Absolute Constraints (Failure to obey violates Governance):**
- **GitOps operations ONLY:** No `kubectl apply` for permanent configuration. Everything goes into `clusters/mac-mini/apps/`.
- **Command execution:** Any command meant for the cluster MUST be prefixed with `ssh macserver`. (e.g. `ssh macserver "kubectl get pods"`).
- **Zero-Leak Policy:** Never commit `ANTHROPIC_API_KEY` or `github_token` into Git.
- **Anti-OOM Rules:** The AI pod must be ephemeral. It must be restricted to `T-Shirt Medium` mapping (Requests: 200m/512Mi, Limits: 1000m/1.5Gi).
- **Architecture Validation:** The Docker images **must** be compiled for `linux/arm64`.

---

## 🚦 Execution Protocol for AI Agents
When you pick up this file to execute tasks:
1. Immediately use tools like `view_file` to review `.agent/rules/00-devops-governance.md` if you are unsure about any constraints.
2. Use `replace_file_content` or `multi_replace_file_content` to edit this tracker file directly. Change `[ ]` to `[/]` for the task you are actively working on.
3. When finished with a task/sub-task, change `[/]` to `[x]`, commit your code changes to Git (Wait for user confirmation before pushing), and STOP to notify the User before moving to the next Phase.

---

## 📋 Task Checklist

### Phase 1: Controller Infrastructure (Adhering to deploy-app.md)

- [x] **1.1 Evaluate Certificate Manager:** Use terminal `ssh macserver "kubectl get pods -n cert-manager"` to verify installation. ARC Controller requires cert-manager for webhook generation.
- [x] **1.2 Validate App-of-Apps Manifest:** Ensure `clusters/mac-mini/apps/arc-controller.yaml` matches the blueprint in `deploy-app.md` step 4. Namespace mapping should be explicit (`CreateNamespace=true`).
- [x] **1.3 Helm Chart Specification:** Ensure `clusters/mac-mini/apps/arc-controller/Chart.yaml` binds correctly to the official ARC helm repo.
- [x] **1.4 ARC Configuration (values.yaml):** Define the controller deployment values. It MUST map to the "Micro" T-Shirt size (`Request: 50m/64Mi`, `Limit: 128Mi` to stay under macOS memory overhead). Ensure probes are active. 

### Phase 2: Zero-Leak Authentication Setup (Standard Secrets)
- [x] **2.1 Prepare Webhook/Runner Auth:** Under "Option A: Standard Kubernetes Secrets" of `deploy-app.md`, we never push secrets to Git. Output exactly the command the User needs to run on their host machine for GitHub auth:
- [x] **2.2 Acknowledge Setup:** Confirm with the User that the secret exists in the cluster before proceeding.

### Phase 3: The Claude .NET Builder Sub-System (Docker Artifact)
- [x] **3.1 Directory Schema:** Create standard folder `/docker/claude-dotnet-developer/` in the repo root (outside the GitOps deployment path).
- [x] **3.2 Craft the ARM64 Dockerfile:** Create the `Dockerfile` enforcing compatibility:
      - Base: `mcr.microsoft.com/dotnet/sdk:10.0-bookworm-slim` (arm64 native).
- [x] **3.3 Pipeline Export:** Document the exact `docker buildx` terminal commands required to build the multi-platform image and push to `ghcr.io`:
      ```bash
      # 1. Login to GHCR (Username: baranacikgoz, Password: <YOUR_GH_TOKEN_WITH_PACKAGES_WRITE>)
      echo $GH_TOKEN | docker login ghcr.io -u baranacikgoz --password-stdin

      # 2. Build multi-platform (linux/arm64 for Mac Mini M4)
      docker buildx build --platform linux/arm64 \
        -t ghcr.io/baranacikgoz/claude-dotnet-developer:latest \
        -f docker/claude-dotnet-developer/Dockerfile \
        ./docker/claude-dotnet-developer/ --push
      ```

### Phase 4: Ephemeral Worker Template Maps (Anti-OOM Restrictions)
- [ ] **4.1 RunnerDeployment Manifest:** Since the AI runner pods are ephemeral jobs spawned by the controller, create `clusters/mac-mini/apps/arc-controller/runnerdeployment.yaml`.
- [ ] **4.2 Resource Boundaries:** Inject our Anti-OOM limit constraints directly into the container definition: `Requests: 200m/512Mi`, `Limits: 1000m/1.5Gi`. Let JVM limits fall into 50-75% heuristic if Java tools are invoked.
- [ ] **4.3 Bind Runner Contexts:** Explicitly bind the Runner to listen to `self-hosted-mac-mini` tags on GitHub. Mount the dummy `ANTHROPIC_API_KEY` environmental variable sourced from a K8s secret placeholder to comply with Zero-Leak.

### Phase 5: The Headless AI Brain (GitHub Workflow Orchestrator)
- [ ] **5.1 Target Repo Orchestration:** Map out the exact deployment YAML to place in the target .NET repository.
- [ ] **5.2 Orchestrator YML generation:** Generate `.github/workflows/claude-dotnet-developer.yml` defining the workflow trigger `on: issues: [labeled]`.
- [ ] **5.3 Task Pipeline Script Definition:** Bash instructions embedded in the workflow YAML *must* include:
      - `gh issue view` to ingest instructions.
      - Headless execution of `claude-code`.
      - Safety verification block: `dotnet build` & `dotnet test`. (Crucial step for safety).
      - Automated git commit and PR operations via the runner's GH token.

---
*Created by the Principal Architect Agent.*
