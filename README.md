prodstack
![CI](https://github.com/psgueogit/prodstack/actions/workflows/ci.yaml/badge.svg)
![CD](https://github.com/psgueogit/prodstack/actions/workflows/cd.yaml/badge.svg)
![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform)
![k3s](https://img.shields.io/badge/Kubernetes-k3s-FFC61C?logo=kubernetes)
![Hetzner](https://img.shields.io/badge/Cloud-Hetzner-D50C2D?logo=hetzner)
> End-to-end DevOps project: containerised Flask API deployed to a self-managed k3s cluster on Hetzner Cloud via a fully automated GitHub Actions CI/CD pipeline, provisioned with Terraform and monitored with Prometheus + Grafana.
---
Architecture
```
GitHub Push
    │
    ▼
GitHub Actions CI
    │  build + test + push image → ghcr.io
    ▼
GitHub Actions CD
    │  SSH → kubectl apply
    ▼
Hetzner CX22 (€4/mo)
    │  k3s (single-node)
    ├── Flask API deployment
    ├── Prometheus
    └── Grafana
```
Provisioned with Terraform (hcloud provider). No managed Kubernetes — k3s installed via cloud-init on a raw Ubuntu 24.04 VPS.
---
Docker Image Optimisation
One of the core demos: the same app built three ways.
Dockerfile	Base image	Size	Technique
`Dockerfile.naive`	`python:3.12`	~900MB	No optimisation
`Dockerfile.slim`	`python:3.12-slim`	~120MB	Slim base
`Dockerfile.distroless`	`gcr.io/distroless/python3`	~45MB	Multi-stage build
Visualised with `docker history` and dive.
```bash
make images        # build all three
make compare       # print size comparison table
make dive          # run dive on the distroless image
```
---
Stack
Layer	Tool
App	Flask (Python)
Containers	Docker
Local K8s	k3d
Cloud K8s	k3s on Hetzner
IaC	Terraform
CI/CD	GitHub Actions
Registry	ghcr.io
Observability	Prometheus + Grafana (Helm)
---
Quick Start (local)
Prerequisites: Docker, k3d, kubectl, helm
```bash
# clone
git clone https://github.com/psgueogit/prodstack.git
cd prodstack

# spin up local cluster
k3d cluster create prodstack

# deploy app locally
kubectl apply -f k8s/

# access
kubectl port-forward svc/flask-api 8080:80
curl http://localhost:8080/health
```
---
Infrastructure (Hetzner)
```bash
cd terraform/
export TF_VAR_hcloud_token="your_token"
terraform init
terraform apply    # provisions CX22 + installs k3s via cloud-init
```
Tear down when not in use (hourly billing):
```bash
terraform destroy
```
---
CI/CD Pipeline
```
push to main
    └── ci.yaml
            ├── docker build
            ├── docker push → ghcr.io
            └── trigger cd.yaml
                    ├── SSH into Hetzner node
                    └── kubectl apply -f k8s/
```
Secrets required in GitHub repo settings:
`HCLOUD_TOKEN`
`SSH_PRIVATE_KEY`
`KUBECONFIG`
---
Observability
Prometheus + Grafana deployed via Helm into the cluster.
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack \
  -f helm/values-monitoring.yaml

# access Grafana
kubectl port-forward svc/monitoring-grafana 3000:80
# open http://localhost:3000
```
---
Project Structure
```
prodstack/
├── app/                    # Flask API
├── docker/                 # 3 Dockerfiles for image size demo
├── terraform/              # Hetzner infra
├── k8s/                    # Kubernetes manifests
├── helm/                   # Helm values
├── Makefile                # dev shortcuts
└── .github/workflows/      # CI/CD pipelines
```
---
Walkthrough
TODO: Loom walkthrough link
---
Built as a portfolio project to demonstrate end-to-end DevOps on real cloud infrastructure.
