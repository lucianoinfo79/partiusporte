# Construction PP03.9 — End-to-End Qualification & Regression Gate

## Scope
Incremental **PartilProva-only** qualification gate. No migrations, no production behavior changes. Tests use controlled doubles; the smoke probe uses the real Atlas public API.

## Apply
Extract the ZIP into `C:\partilprova`, preserving relative paths.

## PowerShell commands
```powershell
docker compose exec web bundle exec rails zeitwerk:check

docker compose exec web bundle exec rspec `
  spec/qualification/pp03_9_operational_integration_gate_spec.rb

docker compose exec web bundle exec rspec `
  spec/requests/public_portal `
  spec/services/partilprova `
  spec/qualification

docker compose exec web bundle exec rails runner script/pp03_9_atlas_smoke.rb
```

## Qualification criteria
1. Zeitwerk OK; specific PP03.9 and complete regression pass.
2. Real Atlas smoke returns `available` (HTTP 200 and supported JSON).
3. Confirm at least one published edition is visible and hidden/draft editions absent in real Atlas API.
4. Confirm registration handoff to the configured public HTTPS Atlas domain or authorized external provider.
5. Confirm published results and protected photo previews, when Atlas endpoints/fixtures exist.
6. Record evidence and any unavailable features; do not mark E2E complete based only on mocks.

## Known blockers
- Earlier environment returned HTTP 403 `Blocked hosts: host.docker.internal:3000` in Atlas. Add the hostname to the **active** Atlas Rails environment and rebuild/restart as needed; verify via `Rails.application.config.hosts.inspect`.
- Atlas public photos endpoint was not present in the previously inspected Atlas snapshot. This gate does not create that endpoint.
- Atlas results API does not yet support `q` and `category` filters; consumer intentionally rejects those requests.

## Notes
The smoke probe does not dump private payloads. It is read-only and does not create registrations, modify events or change cache generations.
