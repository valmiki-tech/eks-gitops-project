# Cloud-Native GitOps & Microservices Automation Platform

A hands-on DevOps project demonstrating CI/CD automation, container security scanning, GitOps-based Kubernetes deployments, infrastructure as code, Helm packaging, horizontal pod autoscaling, and monitoring in a local Kubernetes environment.

> **Deployment status:** The application runs on a local Kind cluster. AWS VPC and EKS infrastructure are defined in Terraform and have passed local validation, but have not been provisioned in AWS.

## Project Overview

The project automates delivery of a lightweight Python microservice using GitHub Actions, Docker, Kubernetes, and Argo CD.

The application CI workflow checks Python syntax, runs unit tests, builds a container image, scans it with Trivy, publishes images to GitHub Container Registry (GHCR), and updates the Kubernetes deployment manifest with the image's Git commit SHA.

Argo CD monitors the Git repository and reconciles Kubernetes resources with the desired configuration. The project also includes a Helm chart, optional CPU-based HPA, a local Prometheus/Grafana stack, and modular Terraform configuration for a proposed AWS environment.

## Architecture

```text
Developer
   |
   v
GitHub Repository
   |
   +-----------------------------+
   |                             |
   v                             v
GitHub Actions CI             Terraform CI
   |                             |
   +-- Python syntax             +-- Format check
   +-- Unit tests                +-- Initialize
   +-- Docker build              +-- Validate
   +-- Trivy scan
   |
   v
Publish image to GHCR
   |
   v
Update Kubernetes manifest
   |
   v
Argo CD reconciliation
   |
   v
Local Kind cluster
   |
   +-- Python microservice
   +-- Kubernetes Deployment and Service
   +-- Helm chart
   +-- Optional HPA
   +-- Prometheus and Grafana

Separate Terraform configuration:
VPC, subnets, NAT Gateways, EKS and managed node group
(Validated locally; not deployed to AWS)
```

## Technology Stack

| Technology | Purpose |
|---|---|
| Python | Microservice and unit tests |
| Docker | Container image creation |
| Git and GitHub | Source control |
| GitHub Actions | Application CI/CD and Terraform validation |
| Trivy | Container vulnerability scanning |
| GHCR | Container image storage |
| Kubernetes | Workload orchestration |
| Kind | Local Kubernetes cluster |
| Argo CD | GitOps reconciliation |
| Helm | Kubernetes application packaging |
| HPA | CPU-based replica autoscaling |
| Terraform | AWS infrastructure configuration |
| Prometheus | Metrics collection |
| Grafana | Metrics visualization |
| Metrics Server | Kubernetes resource metrics |

## Application

The `hello-service` application is a lightweight Python HTTP service.

| Endpoint | Purpose |
|---|---|
| `/` | Returns the application message and status |
| `/health` | Returns application health status |

Example health response:

```json
{
  "status": "healthy",
  "service": "hello-service"
}
```

Automated tests cover the home endpoint, health endpoint, and unknown endpoints.

## CI/CD Pipeline

### Application CI

Workflow: `.github/workflows/hello-service-ci.yml`

The workflow:
1. Checks Python syntax.
2. Runs application unit tests.
3. Builds a Docker image.
4. Scans for HIGH and CRITICAL vulnerabilities with Trivy.
5. Publishes the image to GHCR after successful build and test on a push to `main`.
6. Tags the image with `latest` and the Git commit SHA.
7. Updates `kubernetes/hello-service-deployment.yaml` with the new image reference.

The SHA tag provides traceability between the image and its source revision.

### Helm CI

Workflow: `.github/workflows/helm-ci.yml`

The workflow lints the chart, renders Kubernetes manifests, and checks the expected Deployment, Service, and replica configuration.

### Terraform CI

Workflow: `.github/workflows/terraform-ci.yml`

The workflow checks Terraform formatting, initializes Terraform without configuring a backend, and validates the configuration. These checks do not provision AWS resources or guarantee that a deployment will succeed.

## GitOps with Argo CD

Argo CD application configuration is stored in `argocd/hello-service-application.yaml`.

The `hello-gitops` application has been verified as `Synced` and `Healthy` in the local cluster. Its sync policy is manual, so changes are not assumed to deploy until a sync occurs. The separate `hello-service` application is configured for automated synchronization.

## Kubernetes and Helm

Kubernetes manifests are stored in `kubernetes/`. The reusable chart is in `helm/hello-service/`.

The application configuration includes:
- Kubernetes Deployment and ClusterIP Service.
- Readiness and liveness probes using `/health`.
- CPU and memory requests and limits.
- A non-root container user.
- Configurable image and replica settings.

### Horizontal Pod Autoscaling

The Helm chart contains an optional HPA template using `autoscaling/v2`.

| Setting | Default |
|---|---|
| Autoscaling | Disabled |
| Minimum replicas | 2 |
| Maximum replicas | 5 |
| Target CPU utilization | 70% |

Autoscaling is disabled by default to avoid unexpectedly changing existing releases.

