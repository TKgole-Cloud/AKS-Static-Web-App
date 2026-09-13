# AKS Static Web App

A containerized static web application deployed to **Microsoft Azure Kubernetes Service (AKS)** using **Docker, Azure Container Registry (ACR), Terraform, Kubernetes, GitHub, and GitHub Actions CI/CD**.

The project demonstrates an end-to-end Cloud/DevOps workflow: application development, containerization, infrastructure provisioning, container registry management, Kubernetes deployment, and automated CI/CD.

---

## Project Overview

This project demonstrates how a simple web application can be transformed from source code into a containerized workload and deployed to a managed Kubernetes platform.

The application is intentionally simple so that the primary focus remains on the **Cloud and DevOps engineering workflow** rather than application complexity.

### The workflow

```text
Developer
   │
   ▼
HTML / CSS / JavaScript
   │
   ▼
Git / GitHub
   │
   ▼
Docker
   │
   ├── Local Container Test
   │
   ▼
Azure Container Registry (ACR)
   │
   ▼
Azure Kubernetes Service (AKS)
   │
   ├── Kubernetes Deployment
   │       └── 3 Application Pods
   │
   └── LoadBalancer Service
            │
            ▼
       Azure Public IP
            │
            ▼
          Browser
```

---

# Problem This Project Solves

A common challenge when deploying applications is moving from:

> **"The application works on my computer."**

to:

> **"The application is consistently packaged, deployed, and accessible in the cloud."**

A manually deployed application can become difficult to reproduce and maintain.

For example:

* Application environments can differ.
* Deployments can require manual steps.
* Servers may need to be configured individually.
* Application versions can become difficult to track.
* Infrastructure can be created inconsistently.
* Container images need somewhere reliable to be stored.
* Kubernetes workloads need to be deployed and updated consistently.

This project addresses those problems by creating a repeatable deployment pipeline:

```text
Source Code
     ↓
Docker Image
     ↓
Container Registry
     ↓
Kubernetes
     ↓
Automated Deployment
```

The infrastructure and application deployment are therefore separated from the developer's local machine.

---

# Project Objectives

The main objectives were to:

* Containerize a web application with Docker.
* Store the container image in Azure Container Registry.
* Provision Azure infrastructure using Terraform.
* Deploy the application to Azure Kubernetes Service.
* Run multiple application replicas for basic availability.
* Expose the application using a Kubernetes LoadBalancer.
* Automate image building and deployment using GitHub Actions.
* Authenticate GitHub Actions to Azure using OpenID Connect (OIDC).
* Configure AKS to pull private images from ACR.
* Demonstrate a repeatable Cloud/DevOps deployment workflow.
* Document the implementation with architecture and deployment evidence.

---

# Technology Stack

| Technology               | Purpose                                     |
| ------------------------ | ------------------------------------------- |
| HTML                     | Application structure                       |
| CSS                      | Application styling                         |
| JavaScript               | Client-side functionality                   |
| Git                      | Version control                             |
| GitHub                   | Source code repository                      |
| Docker                   | Application containerization                |
| Azure Container Registry | Private container image registry            |
| Kubernetes               | Container orchestration                     |
| Azure Kubernetes Service | Managed Kubernetes platform                 |
| Terraform                | Infrastructure as Code                      |
| GitHub Actions           | CI/CD automation                            |
| Azure OIDC               | Passwordless GitHub-to-Azure authentication |

---

# Architecture

```text
                         ┌──────────────────────┐
                         │      Developer       │
                         │                      │
                         │ HTML / CSS / JS      │
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │        GitHub        │
                         │    Source Control    │
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │   GitHub Actions     │
                         │                      │
                         │ Build → Push → Deploy│
                         └───────┬───────┬──────┘
                                 │       │
                    Docker Image │       │ Kubernetes Deployment
                                 │       │
                                 ▼       ▼
                    ┌────────────────┐  ┌─────────────────────┐
                    │      ACR       │  │        AKS          │
                    │                │  │                     │
                    │ Docker Image   │  │ Deployment          │
                    │ Repository     │  │        │            │
                    └───────┬────────┘  │        ▼            │
                            │           │   ┌─────────────┐   │
                            │ AcrPull   │   │ Pod 1       │   │
                            └──────────►│   │ Pod 2       │   │
                                        │   │ Pod 3       │   │
                                        │   └──────┬──────┘   │
                                        │          │          │
                                        │          ▼          │
                                        │   LoadBalancer      │
                                        └──────────┬──────────┘
                                                   │
                                                   ▼
                                            Azure Public IP
                                                   │
                                                   ▼
                                               Browser
```

