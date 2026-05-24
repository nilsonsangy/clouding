# Deploy GCP

## Docker Compose

1. Run the app stack on a Compute Engine VM or container host.
   ```bash
   docker compose -f deploy/gcp/docker-compose.yml up --build
   ```
2. Expose the app with firewall rules or a load balancer.
3. Optionally add the observability stack from `observability/docker-compose.yml`.

## Kubernetes

1. Use GKE.
2. Apply the manifests for this environment.
   ```bash
   kubectl apply -f deploy/gcp/k8s/
   ```
3. Apply the observability stack.
   ```bash
   kubectl apply -f deploy/gcp/k8s/observability.yaml
   ```
4. Configure ingress, secrets, and observability.