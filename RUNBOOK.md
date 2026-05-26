# Incident Response Runbook

This runbook is for the Clouding Lab exercises on cloud incident response, Docker troubleshooting, and Kubernetes operations.

## Lab goals

- Detect the symptom quickly
- Confirm the failing component
- Correlate logs, metrics, and traces
- Apply the smallest safe mitigation
- Record the incident and recovery steps

## Local Workflow

### Local Docker Compose Workflow

1. Start the app stack from the repository root.
    ```bash
    docker compose -f deploy/local/docker-compose.yml up -d --build
    ```

2. Start the observability stack in another terminal.
    ```bash
    docker compose -f observability/docker-compose.yml up -d
    ```

3. Open the frontend and the observability UIs.
    - Frontend: [http://localhost:8080](http://localhost:8080)
    - Prometheus: [http://localhost:30090](http://localhost:30090)
    - Grafana: [http://localhost:30300](http://localhost:30300)
    - Jaeger: [http://localhost:31686](http://localhost:31686)
    - Loki: [http://localhost:30310](http://localhost:30310)

4. Use the incident response script to simulate latency, errors, or a crash.
    ```bash
    sh incident-response/inject-faults.sh docker latency orders
    sh incident-response/inject-faults.sh docker errors catalog
    sh incident-response/inject-faults.sh docker crash orders
    ```
    ```powershell
    .\incident-response\inject-faults.ps1 -Mode docker -Scenario latency -Service orders
    .\incident-response\inject-faults.ps1 -Mode docker -Scenario errors -Service catalog
    .\incident-response\inject-faults.ps1 -Mode docker -Scenario crash -Service orders
    ```

5. Use the collection scripts to inspect the problem.
    ```bash
    sh incident-response/collect-logs.sh docker
    sh incident-response/collect-events.sh docker
    ```
    ```powershell
    .\incident-response\collect-logs.ps1 -Mode docker
    .\incident-response\collect-events.ps1 -Mode docker
    ```

6. Check the concise status summary to confirm whether a test is active.
    ```bash
    sh incident-response/check-status.sh docker
    ```
    ```powershell
    .\incident-response\check-status.ps1 -Mode docker
    ```

7. Recover the environment after each scenario.
    ```bash
    sh incident-response/recover-faults.sh docker all
    ```
    ```powershell
    .\incident-response\recover-faults.ps1 -Mode docker -Scenario all
    ```

8. Check Prometheus for service health and Jaeger for traces.

9. When you want to remove the local Docker Compose stacks completely before moving to Kubernetes, stop both the app stack and the observability stack. Keep the downloaded images so the next redeploy is faster.
    ```bash
    # Stop and remove the app stack containers, anonymous volumes, and orphaned containers
    docker compose -f deploy/local/docker-compose.yml down --volumes --remove-orphans

    # Stop and remove the observability stack containers, anonymous volumes, and orphaned containers
    docker compose -f observability/docker-compose.yml down --volumes --remove-orphans

    # Remove the shared network only after both stacks are down (safe to ignore the error)
    docker network rm clouding-lab || true
    ```

### Local Kubernetes Workflow

1. Build the application images locally and make them available to your Kubernetes cluster before applying the manifests.
    ```bash
    # Build the local images from the repository root
    docker build -t clouding-users:latest services/users
    docker build -t clouding-orders:latest services/orders
    docker build -t clouding-catalog:latest services/catalog
    docker build -t clouding-frontend:latest frontend
    ```

    If your cluster does not use the same Docker daemon as your shell, load the images into the cluster runtime first.
    - kind: `kind load docker-image clouding-users:latest clouding-orders:latest clouding-catalog:latest clouding-frontend:latest`
    - minikube: `minikube image load clouding-users:latest clouding-orders:latest clouding-catalog:latest clouding-frontend:latest`
    - Docker Desktop Kubernetes: the images built above are usually enough if Docker Desktop is the active daemon


2. Create the namespace first and wait for it to be ready.
    ```bash
    kubectl apply -f deploy/local/k8s/namespace.yaml
    kubectl wait --for=jsonpath='{.status.phase}'=Active namespace/clouding-lab --timeout=60s
    ```

3. Apply all local Kubernetes manifests after the namespace is ready.
    ```bash
    kubectl apply -f deploy/local/k8s/
    ```

4. Check the namespace, pods, and services.
    ```bash
    kubectl get namespace clouding-lab
    kubectl get pods -n clouding-lab
    kubectl get svc -n clouding-lab
    ```

5. Inspect the service health endpoints and compare them with the dashboards.
    ```bash
    kubectl port-forward -n clouding-lab svc/frontend 8080:80
    kubectl port-forward -n clouding-lab svc/users 3001:3001
    kubectl port-forward -n clouding-lab svc/orders 3002:3002
    kubectl port-forward -n clouding-lab svc/catalog 3003:3003
    ```

6. Open the frontend and the observability UIs.
    - Frontend: [http://localhost:30080](http://localhost:30080) (if `frontend` Service type is `NodePort`) or use the port-forward URL [http://localhost:8080](http://localhost:8080)
    - Grafana: [http://localhost:30300](http://localhost:30300)
    - Prometheus: [http://localhost:30090](http://localhost:30090)
    - Jaeger: [http://localhost:31686](http://localhost:31686)
    - Loki: [http://localhost:30310](http://localhost:30310)

7. Reproduce the incident and confirm that readiness and liveness probes react as expected.
    ```bash
    sh incident-response/inject-faults.sh k8s crash orders clouding-lab
    ```
    ```powershell
    .\incident-response\inject-faults.ps1 -Mode k8s -Scenario crash -Service orders -Namespace clouding-lab
    ```

8. Check the concise status summary for the namespace.
    ```bash
    sh incident-response/check-status.sh k8s clouding-lab
    ```
    ```powershell
    .\incident-response\check-status.ps1 -Mode k8s -Namespace clouding-lab
    ```

9. Recover the deployment and confirm pods become healthy again.
    ```bash
    sh incident-response/recover-faults.sh k8s all orders clouding-lab
    ```
    ```powershell
    .\incident-response\recover-faults.ps1 -Mode k8s -Scenario all -Service orders -Namespace clouding-lab
    ```

## AWS Workflow

### AWS Docker Compose Workflow

### AWS Kubernetes Workflow

## Azure Workflow

### Azure Docker Compose Workflow

### Azure Kubernetes Workflow

## GCP Workflow

### GCP Docker Compose Workflow

### GCP Kubernetes Workflow


