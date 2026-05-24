#!/usr/bin/env sh
set -eu

MODE="${1:-docker}"
NAMESPACE="${2:-clouding-lab}"

usage() {
	echo "Usage: sh incident-response/collect-events.sh <docker|k8s> [namespace]"
}

collect_docker_events() {
	echo "----- Container status snapshot -----"
	docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.RunningFor}}"
	echo
	echo "----- Docker events (last 15 minutes) -----"
	docker events --since 15m --until 0s --filter type=container --format "{{.Time}} {{.Actor.Attributes.name}} {{.Action}}"
}

collect_k8s_events() {
	kubectl -n "$NAMESPACE" get events --sort-by=.metadata.creationTimestamp
}

case "$MODE" in
	docker)
		collect_docker_events
		;;
	k8s)
		collect_k8s_events
		;;
	*)
		echo "Unsupported mode: $MODE"
		usage
		exit 1
		;;
esac