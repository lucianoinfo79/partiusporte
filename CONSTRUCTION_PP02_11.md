# PP02.11 — Resilience, Cache & Observability

Incremental patch for partilprova(10).zip.

- One immediate retry for transport/timeouts and HTTP 502/503/504; no retry for 4xx or invalid JSON.
- Opt-in bounded public cache, restricted to `GET events` with no custom headers, success HTTP 200 and Hash payload.
- Cache is disabled by default, because production cache backend and data publication policy must be validated.
- Notification instrumentation logs metadata only; no URL, query, response body or authorization headers.
- Existing service-level unavailable states remain in place. No stale-data fallback is claimed.

## Configuration
`PARTILPROVA_PUBLIC_CACHE_ENABLED=true` (optional; default false)
`PARTILPROVA_PUBLIC_CACHE_TTL=60` (seconds, clamped 1..300)

Production: verify shared cache backend and public data classification before enabling.

## Qualification (PowerShell)
```powershell
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec web bundle exec rspec `
  spec/services/partilprova/atlas_api/client_spec.rb `
  spec/services/partilprova/atlas_api/pp02_11_resilience_spec.rb `
  spec/qualification/pp02_11_resilience_cache_observability_qualification_spec.rb
docker compose up -d --force-recreate web
```
No migrations or gems.
