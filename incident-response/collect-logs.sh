#!/usr/bin/env sh
set -eu

MODE="${1:-docker}"
NAMESPACE="${2:-clouding-lab}"

usage() {
	echo "Usage: sh incident-response/collect-logs.sh <docker|k8s> [namespace]"
}

collect_docker_logs() {
	for service in users orders catalog; do
		container="local-${service}-1"
		echo "----- ${container} -----"
		docker logs --tail 120 "$container" 2>&1 || true
		echo
	done
}

collect_k8s_logs() {
	for service in users orders catalog; do
		echo "----- deployment/${service} (ns: ${NAMESPACE}) -----"
		kubectl -n "$NAMESPACE" logs deployment/"$service" --tail=120 --all-containers=true 2>&1 || true
		echo
	done
}

case "$MODE" in
	docker)
		collect_docker_logs
		;;
	k8s)
		collect_k8s_logs
		;;
	*)
		echo "Unsupported mode: $MODE"
		usage
		exit 1
		;;
esac