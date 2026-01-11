# MuchTodo Containerization Assessment

## How to Run
1. **Local Dev:** Run `docker-compose up` to test the Node/Mongo setup.
2. **Kubernetes:** Run `./scripts/k8s-deploy.sh` to launch the full cluster.
3. **Verify:** Once pods are running, visit `http://localhost/health`.

## Tech Stack
- **Backend:** Node.js (Express)
- **Database:** MongoDB
- **Orchestration:** Kind (Kubernetes)
- **Ingress:** NGINX