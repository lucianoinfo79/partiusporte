param(
  [Parameter(Mandatory=$true)][string]$AtlasApiBase,
  [Parameter(Mandatory=$true)][string]$PartilprovaBase,
  [Parameter(Mandatory=$true)][string]$EventSlug,
  [string]$ExpectedProvider = "",
  [string]$ExpectedStatus = ""
)
$ErrorActionPreference = "Stop"
$failed = 0
function Check([bool]$ok, [string]$message) {
  if ($ok) { Write-Host "[OK] $message" -ForegroundColor Green }
  else { Write-Host "[FAIL] $message" -ForegroundColor Red; $script:failed++ }
}
function Get-Json([string]$url) {
  return Invoke-RestMethod -Method Get -Uri $url -Headers @{ Accept = "application/json" } -TimeoutSec 25
}
function Get-Page([string]$url) {
  return Invoke-WebRequest -Method Get -Uri $url -TimeoutSec 25 -UseBasicParsing
}
$atlas = $AtlasApiBase.TrimEnd("/")
$portal = $PartilprovaBase.TrimEnd("/")
$slug = [uri]::EscapeDataString($EventSlug)
Write-Host "Read-only qualification: no database writes, registrations or payments."
try {
  $collection = Get-Json "$atlas/events"
  Check ($null -ne $collection.data) "Atlas public event collection responds with data"
} catch {
  Check $false "Atlas public event collection: $($_.Exception.Message)"
}
try {
  $detail = Get-Json "$atlas/events/$slug"
  $event = $detail.data
  if ($null -ne $event.event) { $event = $event.event }
  Check (-not [string]::IsNullOrWhiteSpace([string]$event.name)) "Atlas event detail has a name"
  Check ($null -ne $event.registration) "Atlas event detail exposes registration contract"
  $provider = [string]$event.registration.provider
  Write-Host "Atlas registration provider: $provider"
  $status = [string]$event.registration.status
  Write-Host "Atlas registration status: $status"
  Check ($provider -in @("atlas","external","unavailable")) "Registration provider is a known value ($provider)"
  if ($ExpectedProvider) { Check ($provider -eq $ExpectedProvider) "Provider matches expected $ExpectedProvider" }
  if ($ExpectedStatus) { Check ($status -eq $ExpectedStatus) "Status matches expected $ExpectedStatus" }
  if ($provider -eq "unavailable") {
    Check ([string]::IsNullOrWhiteSpace([string]$event.registration.target)) "Unavailable provider has no target"
  }
  if ($provider -eq "external") {
    $target = [string]$event.registration.target
    Check ($target.StartsWith("https://")) "External registration target uses HTTPS"
  }
  if ($provider -eq "atlas") {
    Check ([string]$event.registration.target -match '^/events/[^/]+/editions/[^/]+/register$') "Atlas registration target is an expected public path"
  }
} catch {
  Check $false "Atlas public event detail: $($_.Exception.Message)"
}
try {
  $homeResponse = Get-Page "$portal/"
  Check ($homeResponse.StatusCode -eq 200) "PartilProva home responds HTTP 200"
} catch {
  Check $false "PartilProva home: $($_.Exception.Message)"
}
try {
  $catalog = Get-Page "$portal/eventos"
  Check ($catalog.StatusCode -eq 200) "PartilProva catalog responds HTTP 200"
} catch {
  Check $false "PartilProva catalog: $($_.Exception.Message)"
}
try {
  $page = Get-Page "$portal/eventos/$slug"
  Check ($page.StatusCode -eq 200) "PartilProva event detail responds HTTP 200"
  if ($null -ne $event -and $event.name) {
    Check ($page.Content -match [regex]::Escape([string]$event.name)) "PartilProva detail displays the Atlas event name"
  }
  if ($provider -eq "unavailable") {
    Check ($page.Content -notmatch 'href="[^"]*/register[^"]*"') "Unavailable event has no Atlas registration CTA"
  }
} catch {
  Check $false "PartilProva event detail: $($_.Exception.Message)"
}
if ($failed -gt 0) { Write-Host "$failed qualification check(s) failed."; exit 1 }
Write-Host "All observable smoke checks passed. Commercial and payment E2E remain separate." -ForegroundColor Green
