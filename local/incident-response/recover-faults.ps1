param(
  [ValidateSet('docker', 'k8s')]
  [string]$Mode = 'docker',

  [ValidateSet('latency', 'errors', 'crash', 'all')]
  [string]$Scenario = 'all',

  [string]$Service = 'all',
  [string]$Namespace = 'clouding-lab'
)

$StateFile = Join-Path $PSScriptRoot '.incident-state'

function Get-Services {
  param([string]$SelectedService)

  if ($SelectedService -eq 'all') {
    return @('users', 'orders', 'catalog')
  }

  return @($SelectedService)
}

function Remove-StateEntry {
  param(
    [string]$ModeValue,
    [string]$ServiceValue,
    [string]$NamespaceValue
  )

  if (-not (Test-Path $StateFile)) {
    return
  }

  $remaining = @()
  foreach ($line in Get-Content $StateFile) {
    if (-not $line) {
      continue
    }

    $parts = $line -split '\|', 4
    if ($parts.Count -lt 4) {
      $remaining += $line
      continue
    }

    if ($parts[0] -eq $ModeValue -and $parts[2] -eq $ServiceValue -and $parts[3] -eq $NamespaceValue) {
      continue
    }

    $remaining += $line
  }

  [System.IO.File]::WriteAllLines($StateFile, @($remaining))
}

$services = Get-Services -SelectedService $Service

if ($Mode -eq 'docker') {
  foreach ($svc in $services) {
    $container = "local-$svc-1"

    switch ($Scenario) {
      'latency' {
        Write-Host "Removing CPU throttle from $container"
        docker update --cpus 0 $container | Out-Null
        Remove-StateEntry -ModeValue 'docker' -ServiceValue $svc -NamespaceValue ''
      }
      'errors' {
        Write-Host "Starting $container"
        docker start $container | Out-Null
        Remove-StateEntry -ModeValue 'docker' -ServiceValue $svc -NamespaceValue ''
      }
      'crash' {
        Write-Host "Starting $container"
        docker start $container | Out-Null
        Remove-StateEntry -ModeValue 'docker' -ServiceValue $svc -NamespaceValue ''
      }
      'all' {
        Write-Host "Restoring $container"
        docker update --cpus 0 $container | Out-Null
        docker start $container | Out-Null
        Remove-StateEntry -ModeValue 'docker' -ServiceValue $svc -NamespaceValue ''
      }
    }
  }

  docker ps --filter name=local- --format "table {{.Names}}`t{{.Status}}"
  exit 0
}

foreach ($svc in $services) {
  switch ($Scenario) {
    'latency' {
      Write-Host "Restoring baseline resources for deployment/$svc"
      $patch = @{
        spec = @{
          template = @{
            spec = @{
              containers = @(
                @{
                  name = $svc
                  resources = @{
                    requests = @{ cpu = '50m'; memory = '64Mi' }
                    limits = @{ cpu = '200m'; memory = '128Mi' }
                  }
                }
              )
            }
          }
        }
      } | ConvertTo-Json -Depth 8 -Compress

      kubectl -n $Namespace patch deployment $svc --type merge -p $patch
      Remove-StateEntry -ModeValue 'k8s' -ServiceValue $svc -NamespaceValue $Namespace
    }
    'errors' {
      Write-Host "Scaling deployment/$svc to 1 replica"
      kubectl -n $Namespace scale deployment $svc --replicas=1
      Remove-StateEntry -ModeValue 'k8s' -ServiceValue $svc -NamespaceValue $Namespace
    }
    'crash' {
      Write-Host "Restarting deployment/$svc"
      kubectl -n $Namespace rollout restart deployment/$svc
      Remove-StateEntry -ModeValue 'k8s' -ServiceValue $svc -NamespaceValue $Namespace
    }
    'all' {
      Write-Host "Restoring deployment/$svc"
      $patch = @{
        spec = @{
          template = @{
            spec = @{
              containers = @(
                @{
                  name = $svc
                  resources = @{
                    requests = @{ cpu = '50m'; memory = '64Mi' }
                    limits = @{ cpu = '200m'; memory = '128Mi' }
                  }
                }
              )
            }
          }
        }
      } | ConvertTo-Json -Depth 8 -Compress

      kubectl -n $Namespace patch deployment $svc --type merge -p $patch
      kubectl -n $Namespace scale deployment $svc --replicas=1
      kubectl -n $Namespace rollout restart deployment/$svc
      Remove-StateEntry -ModeValue 'k8s' -ServiceValue $svc -NamespaceValue $Namespace
    }
  }

  kubectl -n $Namespace rollout status deployment/$svc
}
