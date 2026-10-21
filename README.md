# Cloud-Native GitOps & Microservices Automation Platform

A hands-on DevOps project demonstrating automated testing, container image security scanning, image publishing, Kubernetes deployments, and GitOps-based delivery using GitHub Actions and Argo CD.

> **Environment:** Local Kubernetes cluster using Kind. AWS EKS deployment and infrastructure provisioning are future enhancements.

## Project Overview

This project demonstrates an automated delivery pipeline for a Python-based microservice. Application changes trigger GitHub Actions, which validates the code, runs unit tests, builds a Docker image, scans it with Trivy, and publishes the image to GitHub Container Registry (GHCR).

After a successful image publication, the workflow automatically updates the Kubernetes deployment manifest in Git. Argo CD monitors the repository and synchronizes the desired configuration with the Kubernetes cluster.

## Architecture

```text
Developer
   |
   v
GitHub Repository
   |
   v
GitHub Actions CI Pipeline
   |
   +--> Python Syntax Validation
   |
   +--> Unit Tests
   |
   +--> Docker Image Build
   |
   +--> Trivy Vulnerability Scan
   |
   v
Publish Image to GHCR
   |
   v
Update Kubernetes Manifest in Git
   |
   v
Argo CD Detects Git Changes
   |
   v
Local Kind Kubernetes Cluster
   |
   v
hello-service Application
```

## Technology Stack

| Technology | Purpose |
|---|---|
| Python | Microservice implementation and unit tests |
| Docker | Container image creation |
| Git and GitHub | Version control and source repository |
| GitHub Actions | CI pipeline automation |
| Trivy | Container vulnerability scanning |
| GitHub Container Registry (GHCR) | Container image storage |
| Kubernetes | Application deployment and service discovery |
| Kind | Local Kubernetes cluster |
| Argo CD | GitOps-based deployment synchronization |

**Planned enhancements:** AWS EKS, Terraform, Helm, Prometheus, and Grafana.

## Application

The `hello-service` application is a lightweight Python HTTP service.

### Endpoints

| Endpoint | Purpose |
|---|---|
| `/` | Returns the application message and status |
| `/health` | Returns the application health status |

Example health response:

```json
{
  "status": "healthy",
  "service": "hello-service"
}
```

## CI/CD Pipeline

The GitHub Actions workflow is defined in:

`.github/workflows/hello-service-ci.yml`

### Build and test

- Checks Python syntax.
- Runs automated unit tests.
- Builds the Docker image.
- Scans the image using Trivy for HIGH and CRITICAL vulnerabilities.

### Image publishing

After the `build-and-test` job succeeds on a push to `main`, the publishing job builds and publishes the image to GHCR.

The image is published with two tags:

- `latest`
- The Git commit SHA

Using a commit-SHA tag makes it possible to identify the source revision associated with a container image.

### Automated GitOps updates

After the image is published, GitHub Actions updates `kubernetes/hello-service-deployment.yaml` with the new image tag and pushes the manifest change to GitHub.

Argo CD monitors the configured repository and synchronizes the Kubernetes application with the updated desired state.

## Kubernetes Resources

The Kubernetes manifests are stored in the `kubernetes/` directory.

The application deployment includes:

- A Kubernetes Deployment.
- A ClusterIP Service exposing port `8000`.
- Readiness and liveness probes using `/health`.
- CPU and memory requests and limits.
- A non-root container configuration defined in the Dockerfile.

The application is currently deployed in the `default` namespace of the local Kind cluster.

## Repository Structure

```text
eks-gitops-project/
├── .github/
│   └── workflows/
│       └── hello-service-ci.yml
├── argocd/
│   └── hello-service-application.yaml
├── kubernetes/
│   ├── hello-service-deployment.yaml
│   └── hello-service-service.yaml
├── services/
│   └── hello-service/
│       ├── app.py
│       ├── Dockerfile
│       └── tests/
│           └── test_app.py
├── .gitignore
└── README.md
```

## Running and Verifying the Project

The following commands assume that the local Kind cluster, Kubernetes resources, and Argo CD are already configured.

### Check the application deployment

```bash
kubectl get deployment hello-service -n default
kubectl get pods -n default
kubectl get service hello-service -n default
```

### Verify Argo CD

```bash
kubectl get applications -n argocd
```

The application has previously been verified as `Synced` and `Healthy`.

### Test the application

Start a port-forward in one terminal:

```bash
kubectl port-forward service/hello-service 8001:8000 -n default
```

In a second terminal, test the endpoints:

```bash
curl http://127.0.0.1:8001/health
curl http://127.0.0.1:8001/
```

### Run the unit tests locally

From the repository root:

```bash
cd services/hello-service
python3 -m unittest discover -s tests -v
```

## Security and Reliability Practices

- Run automated tests before publishing container images.
- Scan container images for HIGH and CRITICAL vulnerabilities.
- Use immutable commit-SHA image tags for traceability.
- Run the application container as a non-root user.
- Configure Kubernetes health probes and resource requests and limits.
- Use GitHub's built-in `GITHUB_TOKEN` for workflow authentication.
- Keep workflow permissions scoped to the jobs that require them.

## Current Project Status

**Implemented and verified**

- Python microservice and unit tests.
- GitHub Actions CI pipeline.
- Docker image build and Trivy scanning.
- GHCR image publishing.
- Automated Kubernetes manifest updates.
- Argo CD synchronization.
- Local Kind deployment and application health checks.

**Future enhancements**

- Provision AWS infrastructure and Amazon EKS using Terraform.
- Package Kubernetes resources using Helm.
- Integrate Prometheus and Grafana for metrics and dashboards.
- Add deployment monitoring, alerting, and troubleshooting documentation.

## Learning Outcomes

This project provides hands-on practice with:

- CI/CD pipeline design.
- Containerization and image publishing.
- Container vulnerability scanning.
- Kubernetes deployments and Services.
- GitOps workflows using Argo CD.
- Automated configuration updates and image version traceability.

The project is a learning environment and local Kubernetes implementation; it is not currently a production AWS EKS deployment.
