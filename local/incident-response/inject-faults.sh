#!/usr/bin/env sh
set -eu

MODE="${1:-docker}"
SCENARIO="${2:-latency}"
SERVICE="${3:-}"
NAMESPACE="${4:-clouding-lab}"
STATE_FILE="$(dirname "$0")/.incident-state"

if [ -z "$SERVICE" ]; then
	case "$SCENARIO" in
		errors)
			SERVICE="catalog"
			;;
		*)
			SERVICE="orders"
			;;
	esac
fi

usage() {
	echo "Usage: sh local/incident-response/inject-faults.sh <docker|k8s> <latency|errors|crash> [service] [namespace]"
	echo "Examples:"
	echo "  sh local/incident-response/inject-faults.sh docker latency orders"
	echo "  sh local/incident-response/inject-faults.sh docker errors catalog"
	echo "  sh local/incident-response/inject-faults.sh k8s crash orders clouding-lab"
}

state_write() {
	entry="$1"
	state_dir="$(dirname "$STATE_FILE")"
	mkdir -p "$state_dir"
	touch "$STATE_FILE"
	awk -F'|' -v mode="$MODE" -v service="$SERVICE" -v namespace="$NAMESPACE" '
		NF < 4 { print; next }
		$1 == mode && $3 == service && $4 == namespace { next }
		{ print }
		END { print entry }
	' entry="$entry" "$STATE_FILE" > "$STATE_FILE.tmp"
	mv "$STATE_FILE.tmp" "$STATE_FILE"
}

inject_docker() {
	container="local-${SERVICE}-1"

	case "$SCENARIO" in
		latency)
			echo "Applying CPU throttle on ${container} to simulate latency"
			docker update --cpus 0.15 "$container" >/dev/null
			state_write "docker|latency|${SERVICE}|"
			docker ps --filter "name=${container}" --format "table {{.Names}}\t{{.Status}}"
			;;
		errors)
			echo "Stopping ${container} to trigger downstream errors"
			docker stop "$container" >/dev/null
			state_write "docker|errors|${SERVICE}|"
			docker ps -a --filter "name=${container}" --format "table {{.Names}}\t{{.Status}}"
			;;
		crash)
			echo "Killing ${container} to simulate a crash"
			docker kill "$container" >/dev/null
			state_write "docker|crash|${SERVICE}|"
			docker ps -a --filter "name=${container}" --format "table {{.Names}}\t{{.Status}}"
			;;
		*)
			echo "Unsupported scenario: $SCENARIO"
			usage
			exit 1
			;;
	esac
}

inject_k8s() {
	case "$SCENARIO" in
		latency)
			echo "Patching deployment/${SERVICE} with tight CPU limits to simulate latency"
			kubectl -n "$NAMESPACE" patch deployment "$SERVICE" --type merge -p "{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"${SERVICE}\",\"resources\":{\"requests\":{\"cpu\":\"50m\"},\"limits\":{\"cpu\":\"100m\"}}}]}}}}"
			state_write "k8s|latency|${SERVICE}|${NAMESPACE}"
			kubectl -n "$NAMESPACE" rollout status deployment/"$SERVICE"
			;;
		errors)
			echo "Scaling deployment/${SERVICE} to zero replicas to create dependency errors"
			kubectl -n "$NAMESPACE" scale deployment "$SERVICE" --replicas=0
			state_write "k8s|errors|${SERVICE}|${NAMESPACE}"
			kubectl -n "$NAMESPACE" get deployment "$SERVICE"
			;;
		crash)
			echo "Deleting one pod from deployment/${SERVICE} to simulate a crash"
			pod="$(kubectl -n "$NAMESPACE" get pod -l app="$SERVICE" -o jsonpath='{.items[0].metadata.name}')"
			if [ -z "$pod" ]; then
				echo "No pod found for app=${SERVICE} in namespace ${NAMESPACE}"
				exit 1
			fi
			kubectl -n "$NAMESPACE" delete pod "$pod"
			state_write "k8s|crash|${SERVICE}|${NAMESPACE}"
			kubectl -n "$NAMESPACE" get pods -l app="$SERVICE"
			;;
		*)
			echo "Unsupported scenario: $SCENARIO"
			usage
			exit 1
			;;
	esac
}

case "$MODE" in
	docker)
		inject_docker
		;;
	k8s)
		inject_k8s
		;;
	*)
		echo "Unsupported mode: $MODE"
		usage
		exit 1
		;;
esac
