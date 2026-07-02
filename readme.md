# 🛡️ DevSecOps CI/CD Pipeline & GitOps Infrastructure

[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)](https://argo-cd.readthedocs.io/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white)](https://grafana.com/)

This is an end-to-end CI/CD and GitOps infrastructure pipeline operating within the Cloud and DevSecOps domain. It automates the secure build, deployment, and continuous monitoring of a containerized application directly to an AWS EKS cluster. By enforcing strict vulnerability scanning, passwordless cloud authentication, and declarative Kubernetes management, the architecture provides a highly resilient, scalable, and observable path to production.

## ✨ Key Features

* **🔐 Passwordless AWS Authentication:** Utilizes OpenID Connect (OIDC) to authenticate GitHub Actions with AWS IAM, eliminating the need for long-lived static credentials.
* **🛑 Strict Shift-Left Security:** Implements rigorous quality gates using **Trivy** (container scanning) and **Snyk** (source code scanning). Deployments are automatically blocked if Critical or High CVEs are detected.
* **🔄 GitOps Deployment Strategy:** Fully declarative Kubernetes management using **ArgoCD** and **Kustomize**, with distinct overlays for local `dev`, `staging`, and `prod` environments.
* **📉 Optimized Containerization:** Features multi-stage Docker builds that reduce final application image sizes by **60%**, running securely as a non-root user with read-only filesystems.
* **📊 Complete Observability:** Native integration of the `kube-prometheus-stack`. Features dynamic target discovery via `ServiceMonitors`, cross-namespace scraping, and custom Grafana dashboards for real-time traffic visualization and P95 latency tracking.
* **💰 Cost-Optimized Infrastructure:** Terraform configurations include AWS Budget alerts and automated lifecycle policies to manage ECR storage costs.

## 🏗️ Architecture Workflow

1. **Commit & PR:** A developer pushes code to the `main` branch, triggering the workflow.
2. **CI/CD Pipeline (GitHub Actions):** The pipeline scans source code via Snyk, assumes an AWS IAM role via OIDC, builds a minimal multi-stage Docker image, and scans it with Trivy. If no CVEs are found, it pushes to Amazon ECR and updates Kustomize image tags.
3. **Continuous Deployment (ArgoCD):** ArgoCD detects configuration drift in the Git repository and automatically syncs the updated Kubernetes manifests to the cluster.
4. **Observability Loop:** Prometheus Operator discovers the deployed `ServiceMonitor`, binds to the application's named ports, and scrapes `/metrics` for visualization in Grafana.

## 🛠️ Technology Stack

* **Infrastructure as Code:** Terraform
* **Cloud Provider:** AWS (VPC, EKS, ECR, IAM)
* **CI/CD & Automation:** GitHub Actions
* **Continuous Deployment:** ArgoCD, Kustomize
* **Security Scanning:** Trivy, Snyk
* **Containerization:** Docker
* **Orchestration:** Kubernetes
* **Application:** Node.js (Express)
* **Observability:** Prometheus, Grafana

## 📁 Repository Structure

```text
.
├── .github/workflows/    # GitHub Actions CI/CD pipelines
├── app/                  # Node.js application source code & tests
├── argocd/               # ArgoCD AppProject and Application manifests
├── docker/               # Multi-stage Dockerfile
├── k8s/                  
│   ├── base/             # Foundational manifests (Deployment, Service, ServiceMonitor, Dashboards)
│   └── overlays/         # Environment-specific patches (dev, staging, prod)
├── scripts/              # Bootstrap and Teardown shell scripts
└── terraform/            # Infrastructure as Code (EKS, VPC, IAM, ECR)
```

## 🚀 Getting Started

### Prerequisites
* AWS CLI configured locally (for cloud deployment)
* Terraform `>= 1.5.0`
* `kubectl`, `helm`, and ArgoCD CLI installed
* Docker Desktop (for local testing)

### 1. Provision Infrastructure
```bash
cd terraform
terraform init
terraform apply -auto-approve
```

### 2. Configure GitHub Secrets
Add the following secrets to your repository settings:
* `AWS_ROLE_ARN`: The ARN outputted by the Terraform apply.
* `SNYK_TOKEN`: Your Snyk API token for application scanning.

### 3. Bootstrap GitOps & Observability
Run the bootstrap script to install ArgoCD and the Prometheus Operator stack on the cluster, and apply the initial deployment configurations:
```bash
chmod +x scripts/bootstrap.sh
./scripts/bootstrap.sh
```

### 4. Access the Observability Dashboards
Retrieve the auto-generated Grafana admin password:
```bash
kubectl get secret --namespace monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

Start the port-forwards in separate terminal windows:
```bash
# Terminal 1: Route traffic to the application
kubectl port-forward svc/devsecops-app-svc -n dev 3000:80

# Terminal 2: Access the Grafana UI
kubectl port-forward svc/monitoring-grafana -n monitoring 8080:80
```
Navigate to `http://localhost:8080`, log in with the username `admin` and your decoded password, and view the "DevSecOps Application Performance" dashboard.

## 📜 License
This project is licensed under the MIT License.