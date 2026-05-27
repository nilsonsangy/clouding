# Clouding Lab Azure Environment Runbook

## Docker Compose Workflow

1. Build and push the application images to Azure Container Registry.

```bash
export AZURE_ACR_NAME=clouding
export AZURE_ACR_LOGIN_SERVER=$AZURE_ACR_NAME.azurecr.io
export IMAGE_TAG=latest

az acr login --name $AZURE_ACR_NAME

docker build -t clouding-users:$IMAGE_TAG app/users
docker build -t clouding-orders:$IMAGE_TAG app/orders
docker build -t clouding-catalog:$IMAGE_TAG app/catalog
docker build -t clouding-frontend:$IMAGE_TAG app/frontend

docker tag clouding-users:$IMAGE_TAG $AZURE_ACR_LOGIN_SERVER/clouding-users:$IMAGE_TAG
docker tag clouding-orders:$IMAGE_TAG $AZURE_ACR_LOGIN_SERVER/clouding-orders:$IMAGE_TAG
docker tag clouding-catalog:$IMAGE_TAG $AZURE_ACR_LOGIN_SERVER/clouding-catalog:$IMAGE_TAG
docker tag clouding-frontend:$IMAGE_TAG $AZURE_ACR_LOGIN_SERVER/clouding-frontend:$IMAGE_TAG

docker push $AZURE_ACR_LOGIN_SERVER/clouding-users:$IMAGE_TAG
docker push $AZURE_ACR_LOGIN_SERVER/clouding-orders:$IMAGE_TAG
docker push $AZURE_ACR_LOGIN_SERVER/clouding-catalog:$IMAGE_TAG
docker push $AZURE_ACR_LOGIN_SERVER/clouding-frontend:$IMAGE_TAG
```

2. Provision an Azure VM or container host with Docker Engine and the Docker Compose plugin.
   - Attach the right identity or credentials so the host can pull from ACR.
   - Open only the frontend port and any diagnostics you need.

3. Start the Compose stack.

```bash
export AZURE_ACR_LOGIN_SERVER=clouding.azurecr.io
export IMAGE_TAG=latest
export OTEL_DISABLED=true

docker compose -f azure/docker-compose.yml pull
docker compose -f azure/docker-compose.yml up -d
```

4. Validate the application.
   - Frontend: public VM address or Azure load balancer DNS name
   - Users: http://<host>:3001/health
   - Orders: http://<host>:3002/health
   - Catalog: http://<host>:3003/health

5. If you want the local-style monitoring flow, run the observability stack separately.

## Kubernetes Workflow

1. Use AKS and configure `kubectl`.

2. Make sure AKS can pull from ACR.
   - Prefer attaching the ACR to the AKS cluster.
   - If needed, create an `imagePullSecret` first.

3. Apply the namespace and application manifests.

```bash
kubectl apply -f azure/k8s/namespace.yaml
kubectl apply -f azure/k8s/
```

4. Apply the observability stack.

```bash
kubectl apply -f azure/k8s/observability.yaml
```

5. Verify the workloads.

```bash
kubectl get namespace clouding-lab
kubectl get pods -n clouding-lab
kubectl get svc -n clouding-lab
kubectl get ingress -n clouding-lab
```

6. Expose the app.
   - The ingress host is `azure.clouding.example`.
   - Point DNS to the ingress controller or Azure load balancer.

7. Confirm health and telemetry.
   - Frontend should answer through the ingress endpoint.
   - `users`, `orders`, and `catalog` should be healthy inside the cluster.
   - Prometheus, Grafana, and Jaeger should be reachable through the observability services.
