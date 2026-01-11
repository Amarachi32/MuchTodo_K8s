# #!/bin/bash

# # Create Kind Cluster with Ingress support
# cat <<EOF | kind create cluster --config=-
# kind: Cluster
# apiVersion: kind.x-k8s.io/v1alpha4
# nodes:
# - role: control-plane
#   kubeadmConfigPatches:
#   - |
#     kind: InitConfiguration
#     nodeRegistration:
#       kubeletExtraArgs:
#         node-labels: "ingress-ready=true"
#   extraPortMappings:
#   - containerPort: 80
#     hostPort: 80
#     protocol: TCP
#   - containerPort: 443
#     hostPort: 443
#     protocol: TCP
# EOF

# # Build and load image
# docker build -t muchtodo-backend:latest .
# kind load docker-image muchtodo-backend:latest

# # Create namespace
# kubectl create namespace muchtodo

# # Apply Manifests
# kubectl apply -f kubernetes/mongodb/
# kubectl apply -f kubernetes/backend/
# kubectl apply -f kubernetes/ingress.yaml

# echo "Waiting for pods to be ready..."
# kubectl get pods -n muchtodo -w

#!/bin/bash

# 1. Create Kind Cluster with port 80 open for the Ingress
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 8081
    protocol: TCP
EOF

# 2. Build the local image
echo "Building Docker image..."
docker build -t muchtodo-backend:latest .

# 3. Load the image into Kind 
# (Kind doesn't use Docker Hub, it needs you to "push" the image into its internal registry)
echo "Loading image into Kind..."
kind load docker-image muchtodo-backend:latest

# 4. Install Nginx Ingress Controller (The tool that reads your ingress.yaml)
echo "Installing Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# 5. Wait for Ingress to be ready
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s

# 6. Apply our manifests
echo "Deploying MuchTodo application..."
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/mongodb/
kubectl apply -f kubernetes/backend/
kubectl apply -f kubernetes/ingress.yaml

echo "Done! Give it a minute, then visit http://localhost/health"