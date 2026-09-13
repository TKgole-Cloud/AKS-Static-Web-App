# AKS Static Web App

A simple static web application built with **HTML, CSS, and Vanilla JavaScript**, containerized with **Docker**, stored in **Azure Container Registry (ACR)**, and deployed to **Azure Kubernetes Service (AKS)**.

The main goal of this project is to gain practical, hands-on experience with a complete **Cloud & DevOps deployment workflow**.

The project follows this flow:

```text
HTML / CSS / JavaScript
          │
          ▼
      Git / GitHub
          │
          ▼
        Docker
          │
          ▼
   Docker Container
      (local test)
          │
          ▼
 Azure Container Registry
          │
          ▼
          AKS
          │
          ▼
 Kubernetes Deployment
       3 replicas
          │
          ▼
 Kubernetes Service
      LoadBalancer
          │
          ▼
     Azure Public IP
          │
          ▼
     Web Browser
```

---

# Project Architecture

```text
                         Internet
                            │
                            ▼
                  Azure Load Balancer
                            │
                            ▼
               Kubernetes LoadBalancer
                       Service
                            │
              ┌─────────────┼─────────────┐
              ▼             ▼             ▼
           Pod 1          Pod 2          Pod 3
              │             │             │
              └─────────────┼─────────────┘
                            │
                         Nginx
                            │
                            ▼
                  Static Web Application


Docker Image
     │
     ▼
Azure Container Registry
     │
     │ AcrPull permission
     ▼
     AKS
```

---

# Technology Stack

| **Layer**         | **Technology**                 | **What we learn**            |
| ----------------- | ------------------------------ | ---------------------------- |
| Frontend          | HTML5                          | Web structure                |
| Styling           | CSS3                           | UI/styling                   |
| Logic             | Vanilla JavaScript             | Browser-side functionality   |
| Container         | Docker                         | Package the application      |
| Container Runtime | Docker Container               | Run and test the application |
| Registry          | Azure Container Registry       | Store Docker images          |
| Orchestration     | Azure Kubernetes Service (AKS) | Run and manage containers    |
| IaC               | Terraform                      | Build Azure infrastructure   |
| CI/CD             | GitHub Actions                 | Automate build/deployment    |
| Source Control    | Git/GitHub                     | Version control              |

---

# 1. Build the Static Web Application

The application was created using three basic web technologies:

```text
app/
├── index.html
├── style.css
└── script.js
```

### Why?

The application itself is intentionally simple.

The purpose of this project is to focus on **Cloud and DevOps**, rather than spending most of the project building a complicated frontend.

The application gives us something real to containerize and deploy.

---

# 2. Containerize the Application with Docker

A Dockerfile was created inside:

```text
docker/Dockerfile
```

The Dockerfile uses Nginx as the web server:

```dockerfile
FROM nginx:alpine

COPY app/ /usr/share/nginx/html/

EXPOSE 80
```

### Why Docker?

Docker packages the application and everything required to run it into a **container image**.

Instead of relying on the environment of the machine running the application, we create a repeatable package that can be run locally or in the cloud.

The basic idea is:

```text
Application Files
       │
       ▼
 Dockerfile
       │
       ▼
 Docker Image
```

---

# 3. Build the Docker Image

The image was built from the project root:

```bash
docker build -t aks-static-web-app:v1 -f docker/Dockerfile .
```

The `-t` option gives the image a name and tag:

```text
aks-static-web-app:v1
```

### Why build an image?

A Docker image is the **package we eventually deploy to Kubernetes**.

The important distinction is:

```text
Dockerfile  → instructions
Docker Image → packaged application
Docker Container → running instance of the image
```

---

# 4. Run the Docker Container Locally

Before sending anything to Azure, the image was tested locally as a container.

```bash
docker run -d -p 8080:80 --name aks-static-web-app aks-static-web-app:v1
```

The application was then accessed through:

```text
http://localhost:8080
```

### Why test locally first?

We don't want to troubleshoot multiple systems at the same time.

If the application doesn't work inside a local Docker container, there is no reason to immediately introduce:

* Azure Container Registry
* AKS
* Kubernetes
* Load Balancers

The workflow is therefore:

```text
Build
  ↓
Test locally
  ↓
Only then deploy to Azure
```

This isolates problems and makes troubleshooting easier.

---

# 5. Create Azure Container Registry

Terraform was used to create an **Azure Container Registry (ACR)**.

ACR is used to store our Docker image in Azure.

```text
Local Machine
     │
     │ docker push
     ▼
Azure Container Registry
     │
     │ image stored here
     ▼
aks-static-web-app:v1
```

### Why ACR?

AKS needs somewhere to obtain the container image.

Instead of keeping the image only on the local computer, we store it in a cloud container registry that can be accessed by AKS.

ACR becomes the bridge between:

```text
Docker
   ↓
Container Registry
   ↓
AKS
```

---

# 6. Create AKS with Terraform

Terraform was used to provision the AKS cluster.

The infrastructure created for the project includes:

* Azure Resource Group
* Azure Container Registry
* Azure Kubernetes Service
* AKS managed identity
* ACR pull permission for AKS

### Why Terraform?

Terraform allows the Azure infrastructure to be defined as code.

Instead of manually creating resources through the Azure Portal, the infrastructure can be recreated from the Terraform configuration.

This gives us:

* Repeatability
* Version control
* Consistency
* Easier cleanup
* Infrastructure documentation

The architecture therefore becomes:

