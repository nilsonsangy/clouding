# Incident Response Runbook

This runbook is for the Clouding Lab exercises on cloud incident response, Docker troubleshooting, and Kubernetes operations.

## Lab goals

- Detect the symptom quickly
- Confirm the failing component
- Correlate logs, metrics, and traces
- Apply the smallest safe mitigation
- Record the incident and recovery steps

## Local Docker Compose workflow

1. Start the app stack from the repository root.
	```bash
	docker compose -f deploy/local/docker-compose.yml up -d --build
	```
2. Start the observability stack in another terminal.
	```bash
	docker compose -f observability/docker-compose.yml up -d
	```
3. Open the frontend and the observability UIs.
	- [Frontend](http://localhost:8080)
	- [Grafana](http://localhost:3005)
	- [Prometheus](http://localhost:9090)
	- [Jaeger](http://localhost:16686)
	- [Loki](http://localhost:3100)
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

## Local Kubernetes workflow

1. Apply the app manifests.
	```bash
	kubectl apply -f deploy/local/k8s/
	```
2. Apply the local observability manifest.
	```bash
	kubectl apply -f deploy/local/k8s/observability.yaml
	```
3. Check the namespace, pods, and services.
	```bash
	kubectl get namespace clouding-lab
	kubectl get pods -n clouding-lab
	kubectl get svc -n clouding-lab
	```
4. Use the NodePort services to open Prometheus, Grafana, Jaeger, and Loki.
	```text
	Prometheus: http://localhost:30090
	Grafana: http://localhost:30300
	Jaeger: http://localhost:31686
	Loki: http://localhost:30310
	```
5. Inspect the service health endpoints and compare them with the dashboards.
	```bash
	kubectl port-forward -n clouding-lab svc/frontend 8080:80
	kubectl port-forward -n clouding-lab svc/users 3001:3001
	kubectl port-forward -n clouding-lab svc/orders 3002:3002
	kubectl port-forward -n clouding-lab svc/catalog 3003:3003
	```
6. Reproduce the incident and confirm that readiness and liveness probes react as expected.
	```bash
	sh incident-response/inject-faults.sh k8s crash orders clouding-lab
	```
	```powershell
	.\incident-response\inject-faults.ps1 -Mode k8s -Scenario crash -Service orders -Namespace clouding-lab
	```
7. Check the concise status summary for the namespace.
	```bash
	sh incident-response/check-status.sh k8s clouding-lab
	```
	```powershell
	.\incident-response\check-status.ps1 -Mode k8s -Namespace clouding-lab
	```
8. Recover the deployment and confirm pods become healthy again.
	```bash
	sh incident-response/recover-faults.sh k8s all orders clouding-lab
	```
	```powershell
	.\incident-response\recover-faults.ps1 -Mode k8s -Scenario all -Service orders -Namespace clouding-lab
	```

## Kubernetes workflow

1. Apply the manifests in the chosen environment folder under `deploy/`.
	```bash
	kubectl apply -f deploy/<local|aws|azure|gcp>/k8s/
	```
2. Confirm namespace, deployments, services, and ingress.
	```bash
	kubectl get namespace clouding-lab
	kubectl get deployments -n clouding-lab
	kubectl get svc -n clouding-lab
	kubectl get ingress -n clouding-lab
	```
3. Apply the observability manifest for the same environment.
	```bash
	kubectl apply -f deploy/<local|aws|azure|gcp>/k8s/observability.yaml
	```
4. Reproduce the incident with the fault injection script or by changing the deployment image or resource limits.
	```bash
	sh incident-response/inject-faults.sh k8s latency orders clouding-lab
	sh incident-response/inject-faults.sh k8s errors catalog clouding-lab
	sh incident-response/inject-faults.sh k8s crash orders clouding-lab
	```
	```powershell
	.\incident-response\inject-faults.ps1 -Mode k8s -Scenario latency -Service orders -Namespace clouding-lab
	.\incident-response\inject-faults.ps1 -Mode k8s -Scenario errors -Service catalog -Namespace clouding-lab
	.\incident-response\inject-faults.ps1 -Mode k8s -Scenario crash -Service orders -Namespace clouding-lab
	```
5. Collect pod logs, events, and rollout history.
	```bash
	kubectl logs -n clouding-lab deploy/orders
	kubectl get events -n clouding-lab --sort-by=.metadata.creationTimestamp
	kubectl rollout history deployment/orders -n clouding-lab
	```
6. Roll back the workload if the incident was introduced by a deployment change.
	```bash
	kubectl rollout undo deployment/orders -n clouding-lab
	```
7. Or use the recovery script to restore resources, replicas, and rollout for app services.
	```bash
	sh incident-response/recover-faults.sh k8s all all clouding-lab
	```
	```powershell
	.\incident-response\recover-faults.ps1 -Mode k8s -Scenario all -Service all -Namespace clouding-lab
	```

## Exercises

### Exercise 1: latency spike

Inject latency into `orders` and verify that the frontend still responds.

### Exercise 2: failing dependency

Break the `catalog` service and observe how `orders` behaves when a downstream service is unavailable.

### Exercise 3: crash loop

Force a crash in one service and use logs, events, and rollout history to diagnose it.

### Exercise 4: recovery drill

Restore the affected service, confirm that health checks are green, and write a short post-incident summary.

### Exercise 5: probe failure

Break the `/health` endpoint of one service, watch Kubernetes mark it unhealthy, and recover it.