---

# Repository Structure

```text
AKS-Static-Web-App/
│
├── .github/
│   └── workflows/
│       └── deploy.yml
│
├── app/
│   ├── index.html
│   ├── script.js
│   └── style.css
│
├── docker/
│   └── Dockerfile
│
├── docs/
│   └── screenshots/
│
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── ...
│
├── .gitignore
└── README.md
```

---

# Phase 1 — Application

The application is a simple static web application built with:

* HTML
* CSS
* JavaScript

The application intentionally contains minimal business logic.

### Why?

The objective of this project is not to demonstrate frontend development.

The application acts as the workload that allows the project to demonstrate:

* Docker
* Kubernetes
* Azure
* Terraform
* CI/CD
* Container registries
* Cloud deployment

Keeping the application simple allows the infrastructure and deployment workflow to remain the focus.

![Application](./docs/screenshots/phase-01-application.png)

---

# Phase 2 — Containerization with Docker

The application was packaged into a Docker image using Nginx.

### Dockerfile

```dockerfile
FROM nginx:alpine

COPY app/ /usr/share/nginx/html/

EXPOSE 80
```

### Why Docker?

Docker packages the application and its runtime environment into a portable container image.

Instead of relying on:

```text
"My computer has everything configured correctly."
```

we create:

```text
Application
    +
Runtime
    +
Configuration
    ↓
Container Image
```

This makes the application easier to test locally and deploy consistently to cloud environments.

### Build

The image was built from the project root:

```bash
docker build -t aks-static-web-app:v1 -f docker/Dockerfile .
```

### Local test

```bash
docker run -d -p 8080:80 --name aks-static-web-app aks-static-web-app:v1
```

The application was then verified locally before moving to Azure.

![Docker](./docs/screenshots/phase-02-docker.png)

---

# Phase 3 — Azure Container Registry

The Docker image was pushed to **Azure Container Registry (ACR)**.

Image:

```text
aksstaticwebappacr.azurecr.io/aks-static-web-app
```

### Why ACR?

AKS needs a reliable location from which it can retrieve container images.

ACR provides a private Azure container registry integrated with the Azure environment.

The deployment flow becomes:

```text
Docker Image
     ↓
ACR
     ↓
AKS
```

Instead of building the application directly inside AKS, the container image is built once and stored in a registry.

This creates a cleaner separation between:

* Building the application
* Storing the application
* Running the application

---

# Phase 4 — Infrastructure as Code with Terraform

Azure infrastructure was provisioned using Terraform.

The main Azure resources include:

```text
Resource Group
     │
     ├── Azure Container Registry
     │
     └── Azure Kubernetes Service
```

### Resource Group

```text
rg-aks-static-webapp
```

### Azure Container Registry

```text
aksstaticwebappacr
```

### Azure Kubernetes Service

```text
aks-static-webapp
```

### Why Terraform?

Without Infrastructure as Code, cloud resources may be created manually through the Azure Portal.

That can lead to:

* configuration drift
* inconsistent environments
* difficult recreation
* undocumented infrastructure
* manual deployment processes

Terraform allows the infrastructure configuration to be represented as code.

The environment can therefore be:

```text
Terraform Configuration
        ↓
Terraform Plan
        ↓
Terraform Apply
        ↓
Azure Infrastructure
```

This makes the infrastructure more repeatable and easier to manage.

---

# Phase 5 — AKS Configuration

The application was deployed to Azure Kubernetes Service.

The Kubernetes Deployment runs:

```text
3 replicas
```

This produces:

```text
Deployment
   │
   ├── Pod 1
   ├── Pod 2
   └── Pod 3
```

### Why multiple replicas?

Running multiple replicas provides basic workload redundancy.

If one application Pod becomes unavailable, other replicas can continue serving the workload.

This also allows Kubernetes to perform rolling updates rather than replacing every application instance simultaneously.

---

# Phase 6 — ACR Authentication

The AKS cluster needs permission to pull the private container image from ACR.

The AKS kubelet identity was granted:

```text
AcrPull
```

on the Azure Container Registry.

The resulting relationship is:

```text
AKS Kubelet Identity
        │
        │ AcrPull
        ▼
Azure Container Registry
        │
        ▼
Container Image
```

