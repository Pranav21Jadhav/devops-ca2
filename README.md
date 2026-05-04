# DevOps CA-II Assessment — Pranav
**Tasks completed:** Task 1 (Deployment Strategy) + Task 3 (Containerization & Orchestration)

---

## Task 1 — Deployment Strategy with GitHub Actions (2 marks)

**Tool selected:** GitHub Actions

### Files
| File | Purpose |
|------|---------|
| `.github/workflows/ci-cd.yml` | Full CI/CD pipeline workflow |
| `app/index.js` | Node.js Express application |
| `app/package.json` | Dependencies & test scripts |
| `app/index.test.js` | Jest unit tests |

### Pipeline Stages
1. **Build & Test** — Install deps → run Jest with coverage → upload report
2. **Docker Build & Push** — Multi-stage Dockerfile → push to Docker Hub with SHA/branch/latest tags
3. **Deploy to Kubernetes** — `kubectl set image` → rollout status watch (120s timeout)
4. **Smoke Test** — HTTP 200 health check against live URL

### Secrets required (add in GitHub Settings → Secrets)
- `DOCKERHUB_USERNAME` / `DOCKERHUB_TOKEN`
- `KUBECONFIG` (base64-encoded kubeconfig)
- `APP_URL` (deployed app URL for smoke test)

---

## Task 3 — Containerization & Orchestration (2 marks)

**Tools:** Docker (multi-stage build) + Kubernetes (Deployment, Service, HPA)

### Files
| File | Purpose |
|------|---------|
| `Dockerfile` | Multi-stage Docker build (Node 20 Alpine) |
| `docker-compose.yml` | Local development environment |
| `k8s/deployment.yaml` | K8s Deployment with rolling update config |
| `k8s/service.yaml` | LoadBalancer Service + Namespace + HPA |

### Rolling Update Strategy
```
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1        # One extra pod during update
    maxUnavailable: 0  # Zero downtime guaranteed
```

### Demo Commands
```bash
# Build and run locally
docker build -t devops-demo-app .
docker run -p 3000:3000 devops-demo-app

# OR with Docker Compose
docker-compose up

# Deploy to Kubernetes
kubectl apply -f k8s/

# Trigger a rolling update (change image tag)
kubectl set image deployment/devops-demo-app \
  devops-demo-app=<your-user>/devops-demo-app:v2.0 \
  -n devops-demo

# Watch the rollout
kubectl rollout status deployment/devops-demo-app -n devops-demo

# Rollback to previous version
kubectl rollout undo deployment/devops-demo-app -n devops-demo
```

### Kubernetes Resources Created
- **Namespace**: `devops-demo`
- **Deployment**: 3 replicas, liveness + readiness probes
- **Service**: LoadBalancer on port 80 → container port 3000
- **HPA**: Auto-scales 2–10 pods at 70% CPU utilization

---

## Architecture Summary

```
GitHub Push
    │
    ▼
GitHub Actions
    ├─ Stage 1: npm test (Jest)
    ├─ Stage 2: docker build + push (Docker Hub)
    ├─ Stage 3: kubectl set image → K8s Deployment
    │               ├─ Pod 1 (v2) ─┐
    │               ├─ Pod 2 (v2)  ├─ LoadBalancer Service → Users
    │               └─ Pod 3 (v2) ─┘
    └─ Stage 4: /health smoke test
```
