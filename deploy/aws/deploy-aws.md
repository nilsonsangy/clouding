# Deploy AWS

## Docker Compose

1. Start the app stack on an EC2 instance or on a Docker host.
	```bash
	docker compose -f deploy/aws/docker-compose.yml up --build
	```
2. Open the frontend and expose ports through the security group or load balancer.
3. Use the observability stack from `observability/docker-compose.yml` if you want the same local monitoring flow.

## Kubernetes

1. Use EKS or another managed Kubernetes cluster.
2. Apply the manifests for this environment.
	```bash
	kubectl apply -f deploy/aws/k8s/
	```
3. Apply the observability stack.
	```bash
	kubectl apply -f deploy/aws/k8s/observability.yaml
	```
4. Confirm that the namespace, deployments, and services are ready.