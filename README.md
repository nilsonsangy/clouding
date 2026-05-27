# Clouding Lab Project Overview

Clouding Lab is an educational application for teaching cloud incident response, Docker operations, Kubernetes troubleshooting, and observability.

## What this lab teaches

- How to detect and triage incidents in containerized systems
- How to inspect logs, metrics, and traces
- How to understand service-to-service dependencies
- How to practice rollback and recovery on Docker and Kubernetes

## Project layout

- [frontend/](frontend/) contains the student-facing dashboard
- [services/](services/) contains the microservices used in the exercises
- [observability/](observability/) contains Prometheus, Grafana, Jaeger, Loki, and Fluent Bit configuration
- [incident-response/](incident-response/) contains operational scripts for fault injection and evidence collection
- [deploy/](deploy/) contains environment-specific runbooks and deployment files

## Environment runbooks

- [Local](deploy/local/README.md)
- [AWS](deploy/aws/README.md)
- [Azure](deploy/azure/README.md)
- [GCP](deploy/gcp/README.md)

## Quick start

For local development, use [deploy/local/docker-compose.yml](deploy/local/docker-compose.yml) for the application stack and [observability/docker-compose.yml](observability/docker-compose.yml) for the monitoring stack.

## Notes

- The old backend code was removed.
- The old GitHub Actions workflow was removed.
- Observability components are treated as infrastructure, not npm packages.