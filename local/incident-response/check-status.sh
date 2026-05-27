#!/usr/bin/env sh
set -eu

MODE="${1:-docker}"
NAMESPACE="${2:-clouding-lab}"
STATE_FILE="$(dirname "$0")/.incident-state"

usage() {
  echo "Usage: sh local/incident-response/check-status.sh <docker|k8s> [namespace]"
}

summarize_state() {
  mode="$1"
  namespace_filter="$2"
  if [ ! -f "$STATE_FILE" ]; then
    echo "All clear. No active tests."
    return
  fi

  active_lines="$(awk -F'|' -v mode="$mode" -v namespace="$namespace_filter" '
    NF >= 4 && $1 == mode && (namespace == "" || $4 == namespace) { print }
  ' namespace="$namespace_filter" "$STATE_FILE")"

  if [ -z "$active_lines" ]; then
    echo "All clear. No active tests."
    return
  fi

  echo "Active test detected:"
  printf '%s\n' "$active_lines" | while IFS='|' read -r line_mode line_scenario line_service line_namespace; do
    if [ "$line_mode" = "docker" ]; then
      echo "- ${line_scenario} in ${line_service}"
    else
      echo "- ${line_scenario} in ${line_service} (${line_namespace})"
    fi
  done
}

case "$MODE" in
  docker)
    summarize_state "docker" ""
    ;;
  k8s)
    summarize_state "k8s" "$NAMESPACE"
    ;;
  *)
    echo "Unsupported mode: $MODE"
    usage
    exit 1
    ;;
esac
