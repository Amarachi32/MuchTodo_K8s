#!/bin/bash

# 1. Create cluster with port mapping
kind create cluster --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 8081
    protocol: TCP
EOF

# 2. Install Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# --- PRO ADDITION: Wait for Ingress Controller to be ready ---
echo "Waiting for Ingress Controller to initialize..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# 3. Build and Load Image
# (Using the tag 'latest' is fine for this assessment)
docker build -t muchtodo-backend:latest .
kind load docker-image muchtodo-backend:latest --name kind

# 4. Apply all manifests in logical order
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/mongodb/
kubectl apply -f kubernetes/backend/
kubectl apply -f kubernetes/ingress.yaml

echo "Deployment complete! Visit http://localhost:8081/health"