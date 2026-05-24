# Deploy Azure

## Docker Compose

1. Start the app stack on an Azure VM or container host.
	```bash
	docker compose -f deploy/azure/docker-compose.yml up --build
	```
2. Publish the app through Azure networking resources.
3. Optionally run `observability/docker-compose.yml` for the monitoring stack.

## Kubernetes

1. Use AKS.
2. Apply the manifests for this environment.
	```bash
	kubectl apply -f deploy/azure/k8s/
	```
3. Apply the observability stack.
	```bash
	kubectl apply -f deploy/azure/k8s/observability.yaml
	```
4. Configure ingress, secrets, and observability.