HPA was enabled on the local `hello-helm` release. It reached two replicas, its configured minimum, and reported CPU utilization of approximately 2% against a 70% target. This verifies HPA reconciliation at the minimum replica count; scaling above two replicas under sustained CPU load has not yet been demonstrated.

## Monitoring

Prometheus and Grafana are installed in the local Kind cluster. Metrics Server is available and has been verified with `kubectl top nodes` and `kubectl top pods`. HPA uses resource metrics from the Kubernetes metrics API.

Application-specific dashboards, alert delivery, and production-grade monitoring have not been fully verified as completed capabilities.

## Terraform Infrastructure Configuration

The `terraform/` directory contains modular configuration for a proposed AWS environment in `ap-south-1`.

It defines:
- A VPC with CIDR `10.0.0.0/16`.
- Public and private subnets across two Availability Zones.
- An Internet Gateway and public routing.
- NAT Gateways and private routing.
- An Amazon EKS control plane.
- IAM roles and policy attachments.
- An EKS managed node group using private subnets.

The configuration has been formatted, initialized, and validated locally, and the provider lock file is committed.

**No AWS infrastructure has been provisioned by this project.** Terraform validation does not guarantee that deployment will succeed. NAT Gateways, EKS, and worker nodes can incur ongoing AWS charges if created.

## Repository Structure

```text
eks-gitops-project/
├── .github/workflows/
│   ├── hello-service-ci.yml
│   ├── helm-ci.yml
│   └── terraform-ci.yml
├── argocd/
│   └── hello-service-application.yaml
├── helm/hello-service/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── deployment.yaml
│       ├── service.yaml
│       └── hpa.yaml
├── kubernetes/
│   ├── hello-service-deployment.yaml
│   └── hello-service-service.yaml
├── services/hello-service/
│   ├── app.py
│   ├── Dockerfile
│   └── tests/
│       └── test_app.py
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   └── modules/
│       ├── network/
│       └── eks/
├── .gitignore
└── README.md
```

## Running and Verifying the Project

These commands assume the local Kind cluster and relevant resources are already configured.

### Check Kubernetes workloads

```bash
kubectl get nodes
kubectl get deployments -A
kubectl get services -n default
kubectl get applications -n argocd
```

### Test the application

In one terminal:

```bash
kubectl port-forward service/hello-service 8001:8000 -n default
```

In another terminal:

```bash
curl http://127.0.0.1:8001/health
curl http://127.0.0.1:8001/
```

### Run unit tests

From the repository root:

```bash
cd services/hello-service
python3 -m unittest discover -s tests -v
```

### Validate Helm

From the repository root:

```bash
helm lint helm/hello-service

helm template hello-service helm/hello-service

helm template hello-service helm/hello-service \
  --set autoscaling.enabled=true
```

The default render omits the HPA; the enabled render includes it.

### Check HPA and metrics

```bash
kubectl get hpa -n default
kubectl describe hpa hello-helm -n default
kubectl top nodes
kubectl top pods -n default
```

### Validate Terraform locally

```bash
terraform -chdir=terraform fmt -check -recursive
terraform -chdir=terraform init -backend=false
terraform -chdir=terraform validate
```

Do not run `terraform apply` unless you intentionally decide to provision AWS resources after reviewing security and cost implications.

## Security and Reliability Practices

- Run automated tests before publishing images.
- Scan container images for HIGH and CRITICAL vulnerabilities.
- Use commit-SHA image tags for traceability.
- Run the application container as a non-root user.
- Configure health probes and resource requests and limits.
- Scope GitHub Actions permissions to required operations.
- Keep Terraform state, secrets, and generated files out of version control.
- Validate Terraform configuration before considering deployment.
- Keep autoscaling optional by default to preserve existing release behavior.

## Current Project Status

### Implemented and locally verified
- Python microservice and three unit tests.
- Application CI workflow configuration.
- Docker build and Trivy scanning workflow configuration.
- GHCR publishing and Kubernetes manifest update workflow configuration.
- Argo CD GitOps application on Kind.
- Kubernetes Deployment and Service resources.
- Helm chart linting and rendering.
- Optional HPA enabled and verified on the local `hello-helm` release.
- Prometheus, Grafana, and Metrics Server installed in the local cluster.
- Modular Terraform VPC and EKS configuration validated locally.
- GitHub Actions workflow for Terraform formatting, initialization, and validation.

### Remaining work
- Verify successful remote runs of all GitHub Actions workflows.
- Demonstrate HPA scaling above two replicas under sustained CPU load.
- Complete and document useful Grafana dashboards and alerting.
- Finish architecture documentation.
- Optionally deploy the Terraform design to AWS after reviewing cost and security.

## Learning Outcomes

This project provides practical experience with CI/CD design, containerization, image security scanning, Kubernetes deployments, GitOps with Argo CD, Helm packaging, CPU-based HPA, monitoring foundations, modular Terraform, and infrastructure validation.

This is an evolving DevOps learning project with a functioning local Kubernetes implementation and validated AWS infrastructure configuration. It is not yet a production AWS EKS deployment.
