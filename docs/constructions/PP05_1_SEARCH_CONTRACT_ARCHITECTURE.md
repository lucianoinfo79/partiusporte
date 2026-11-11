# PP05.1 — Search Contract & Architecture

## Baseline verified in supplied PartilProva source

- `PhotoCatalog#call(event_identifier:, page:)` calls `GET events/:event_identifier/photos` with `page` and `per_page=24`.
- Existing gallery enforces publication state, URL checks, and pagination.
- No confirmed Atlas API server-side `bib_number` filter contract was provided.

## Public search query (PartilProva)

- Scope: exactly one published event (`event_identifier`).
- Optional `bib_number`: digits only, 1–12 characters, trim surrounding whitespace, preserve leading zeros.
- `page`: 1–1000; `per_page`: fixed at 24.
- Invalid input: reject at boundary; never forward unchecked input.
- A bib is not proof of identity or authorization. No participant record or personal data in search results.

## Atlas contract dependency (NOT implemented or assumed)

Before enabling search, Atlas must confirm a documented, server-side event-scoped filter, e.g. `GET /api/public/v1/events/:slug/photos?bib_number=9001&page=1&per_page=24` (proposed, NOT verified).

Required response semantics: only published photos; confirmed public bib associations; stable pagination metadata (`total`, `has_next`); no original/master URLs, private identification records, internal storage keys or unapproved redirects. Filtering must happen in Atlas before pagination, not by PartilProva after receiving an unfiltered page.

Atlas must define behavior for no matches, unpublished event, missing event, invalid bib, and service failure. Confirm whether an image may match multiple bibs and how deduplication works. The current gallery must continue working without this feature.

## Boundaries

- PartilProva: input normalization, UI, public API client, presentation; never reads Atlas database directly.
- Atlas: publication and identification authority, event scope, filter, pagination and access control.
- Previews: retain existing protected delivery and same-origin development proxy rules.
- No shared cache for personalized or photo search queries; no bib numbers in instrumentation/log payloads.
- Fail closed: `PhotoSearchCapability.current.available? == false` until Atlas contract is implemented and verified.

## Next increments

- PP05.2: qualify Atlas public API filter and integrate with `PhotoCatalog` without altering default gallery.
- PP05.3–5: UI, states, pagination, lightbox integration.
- PP05.6: full regression and security qualification.

## Qualification

```bash
bundle exec rspec spec/services/partilprova/public_portal/photo_search_contract_spec.rb spec/qualification/pp05_1_photo_search_contract_qualification_spec.rb spec/services/partilprova/public_portal/photo_catalog_spec.rb spec/qualification/pp04_5_photo_gallery_qualification_spec.rb
bundle exec rails zeitwerk:check
```

No migration or asset compilation required. Incremental ZIP: extract into project root, preserving relative paths.