### Why?

The registry is private.

AKS therefore requires appropriate Azure permissions to retrieve the image.

This avoids storing registry credentials directly inside the Kubernetes deployment configuration.

---

# Phase 7 — Kubernetes Deployment

The Kubernetes Deployment defines how the application should run.

Key configuration:

```yaml
replicas: 3
```

The application container listens on:

```text
Port 80
```

The Deployment manages the application Pods.

Conceptually:

```text
Deployment
     │
     ▼
ReplicaSet
     │
     ├── Pod
     ├── Pod
     └── Pod
```

Kubernetes is responsible for maintaining the desired number of replicas.

---

# Phase 8 — Kubernetes LoadBalancer

The application was exposed using a Kubernetes:

```text
Service
type: LoadBalancer
```

The traffic flow is:

```text
Internet
   ↓
Azure Public IP
   ↓
LoadBalancer Service
   ↓
Kubernetes Pods
   ↓
Nginx
   ↓
Static Web Application
```

### Why a LoadBalancer?

Pods are internal Kubernetes workloads.

A LoadBalancer Service provides an external entry point so that users can access the application from outside the cluster.

The service also uses a selector to identify the application Pods.

```yaml
selector:
  app: aks-static-web-app
```

This connects the Service to the matching Pods.

---

# Phase 9 — CI/CD with GitHub Actions

The project was automated using GitHub Actions.

The pipeline follows:

```text
Git Push
   ↓
GitHub Actions
   ↓
Checkout Repository
   ↓
Login to Azure
   ↓
Login to ACR
   ↓
Build Docker Image
   ↓
Push Image to ACR
   ↓
Get AKS Credentials
   ↓
Update Kubernetes Deployment
   ↓
Rolling Update
   ↓
Verify Deployment
```

The container image is tagged using the Git commit SHA:

```text
aks-static-web-app:<commit-sha>
```

### Why use the commit SHA?

Instead of relying only on a mutable tag such as:

```text
latest
```

each deployment receives a unique identifier associated with a specific Git commit.

This makes it easier to identify which version of the source code is running in AKS.

---

# Phase 10 — GitHub OIDC Authentication

GitHub Actions authenticates to Azure using **OpenID Connect (OIDC)**.

The workflow uses:

```yaml
permissions:
  id-token: write
  contents: read
```

GitHub Actions obtains an identity token and Azure verifies that token against the configured federated identity.

The flow is:

```text
GitHub Actions
      │
      │ OIDC Token
      ▼
Microsoft Entra ID
      │
      │ Federated Identity
      ▼
Azure Service Principal
      │
      ▼
Azure Resources
```

### Why OIDC?

Traditional CI/CD pipelines often require long-lived credentials such as client secrets.

OIDC allows the workflow to authenticate without storing a long-lived Azure password/secret in GitHub.

This provides a more modern authentication model for CI/CD.

---

# Phase 11 — Automated Deployment

When changes are pushed to the `main` branch:

```text
Developer
    │
    │ git push
    ▼
GitHub
    │
    ▼
GitHub Actions
    │
    ├── Build image
    │
    ├── Push image to ACR
    │
    └── Update AKS
            │
            ▼
       Kubernetes
            │
            ▼
      Rolling Update
```

The deployment is then verified using:

```bash
kubectl rollout status deployment/aks-static-web-app
```

This confirms that Kubernetes successfully completed the rollout.

![CI/CD Pipeline](./docs/screenshots/phase-05-cicd.png)

---

# Deployment Verification

The Kubernetes environment was verified using:

```bash
kubectl get nodes
```

```bash
kubectl get pods
```

```bash
kubectl get deployment
```

```bash
kubectl get svc
```

The expected application state was:

```text
Deployment: 1
Replicas:   3
Pods:       3 Running
Service:    LoadBalancer
```

The application was then accessed through the Azure public IP address.

---

# What This Project Demonstrates

This project demonstrates practical experience with the following Cloud/DevOps concepts:

### Cloud

* Azure Resource Groups
* Azure Container Registry
* Azure Kubernetes Service
* Azure managed identities
* Azure RBAC

### Containers

* Docker
* Dockerfiles
* Docker image creation
* Container testing
* Container registries

### Kubernetes

* Deployments
* ReplicaSets
* Pods
* Services
* LoadBalancers
* Replica management
* Rolling updates
* Container image deployment

### Infrastructure as Code

