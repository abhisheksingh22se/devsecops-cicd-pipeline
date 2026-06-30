# 🛡️ DevSecOps CI/CD Pipeline & GitOps Infrastructure

[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)](https://argo-cd.readthedocs.io/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)

A production-ready, zero-trust DevSecOps pipeline and GitOps deployment architecture. This professional portfolio project demonstrates a highly secure, automated path to production using AWS EKS, GitHub Actions, and ArgoCD, fully instrumented with a Prometheus/Grafana observability stack.

## ✨ Key Features

* **🔐 Passwordless AWS Authentication:** Utilizes OpenID Connect (OIDC) to authenticate GitHub Actions with AWS IAM, eliminating the need for long-lived static credentials.
* **🛑 Strict Shift-Left Security:** Implements rigorous quality gates using **Trivy** (container scanning) and **Snyk** (source code scanning). Deployments are automatically blocked if Critical or High CVEs are detected.
* **🔄 GitOps Deployment Strategy:** Fully declarative Kubernetes management using **ArgoCD** and **Kustomize**, with distinct overlays for `dev`, `staging`, and `prod` environments.
* **📉 Optimized Containerization:** Features multi-stage Docker builds that reduce final application image sizes by **60%**, running securely as a non-root user with read-only filesystems.
* **📊 Complete Observability:** Native integration of the `kube-prometheus-stack` to scrape custom Node.js application metrics (via `prom-client`) and visualize them in Grafana.
* **💰 Cost-Optimized Infrastructure:** Terraform configurations include AWS Budget alerts and automated lifecycle policies to manage ECR storage costs.

## 🏗️ Architecture

1. **Commit & PR:** Developer pushes code to the `main` branch.
2. **CI/CD Pipeline (GitHub Actions):**
   - Source code scanned via Snyk.
   - Assumes AWS IAM role via OIDC token exchange.
   - Builds minimal, multi-stage Docker image.
   - Scans image via Trivy; blocks push if CVEs are found.
   - Pushes secure image to Amazon ECR.
   - Automatically updates Kustomize image tags in the `prod` overlay.
3. **Continuous Deployment (ArgoCD):**
   - ArgoCD detects configuration drift in the GitHub repository.
   - Automatically syncs and deploys updated manifests to the AWS EKS cluster.
4. **Observability:** Prometheus scrapes application `/metrics`, viewable on Grafana dashboards.

## 🛠️ Technology Stack

* **Infrastructure as Code:** Terraform
* **Cloud Provider:** AWS (VPC, EKS, ECR, IAM)
* **CI/CD & Automation:** GitHub Actions
* **Continuous Deployment:** ArgoCD, Kustomize
* **Security Scanning:** Trivy, Snyk
* **Containerization:** Docker
* **Orchestration:** Kubernetes (EKS)
* **Application:** Node.js (Express)
* **Observability:** Prometheus, Grafana

## 📁 Repository Structure

```text
.
├── .github/workflows/    # GitHub Actions CI/CD pipelines
├── app/                  # Node.js application source code & tests
├── argocd/               # ArgoCD AppProject and Application manifests
├── docker/               # Multi-stage Dockerfile
├── k8s/                  # Kubernetes manifests (Base + Overlays)
├── scripts/              # Bootstrap and Teardown shell scripts
└── terraform/            # Infrastructure as Code (EKS, VPC, IAM, ECR)
```

## 🚀 Getting Started

### Prerequisites
* AWS CLI configured locally (for initial setup)
* Terraform `>= 1.5.0`
* `kubectl` and ArgoCD CLI installed
* A GitHub repository with Snyk tokens configured in Secrets.

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
Run the bootstrap script to install ArgoCD, Prometheus, and Grafana on the cluster, and apply the initial deployment bounds:
```bash
chmod +x scripts/bootstrap.sh
./scripts/bootstrap.sh
```

### 4. Teardown
To avoid incurring ongoing AWS charges, run the teardown script when finished:
```bash
chmod +x scripts/teardown.sh
./scripts/teardown.sh
```

## 📜 License
This project is licensed under the MIT License.