```text
Terraform
    │
    ├── Resource Group
    ├── ACR
    └── AKS
```

---

# 7. Give AKS Permission to Pull from ACR

AKS needs permission to retrieve our Docker image from ACR.

The AKS kubelet identity was given the:

```text
AcrPull
```

role on the Azure Container Registry.

This allows AKS to pull images from ACR without storing registry usernames and passwords inside Kubernetes.

```text
AKS Managed Identity
        │
        │ AcrPull
        ▼
Azure Container Registry
```

### Why?

This follows a better cloud authentication pattern:

**Use Azure identity and RBAC instead of hard-coded credentials.**

---

# 8. Push the Docker Image to ACR

The local image:

```text
aks-static-web-app:v1
```

was tagged with the ACR registry name:

```text
aksstaticwebappacr.azurecr.io/aks-static-web-app:v1
```

Then it was pushed:

```bash
docker push aksstaticwebappacr.azurecr.io/aks-static-web-app:v1
```

The image is now available inside Azure Container Registry.

```text
Local Docker Image
        │
        │ docker push
        ▼
       ACR
        │
        ▼
aks-static-web-app:v1
```

---

# 9. Deploy the Application to AKS

A Kubernetes Deployment was created:

```text
k8s/deployment.yaml
```

The Deployment points to the image stored in ACR:

```yaml
image: aksstaticwebappacr.azurecr.io/aks-static-web-app:v1
```

The Deployment was configured with:

```yaml
replicas: 3
```

### Why 3 replicas?

Instead of running only one Pod, Kubernetes runs three copies of the application.

```text
Deployment
    │
    ├── Pod 1
    ├── Pod 2
    └── Pod 3
```

This gives us basic redundancy and allows Kubernetes to distribute incoming requests across multiple application instances.

It also gives us practical experience with one of Kubernetes' most important concepts:

**A Deployment manages the desired number of application replicas.**

---

# 10. Create a Kubernetes LoadBalancer Service

A Kubernetes Service was created:

```text
k8s/service.yaml
```

The Service uses:

```yaml
type: LoadBalancer
```

The Service selects the Pods using:

```yaml
selector:
  app: aks-static-web-app
```

and exposes port 80:

```yaml
ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

### Why use a Service?

Pods are temporary Kubernetes resources. Their IP addresses can change.

The Service provides a **stable endpoint** for accessing the application.

The LoadBalancer type also asks Azure to provision an external load balancer and public IP.

The traffic flow becomes:

```text
Internet
   │
   ▼
Azure Load Balancer
   │
   ▼
Kubernetes Service
   │
   ├── Pod 1
   ├── Pod 2
   └── Pod 3
```

---

# 11. Verify the Deployment

The Kubernetes Pods were checked with:

```bash
kubectl get pods
```

The expected result was three running replicas:

```text
NAME                         READY   STATUS
aks-static-web-app-xxxxx     1/1     Running
aks-static-web-app-xxxxx     1/1     Running
aks-static-web-app-xxxxx     1/1     Running
```

The Service was checked with:

```bash
kubectl get service
```

The Service received an external IP from Azure.

---

# 12. Access the Application from the Browser

The application was finally accessed using the external IP assigned to the Kubernetes LoadBalancer Service.

```text
Browser
   │
   ▼
Public IP
   │
   ▼
Azure Load Balancer
   │
   ▼
Kubernetes Service
   │
   ├── Pod 1
   ├── Pod 2
   └── Pod 3
   │
   ▼
Nginx
   │
   ▼
Static Web Application
```

The application successfully loaded in the browser.

This confirms that the complete deployment path is working:

```text
Source Code
     ↓
Docker Image
     ↓
Local Container Test
     ↓
Azure Container Registry
     ↓
AKS
     ↓
3 Kubernetes Replicas
     ↓
LoadBalancer Service
     ↓
Public IP
     ↓
Browser
```

---

# Current Project Status

| Component                       | Status       |
| ------------------------------- | ------------ |
| HTML/CSS/JavaScript application | ✅ Complete   |
| Dockerfile                      | ✅ Complete   |
| Docker image                    | ✅ Built      |
| Local Docker container test     | ✅ Working    |
| Azure Container Registry        | ✅ Created    |
| Docker image pushed to ACR      | ✅ Complete   |
| AKS cluster                     | ✅ Created    |
| AKS → ACR authentication        | ✅ Configured |
| Kubernetes Deployment           | ✅ Complete   |
| 3 application replicas          | ✅ Running    |
| LoadBalancer Service            | ✅ Complete   |
| Public IP                       | ✅ Assigned   |
| Browser access                  | ✅ Working    |

---

# Project Structure

```text
aks-static-webapp/
│
├── app/
│   ├── index.html
│   ├── style.css
│   └── script.js
│
├── docker/
│   └── Dockerfile
│
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
│
├── terraform/
│   ├── main.tf
│   └── outputs.tf
│
├── docs/
│   └── architecture diagram/
│
├── .github/
│   └── workflows/
│
├── .gitignore
└── README.md
```

# Next Phase

The next stage of the project will focus on **CI/CD with GitHub Actions**.

The goal is to automate the process so that instead of manually building and pushing the image, a GitHub workflow can:

```text
Git Push
   ↓
GitHub Actions
   ↓
Build Docker Image
   ↓
Push Image to ACR
   ↓
Deploy Updated Image to AKS
```

This will complete the core **build → containerize → registry → Kubernetes → deployment automation** workflow.
