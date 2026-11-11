# PP02 — PartilProva Public Portal Architecture

## Product boundary

PartilProva is a standalone public-facing application deployed independently
from Atlas.

- Public product: `https://partilprova.com.br`
- Atlas operational application: `https://atlasplataform.mgl.com.br`
- Integration contract: `/api/public/v1`
- Institutional site: `https://mgl.com.br`

## Non-negotiable boundaries

1. PartilProva MUST NOT connect to the Atlas PostgreSQL database.
2. PartilProva MUST NOT read Atlas Redis/Solid Cache directly.
3. PartilProva MUST NOT depend on Atlas internal models, IDs or services.
4. All Atlas data consumed by PartilProva must cross the versioned public API.
5. Atlas remains the source of truth for event publication, registration
   routing, public results and protected-photo availability.
6. Participant-private photo delivery remains governed by Atlas/AP13/PH01.
7. PartilProva may have its own persistence/cache for portal concerns, but
   those stores are never authoritative for Atlas domain state.

## Runtime topology

Browser
  -> partilprova.com.br
      -> PartilProva Rails application
          -> HTTPS/JSON
              -> atlasplataform.mgl.com.br/api/public/v1
                  -> Atlas domain/database/cache

## Environment contract

`ATLAS_PUBLIC_API_BASE_URL` is mandatory in deployed environments and must
point to the Atlas Public API v1 boundary.

Timeouts:
- `ATLAS_PUBLIC_API_OPEN_TIMEOUT`
- `ATLAS_PUBLIC_API_READ_TIMEOUT`

PP02.3 will add the production HTTP client, envelope/error handling,
conditional requests, rate-limit handling and resilience.

## Ownership

Atlas owns:
- publication eligibility
- event public projection
- registration provider/target
- confirmed public results
- protected photo capability

PartilProva owns:
- participant-facing presentation
- discovery/navigation
- portal SEO
- portal-side cache
- portal observability
- graceful degradation
