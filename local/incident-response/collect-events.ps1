param(
  [ValidateSet('docker', 'k8s')]
  [string]$Mode = 'docker',
  [string]$Namespace = 'clouding-lab'
)

if ($Mode -eq 'docker') {
  Write-Host '----- Container status snapshot -----'
  docker ps -a --format "table {{.Names}}`t{{.Status}}`t{{.RunningFor}}"
  Write-Host ""
  Write-Host '----- Docker events (last 15 minutes) -----'
  docker events --since 15m --until 0s --filter type=container --format "{{.Time}} {{.Actor.Attributes.name}} {{.Action}}"
  exit 0
}

kubectl -n $Namespace get events --sort-by=.metadata.creationTimestamp
