# MuchToDo API

A robust RESTful API for a ToDo application built with Go (Golang). This project features user authentication, JWT-based session management, CRUD operations for ToDo items, and an optional Redis caching layer.

The API is built with a clean, layered architecture to separate concerns, making it scalable and easy to maintain. It includes a full suite of unit and integration tests and provides interactive API documentation via Swagger.

## Features

* **User Management**: Secure user registration, login, update, and deletion.
* **Authentication**: JWT-based authentication that supports both `httpOnly` cookies (for web clients) and `Authorization` headers.
* **CRUD for ToDos**: Full create, read, update, and delete functionality for user-specific ToDo items.
* **Structured Logging**: Configurable, structured JSON logging with request context for production-ready monitoring.
* **Optional Caching**: Redis-backed caching layer that can be toggled on or off via environment variables.
* **API Documentation**: Auto-generated interactive Swagger documentation.
* **Testing**: Comprehensive unit and integration test suites.
* **Graceful Shutdown**: The server shuts down gracefully, allowing active requests to complete.

## Prerequisites

To run this project locally, you will need the following installed:

* **Go**: Version 1.21 or later.
* **Swag CLI**: To generate the Swagger API documentation.
* **Make** (optional, for easier command execution):

  On macOS, you can install `make` via Homebrew if it's not already available:

  ```bash
  brew install make
  ```

  On Linux, `make` is usually pre-installed or available via your package manager.

```bash
go install github.com/swaggo/swag/cmd/swag@latest
```

## Using Make

This project includes a `Makefile` to simplify common development tasks. You can use `make <target>` to run commands such as starting the server, building, running tests, and managing Docker containers.

## Getting Started

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd much-to-do/Server/MuchToDo
```

### 2. Configure Environment Variables

Create a `.env` file in the root of the project by copying the example.

```bash
cp .env.example .env
```

Now, open the `.env` file and **change the** `JWT_SECRET_KEY` to a new, long, random string.

Also, ensure that the `MONGO_URI` and `DB_NAME` points to your local MongoDB instance and db.

You can leave the other variables as they are for local development.

### 3. Start Local Dependencies

With Docker running, start the MongoDB and Redis containers using Docker Compose.

```bash
docker-compose up -d
```
**Or using Make:**
```bash
make dc-up
```

### 4. Install Go Dependencies

Download the necessary Go modules.

```bash
go mod tidy
```
**Or using Make:**
```bash
make tidy
```

### 5. Generate API Documentation

Generate the Swagger/OpenAPI documentation from the code comments.

```bash
swag init -g cmd/api/main.go
```
**Or using Make:**
```bash
make generate-docs
```

### 6. Run the Application

You can now run the API server.

```bash
go run ./cmd/api/main.go
```
**Or using Make (also generates docs first):**
```bash
make run
```

The server will start, and you should see log output in your terminal.

* The API will be available at `http://localhost:8080`.
* The interactive Swagger documentation will be at `http://localhost:8080/swagger/index.html`.

## Running Tests

The project includes both unit and integration tests.

### Run Unit Tests

These tests are fast and do not require any external dependencies.

```bash
go test ./...
```
**Or using Make:**
```bash
make unit-test
```

### Run Integration Tests

These tests require Docker to be running as they spin up their own temporary database and cache containers.

```bash
INTEGRATION=true go test -v --tags=integration ./...
```
**Or using Make:**
```bash
make integration-test
```

The `INTEGRATION=true` environment variable is required to explicitly enable these tests. The `-v` flag provides verbose output.

## Other Useful Make Commands

- **Build the binary:**  
  ```bash
  make build
  ```
- **Clean build artifacts:**  
  ```bash
  make clean
  ```
- **Stop Docker containers:**  
  ```bash
  make dc-down
  ```
- **Restart Docker containers:**  
  ```bash
  make dc-restart
  ```

Refer to the `Makefile` for more available commands.



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
