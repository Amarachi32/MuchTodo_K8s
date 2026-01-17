# DEVOP PRACTICE

# MuchTodo Backend: Containerization & Orchestration

This project modernizes the MuchTodo Node.js API by containerizing it with Docker and deploying it to a local Kubernetes cluster using Kind.

## 🏗 Project Architecture
The application consists of a Node.js backend connected to a MongoDB database. In Kubernetes, this is orchestrated with high availability and security in mind.

### Key Technical Decisions
- **Multi-stage Docker Build**: Reduced image size and attack surface by separating the build environment from the runtime environment.  
- **Security**: The application runs as a non-root user (`appuser`) inside the container to follow the principle of least privilege.  
- **Persistence**: MongoDB data is stored in a Persistent Volume Claim (PVC), ensuring data survives pod restarts.  
- **Scalability**: The backend API is configured with 2 replicas for load balancing and redundancy.  
- **Ingress Routing**: Used NGINX Ingress Controller to expose the service on a custom host port (`8081`) to avoid local system conflicts on port 80.  

## 🚀 Getting Started

### Prerequisites
- Docker Desktop  
- Kind (`choco install kind`)  
- Kubectl  

## Tech Stack
- **Backend:** Node.js (Express)
- **Database:** MongoDB
- **Orchestration:** Kind (Kubernetes)
- **Ingress:** NGINX

## How to Run
1. **Local Dev:** Run `docker-compose up` to test the Node/Mongo setup.
2. **Kubernetes:** Run `./scripts/k8s-deploy.sh` to launch the full cluster.
3. **Verify:** Once pods are running, visit `http://localhost/health`.

## 2. Kubernetes Deployment (Production-like)

To deploy the entire stack to a Kind cluster automatically:

```bash
chmod +x scripts/*.sh
./scripts/k8s-deploy.sh
```

## 📁 Project Structure

```plaintext
container-assessment/
├── kubernetes/           # K8s Manifests
│   ├── namespace.yaml    # Resource isolation
│   ├── mongodb/          # DB Deployment, Service, PVC, Secret
│   ├── backend/          # API Deployment, Service, ConfigMap
│   └── ingress.yaml      # External access configuration
├── scripts/              # Automation tools
├── evidence/             # Deployment screenshots
├── Dockerfile            # Multi-stage build
└── docker-compose.yml    # Local dev orchestration
```

## 🔍 Verification & Evidence

Once deployed, verify the status of the resources:

- **Check Pods**:  
  ```bash
  kubectl get pods -n muchtodo

- **Check Health**: Visit http://localhost:8081/health in your browser.

## 📸 Evidence Screenshots

Detailed evidence of the successful deployment can be found in the `/evidence` folder:

- `browser_health_check`: Confirms the API is responding through the Ingress with a {"status":"ok","db":"connected"} message  
- `app_swagger_ui` : Displays the interactive Swagger UI at http://localhost:8081/swagger/index.html, proving the documentation is live and reachable.
- `app_logs_connected`: Check if the server is actually running.  
- `k8s_pods_running`: Shows all pods, including backend-api and mongodb, in a Running state
- `k8s_ingress_svc.png`: Displays the networking configuration, confirming the Ingress is routing traffic to the backend service.
