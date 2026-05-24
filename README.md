# Clouding Lab

Clouding Lab is an educational application for teaching cloud incident response, Docker operations, Kubernetes troubleshooting, and observability.

## What this lab teaches

- How to detect and triage incidents in containerized systems
- How to inspect logs, metrics, and traces
- How to understand service-to-service dependencies
- How to practice rollback and recovery on Docker and Kubernetes

## Project layout

- `frontend/` contains the student-facing dashboard
- `services/` contains the microservices used in the exercises
- `observability/` contains Prometheus, Grafana, Jaeger, Loki, and Fluent Bit configuration
- `incident-response/` contains operational scripts for fault injection and evidence collection
- `deploy/` contains environment-specific deployment files and tutorials

## Local run

Use `deploy/local/docker-compose.yml` for the application stack and `observability/docker-compose.yml` for the monitoring stack.

## Kubernetes run

Use the manifests inside each environment folder under `deploy/`.

## Notes

- The old backend code was removed.
- The old GitHub Actions workflow was removed.
- Observability components are treated as infrastructure, not npm packages.