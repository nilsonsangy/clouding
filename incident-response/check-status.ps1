param(
  [ValidateSet('docker', 'k8s')]
  [string]$Mode = 'docker',
  [string]$Namespace = 'clouding-lab'
)

$StateFile = Join-Path $PSScriptRoot '.incident-state'

function Write-Section {
  param([string]$Title)
  Write-Host ""
  Write-Host "===== $Title ====="
}

function Show-Summary {
  param(
    [string]$ModeValue,
    [string]$NamespaceValue
  )

  if (-not (Test-Path $StateFile)) {
    Write-Host 'All clear. No active tests.'
    return
  }

  $entries = Get-Content $StateFile | Where-Object {
    $_ -and $_.StartsWith("$ModeValue|") -and ($NamespaceValue -eq '' -or $_.EndsWith("|$NamespaceValue"))
  }

  if (-not $entries) {
    Write-Host 'All clear. No active tests.'
    return
  }

  Write-Host 'Active test detected:'
  foreach ($entry in $entries) {
    $parts = $entry -split '\|', 4
    $scenario = $parts[1]
    $service = $parts[2]
    if ($ModeValue -eq 'k8s') {
      $ns = $parts[3]
      Write-Host ("- {0} in {1} ({2})" -f $scenario, $service, $ns)
    } else {
      Write-Host ("- {0} in {1}" -f $scenario, $service)
    }
  }
}

if ($Mode -eq 'docker') {
  Show-Summary -ModeValue 'docker' -NamespaceValue ''
  exit 0
}

Show-Summary -ModeValue 'k8s' -NamespaceValue $Namespace