* Terraform
* Azure resource provisioning
* Declarative infrastructure
* Repeatable environments

### CI/CD

* GitHub Actions
* Automated Docker builds
* Image publishing
* Kubernetes deployment automation
* Deployment verification

### Identity

* GitHub OIDC
* Microsoft Entra ID
* Federated credentials
* Azure RBAC

### Version Control

* Git
* GitHub
* Commit-based container image tagging

---

# Why This Architecture?

The architecture deliberately separates responsibilities.

| Component             | Responsibility              |
| --------------------- | --------------------------- |
| GitHub                | Source control              |
| GitHub Actions        | Automation                  |
| Docker                | Application packaging       |
| ACR                   | Image storage               |
| Terraform             | Infrastructure provisioning |
| AKS                   | Container orchestration     |
| Kubernetes Deployment | Application lifecycle       |
| Kubernetes Service    | Network exposure            |
| Azure                 | Cloud infrastructure        |

This creates a simple but realistic Cloud/DevOps workflow.

---

# Key Engineering Decisions

### Simple Application

The application was intentionally kept simple.

**Reason:** The purpose of the project is to demonstrate Cloud/DevOps engineering rather than frontend development.

### Docker + Nginx

Nginx provides a lightweight production-style web server for the static application.

### ACR

ACR provides private storage for the Docker image and integrates naturally with Azure.

### AKS

AKS provides managed Kubernetes rather than requiring the Kubernetes control plane to be operated manually.

### Terraform

Terraform makes Azure infrastructure reproducible and version-controlled.

### Three Replicas

Three replicas demonstrate Kubernetes workload management and provide basic redundancy.

### GitHub Actions

GitHub Actions automates the deployment process and removes repetitive manual deployment steps.

### OIDC

OIDC removes the need for long-lived Azure client secrets in the GitHub Actions workflow.

### Commit SHA Image Tags

Each CI/CD deployment produces a uniquely identifiable container image version.

---

# Lessons Learned

This project provided practical experience with the relationship between the major Cloud/DevOps components.

The most important workflow learned was:

```text
Code
 ↓
Git
 ↓
Docker
 ↓
ACR
 ↓
Kubernetes
 ↓
AKS
 ↓
Service
 ↓
Application
```

I also learned that each layer has a different responsibility.

For example:

```text
Docker
→ Packages the application

ACR
→ Stores the image

Kubernetes
→ Manages the application workload

AKS
→ Provides the managed Kubernetes platform

Terraform
→ Creates and manages infrastructure

GitHub Actions
→ Automates the deployment process
```

Understanding these boundaries is important when troubleshooting Cloud/DevOps environments.

---

# Project Outcome

The final environment successfully provides:

```text
Git Push
    ↓
Automated CI/CD
    ↓
Docker Image Build
    ↓
ACR Push
    ↓
AKS Deployment
    ↓
3 Running Pods
    ↓
LoadBalancer
    ↓
Public Application
```

A code change can therefore move from the GitHub repository to the running AKS application through an automated deployment pipeline.

---

# Future Work

This project intentionally focuses on the core **Cloud + Docker + Kubernetes + Terraform + CI/CD** workflow.

Advanced troubleshooting and operational scenarios are being kept as a **separate AKS Troubleshooting project** rather than adding unnecessary complexity to this repository.

Future learning areas may include:

* Kubernetes troubleshooting
* `ImagePullBackOff`
* `CrashLoopBackOff`
* Service selector failures
* Container port problems
* Readiness and liveness failures
* Kubernetes networking
* Monitoring and logging
* Helm
* GitOps
* Argo CD
* Cloud security

These are deliberately outside the scope of this project.

---

# Project Status

**Status: Complete**

The application has been:

* ✅ Developed
* ✅ Containerized
* ✅ Tested locally
* ✅ Stored in Azure Container Registry
* ✅ Deployed to AKS
* ✅ Provisioned with Terraform
* ✅ Configured with ACR Pull permissions
* ✅ Exposed through a LoadBalancer
* ✅ Automated with GitHub Actions
* ✅ Authenticated through Azure OIDC
* ✅ Updated through CI/CD
* ✅ Verified in AKS
* ✅ Documented

---

# Portfolio Focus

This project demonstrates my practical understanding of:

> **Cloud Infrastructure + Containers + Kubernetes + Infrastructure as Code + CI/CD**

It represents an end-to-end deployment workflow rather than a collection of isolated technologies.


