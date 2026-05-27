#!/usr/bin/env sh
set -eu

MODE="${1:-docker}"
SCENARIO="${2:-all}"
SERVICE="${3:-all}"
NAMESPACE="${4:-clouding-lab}"
STATE_FILE="$(dirname "$0")/.incident-state"

usage() {
  echo "Usage: sh local/incident-response/recover-faults.sh <docker|k8s> <latency|errors|crash|all> [service|all] [namespace]"
  echo "Examples:"
  echo "  sh local/incident-response/recover-faults.sh docker all"
  echo "  sh local/incident-response/recover-faults.sh docker latency orders"
  echo "  sh local/incident-response/recover-faults.sh k8s errors catalog clouding-lab"
}

state_remove() {
  mode="$1"
  service_name="$2"
  namespace_name="$3"
  if [ -f "$STATE_FILE" ]; then
    awk -F'|' -v mode="$mode" -v service="$service_name" -v namespace="$namespace_name" '
      NF < 4 { print; next }
      $1 == mode && $3 == service && $4 == namespace { next }
      { print }
    ' "$STATE_FILE" > "$STATE_FILE.tmp"
    mv "$STATE_FILE.tmp" "$STATE_FILE"
  fi
}

service_list() {
  if [ "$SERVICE" = "all" ]; then
    echo "users orders catalog"
  else
    echo "$SERVICE"
  fi
}

recover_docker() {
  for svc in $(service_list); do
    container="local-${svc}-1"

    case "$SCENARIO" in
      latency)
        echo "Removing CPU throttle from ${container}"
        docker update --cpus 0 "$container" >/dev/null
        state_remove "$MODE" "$svc" ""
        ;;
      errors|crash)
        echo "Starting ${container}"
        docker start "$container" >/dev/null || true
        state_remove "$MODE" "$svc" ""
        ;;
      all)
        echo "Restoring ${container}"
        docker update --cpus 0 "$container" >/dev/null
        docker start "$container" >/dev/null || true
        state_remove "$MODE" "$svc" ""
        ;;
      *)
        echo "Unsupported scenario: $SCENARIO"
        usage
        exit 1
        ;;
    esac
  done

  docker ps --filter name=local- --format "table {{.Names}}\t{{.Status}}"
}

recover_k8s() {
  for svc in $(service_list); do
    case "$SCENARIO" in
      latency)
        echo "Restoring baseline resources for deployment/${svc}"
        kubectl -n "$NAMESPACE" patch deployment "$svc" --type merge -p "{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"${svc}\",\"resources\":{\"requests\":{\"cpu\":\"50m\",\"memory\":\"64Mi\"},\"limits\":{\"cpu\":\"200m\",\"memory\":\"128Mi\"}}}]}}}}"
        state_remove "$MODE" "$svc" "$NAMESPACE"
        ;;
      errors)
        echo "Scaling deployment/${svc} to 1 replica"
        kubectl -n "$NAMESPACE" scale deployment "$svc" --replicas=1
        state_remove "$MODE" "$svc" "$NAMESPACE"
        ;;
      crash)
        echo "Restarting deployment/${svc}"
        kubectl -n "$NAMESPACE" rollout restart deployment "$svc"
        state_remove "$MODE" "$svc" "$NAMESPACE"
        ;;
      all)
        echo "Restoring deployment/${svc}"
        kubectl -n "$NAMESPACE" patch deployment "$svc" --type merge -p "{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"${svc}\",\"resources\":{\"requests\":{\"cpu\":\"50m\",\"memory\":\"64Mi\"},\"limits\":{\"cpu\":\"200m\",\"memory\":\"128Mi\"}}}]}}}}"
        kubectl -n "$NAMESPACE" scale deployment "$svc" --replicas=1
        kubectl -n "$NAMESPACE" rollout restart deployment "$svc"
        ;;
      *)
        echo "Unsupported scenario: $SCENARIO"
        usage
        exit 1
        state_remove "$MODE" "$svc" "$NAMESPACE"
        ;;
    esac

    kubectl -n "$NAMESPACE" rollout status deployment/"$svc"
  done
}

case "$MODE" in
  docker)
    recover_docker
    ;;
  k8s)
    recover_k8s
    ;;
  *)
    echo "Unsupported mode: $MODE"
    usage
    exit 1
    ;;
esac
