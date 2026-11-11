$ErrorActionPreference = "Stop"
$failed = $false
function Invoke-Gate([string]$Name, [string[]]$ArgsList) {
  Write-Host "`n=== $Name ===" -ForegroundColor Cyan
  & docker compose exec -T web bundle exec @ArgsList
  if ($LASTEXITCODE -ne 0) { Write-Host "FAILED: $Name" -ForegroundColor Red; $script:failed = $true }
}
Invoke-Gate "Zeitwerk" @("rails", "zeitwerk:check")
Invoke-Gate "PP02.12 public journey + qualification" @("rspec", "spec/requests/public_portal/pp02_12_public_journey_spec.rb", "spec/qualification/pp02_12_end_to_end_regression_gate_spec.rb", "--format", "documentation")
Invoke-Gate "All public request specs" @("rspec", "spec/requests/public_portal", "--format", "progress")
Invoke-Gate "All service specs" @("rspec", "spec/services/partilprova", "--format", "progress")
Invoke-Gate "All qualification specs PP02.1-PP02.12" @("rspec", "spec/qualification", "--format", "progress")
if ($failed) { Write-Host "`nPP02.12 GATE: FAILED" -ForegroundColor Red; exit 1 }
Write-Host "`nPP02.12 GATE: PASSED (automated checks)" -ForegroundColor Green
