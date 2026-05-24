# Deploy local

## Docker Compose

1. From the repository root, start the application stack.
	```bash
	docker compose -f deploy/local/docker-compose.yml up --build
	```
2. In a second terminal, start the observability stack.
	```bash
	docker compose -f observability/docker-compose.yml up -d
	```
3. Open the frontend at `http://localhost:8080` and the service health endpoints.
4. Use the scripts in `incident-response/` to inject faults and collect evidence.

## Kubernetes

1. Make sure Docker Desktop Kubernetes is enabled.
2. Apply the namespace, services, deployments, and ingress.
	```bash
	kubectl apply -f deploy/local/k8s/
	```
3. Apply the observability stack.
	```bash
	kubectl apply -f deploy/local/k8s/observability.yaml
	```
4. Verify the workloads.
	```bash
	kubectl get pods -n clouding-lab
	kubectl get svc -n clouding-lab
	```
5. Use `incident-response/collect-logs.sh` and `incident-response/collect-events.sh` to inspect the incident.