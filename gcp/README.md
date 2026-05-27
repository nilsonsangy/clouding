# Clouding Lab GCP Environment Runbook

## Docker Compose Workflow

1. Build and push the application images to Artifact Registry.

```bash
export GCP_PROJECT_ID=clouding-project
export GCP_REGION=us-central1
export GCP_ARTIFACT_REGISTRY=$GCP_REGION-docker.pkg.dev/$GCP_PROJECT_ID/clouding-repo
export IMAGE_TAG=latest

gcloud auth configure-docker $GCP_REGION-docker.pkg.dev

docker build -t clouding-users:$IMAGE_TAG app/users
docker build -t clouding-orders:$IMAGE_TAG app/orders
docker build -t clouding-catalog:$IMAGE_TAG app/catalog
docker build -t clouding-frontend:$IMAGE_TAG app/frontend

docker tag clouding-users:$IMAGE_TAG $GCP_ARTIFACT_REGISTRY/clouding-users:$IMAGE_TAG
docker tag clouding-orders:$IMAGE_TAG $GCP_ARTIFACT_REGISTRY/clouding-orders:$IMAGE_TAG
docker tag clouding-catalog:$IMAGE_TAG $GCP_ARTIFACT_REGISTRY/clouding-catalog:$IMAGE_TAG
docker tag clouding-frontend:$IMAGE_TAG $GCP_ARTIFACT_REGISTRY/clouding-frontend:$IMAGE_TAG

docker push $GCP_ARTIFACT_REGISTRY/clouding-users:$IMAGE_TAG
docker push $GCP_ARTIFACT_REGISTRY/clouding-orders:$IMAGE_TAG
docker push $GCP_ARTIFACT_REGISTRY/clouding-catalog:$IMAGE_TAG
docker push $GCP_ARTIFACT_REGISTRY/clouding-frontend:$IMAGE_TAG
```

2. Provision a Compute Engine VM or container host with Docker Engine and the Docker Compose plugin.
   - Make sure the VM has permission to pull from Artifact Registry.
   - Open only the frontend port and any diagnostics you need.

3. Start the Compose stack.

```bash
export GCP_ARTIFACT_REGISTRY=us-central1-docker.pkg.dev/clouding-project/clouding-repo
export IMAGE_TAG=latest
export OTEL_DISABLED=true

docker compose -f gcp/docker-compose.yml pull
docker compose -f gcp/docker-compose.yml up -d
```

4. Validate the application.
   - Frontend: public VM address or GCP load balancer DNS name
   - Users: http://<host>:3001/health
   - Orders: http://<host>:3002/health
   - Catalog: http://<host>:3003/health

5. If you want the local-style monitoring flow, run the observability stack separately.

## Kubernetes Workflow

1. Use GKE and configure `kubectl`.

2. Make sure GKE can pull from Artifact Registry.
   - Prefer granting the node or workload identity the right registry permissions.
   - If needed, create an `imagePullSecret` first.

3. Apply the namespace and application manifests.

```bash
kubectl apply -f gcp/k8s/namespace.yaml
kubectl apply -f gcp/k8s/
```

4. Apply the observability stack.

```bash
kubectl apply -f gcp/k8s/observability.yaml
```

5. Verify the workloads.

```bash
kubectl get namespace clouding-lab
kubectl get pods -n clouding-lab
kubectl get svc -n clouding-lab
kubectl get ingress -n clouding-lab
```

6. Expose the app.
   - The ingress host is `gcp.clouding.example`.
   - Point DNS to the ingress controller or load balancer.

7. Confirm health and telemetry.
   - Frontend should answer through the ingress endpoint.
   - `users`, `orders`, and `catalog` should be healthy inside the cluster.
   - Prometheus, Grafana, and Jaeger should be reachable through the observability services.
