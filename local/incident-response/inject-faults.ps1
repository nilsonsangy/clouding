param(
  [ValidateSet('docker', 'k8s')]
  [string]$Mode = 'docker',

  [ValidateSet('latency', 'errors', 'crash')]
  [string]$Scenario = 'latency',

  [string]$Service,
  [string]$Namespace = 'clouding-lab'
)

$StateFile = Join-Path $PSScriptRoot '.incident-state'

function Save-StateEntry {
  param(
    [string]$ModeValue,
    [string]$ScenarioValue,
    [string]$ServiceValue,
    [string]$NamespaceValue
  )

  $entry = "$ModeValue|$ScenarioValue|$ServiceValue|$NamespaceValue"
  $current = @()
  if (Test-Path $StateFile) {
    foreach ($line in Get-Content $StateFile) {
      if (-not $line) {
        continue
      }

      $parts = $line -split '\|', 4
      if ($parts.Count -lt 4) {
        $current += $line
        continue
      }

      if ($parts[0] -eq $ModeValue -and $parts[2] -eq $ServiceValue -and $parts[3] -eq $NamespaceValue) {
        continue
      }

      $current += $line
    }
  }

  [System.IO.File]::WriteAllLines($StateFile, @($current + $entry))
}

if (-not $Service) {
  if ($Scenario -eq 'errors') {
    $Service = 'catalog'
  } else {
    $Service = 'orders'
  }
}

if ($Mode -eq 'docker') {
  $container = "local-$Service-1"

  switch ($Scenario) {
    'latency' {
      Write-Host "Applying CPU throttle on $container to simulate latency"
      docker update --cpus 0.15 $container | Out-Null
      Save-StateEntry -ModeValue 'docker' -ScenarioValue 'latency' -ServiceValue $Service -NamespaceValue ''
      docker ps --filter "name=$container" --format "table {{.Names}}`t{{.Status}}"
    }
    'errors' {
      Write-Host "Stopping $container to trigger downstream errors"
      docker stop $container | Out-Null
      Save-StateEntry -ModeValue 'docker' -ScenarioValue 'errors' -ServiceValue $Service -NamespaceValue ''
      docker ps -a --filter "name=$container" --format "table {{.Names}}`t{{.Status}}"
    }
    'crash' {
      Write-Host "Killing $container to simulate a crash"
      docker kill $container | Out-Null
      Save-StateEntry -ModeValue 'docker' -ScenarioValue 'crash' -ServiceValue $Service -NamespaceValue ''
      docker ps -a --filter "name=$container" --format "table {{.Names}}`t{{.Status}}"
    }
  }

  exit 0
}

switch ($Scenario) {
  'latency' {
    Write-Host "Patching deployment/$Service with tight CPU limits to simulate latency"
    $patch = @{
      spec = @{
        template = @{
          spec = @{
            containers = @(
              @{
                name = $Service
                resources = @{
                  requests = @{ cpu = '50m' }
                  limits = @{ cpu = '100m' }
                }
              }
            )
          }
        }
      }
    } | ConvertTo-Json -Depth 8 -Compress

    kubectl -n $Namespace patch deployment $Service --type merge -p $patch
    Save-StateEntry -ModeValue 'k8s' -ScenarioValue 'latency' -ServiceValue $Service -NamespaceValue $Namespace
    kubectl -n $Namespace rollout status deployment/$Service
  }
  'errors' {
    Write-Host "Scaling deployment/$Service to zero replicas to create dependency errors"
    kubectl -n $Namespace scale deployment $Service --replicas=0
    Save-StateEntry -ModeValue 'k8s' -ScenarioValue 'errors' -ServiceValue $Service -NamespaceValue $Namespace
    kubectl -n $Namespace get deployment $Service
  }
  'crash' {
    Write-Host "Deleting one pod from deployment/$Service to simulate a crash"
    $pod = kubectl -n $Namespace get pod -l app=$Service -o jsonpath='{.items[0].metadata.name}'
    if (-not $pod) {
      throw "No pod found for app=$Service in namespace $Namespace"
    }

    kubectl -n $Namespace delete pod $pod
    Save-StateEntry -ModeValue 'k8s' -ScenarioValue 'crash' -ServiceValue $Service -NamespaceValue $Namespace
    kubectl -n $Namespace get pods -l app=$Service
  }
}
