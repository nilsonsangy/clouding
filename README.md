# Clouding Lab Project Overview

Clouding Lab is an educational application for teaching cloud incident response, Docker operations, Kubernetes troubleshooting, and observability.

## What this lab teaches

- How to detect and triage incidents in containerized systems
- How to inspect logs, metrics, and traces
- How to understand service-to-service dependencies
- How to practice rollback and recovery on Docker and Kubernetes

## Project layout

- [app/frontend/](app/frontend/) contains the student-facing dashboard
- [app/](app/) contains the microservices used in the exercises
- [local/observability/](local/observability/) contains Prometheus, Grafana, Jaeger, Loki, and Fluent Bit configuration
- [local/incident-response/](local/incident-response/) (and others inside aws/azure/gcp) contains operational scripts for fault injection and evidence collection

## Environment runbooks

- [Local](local/README.md)
- [AWS](aws/README.md)
- [Azure](azure/README.md)
- [GCP](gcp/README.md)

## Quick start

For local development, use [local/docker-compose.yml](local/docker-compose.yml) for the application stack and [local/observability/docker-compose.yml](local/observability/docker-compose.yml) for the monitoring stack.

## Notes

- The old backend code was removed.
- The old GitHub Actions workflow was removed.
- Observability components are treated as infrastructure, not npm packages.
