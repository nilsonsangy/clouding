param(
  [ValidateSet('docker', 'k8s')]
  [string]$Mode = 'docker',
  [string]$Namespace = 'clouding-lab'
)

$services = @('users', 'orders', 'catalog')

if ($Mode -eq 'docker') {
  foreach ($service in $services) {
    $container = "local-$service-1"
    Write-Host "----- $container -----"
    docker logs --tail 120 $container 2>&1
    Write-Host ""
  }
  exit 0
}

foreach ($service in $services) {
  Write-Host "----- deployment/$service (ns: $Namespace) -----"
  kubectl -n $Namespace logs deployment/$service --tail=120 --all-containers=true 2>&1
  Write-Host ""
}
