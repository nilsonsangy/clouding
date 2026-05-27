# Clouding Lab Local Environment Runbook

## Docker Compose Workflow

1. From the repository root, start the application stack.

```bash
docker compose -f local/docker-compose.yml up -d --build
```

2. Start the observability stack.

```bash
docker compose -f local/observability/docker-compose.yml up -d
```

3. Open the frontend and observability UIs.

- Frontend: http://localhost:8080
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3005
- Jaeger: http://localhost:16686
- Loki: http://localhost:3100

4. Use the incident response scripts to inject faults and collect evidence.

    - Linux
    ```bash
    sh local/incident-response/inject-faults.sh docker latency orders
    sh local/incident-response/inject-faults.sh docker errors catalog
    sh local/incident-response/inject-faults.sh docker crash orders

    sh local/incident-response/collect-logs.sh docker
    sh local/incident-response/collect-events.sh docker

    sh local/incident-response/check-status.sh docker

    sh local/incident-response/recover-faults.sh docker all
    ```

    - Windows
    ```powershell
    .\local\incident-response\inject-faults.ps1 -Mode docker -Scenario latency -Service orders
    .\local\incident-response\inject-faults.ps1 -Mode docker -Scenario errors -Service catalog
    .\local\incident-response\inject-faults.ps1 -Mode docker -Scenario crash -Service orders

    .\local\incident-response\collect-logs.ps1 -Mode docker
    .\local\incident-response\collect-events.ps1 -Mode docker

    .\local\incident-response\check-status.ps1 -Mode docker

    .\local\incident-response\recover-faults.ps1 -Mode docker -Scenario all
    ```

5. When you want to clean the local environment and remove the running containers, stop both stacks but keep the downloaded images so the next build is faster.

```bash
docker compose -f local/docker-compose.yml down --volumes --remove-orphans
docker compose -f local/observability/docker-compose.yml down --volumes --remove-orphans
docker network rm clouding-lab
```

## Kubernetes Workflow

1. Make sure Docker Desktop Kubernetes is enabled.

2. Build the local images.

```bash
docker build -t clouding-users:latest app/users
docker build -t clouding-orders:latest app/orders
docker build -t clouding-catalog:latest app/catalog
docker build -t clouding-frontend:latest frontend
docker build -t clouding-frontend:latest app/frontend
```

3. Load the images into the cluster runtime if your Kubernetes environment needs it.

- kind: `kind load docker-image clouding-users:latest clouding-orders:latest clouding-catalog:latest clouding-frontend:latest`
- minikube: `minikube image load clouding-users:latest clouding-orders:latest clouding-catalog:latest clouding-frontend:latest`
- Docker Desktop Kubernetes usually reads the local Docker daemon directly.

4. Apply the namespace first, then the Kubernetes manifests.

```bash
kubectl apply -f local/k8s/namespace.yaml
kubectl apply -f local/k8s/
```

5. Apply the observability stack.

```bash
kubectl apply -f local/k8s/observability.yaml
```

6. Verify the workloads.

```bash
kubectl get namespace clouding-lab
kubectl get pods -n clouding-lab
kubectl get svc -n clouding-lab
```

7. Open the frontend and observability endpoints.

- Frontend: http://clouding.local or http://localhost:30080 if you prefer the NodePort service
- Grafana: http://localhost:3005
- Prometheus: http://localhost:9090
- Jaeger: http://localhost:16686
- Loki: http://localhost:3100

8. Use the incident response scripts to reproduce and inspect a fault.

```bash
sh local/incident-response/inject-faults.sh k8s crash orders clouding-lab
sh local/incident-response/check-status.sh k8s clouding-lab
sh local/incident-response/recover-faults.sh k8s all orders clouding-lab
```
