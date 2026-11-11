# Correction PP05.1.1 — Search Contract and Catalog Fixture

- Fix default page parsing: `Integer(value, 10)` requires a string in Ruby.
- Update the existing PhotoCatalog spec fixture to match the Atlas API response envelope (`data` and `meta`). No production PhotoCatalog change.

Apply to the root of PartilProva. No migrations or asset builds.

```powershell
docker compose exec web bundle exec rspec `
  spec/services/partilprova/public_portal/photo_search_contract_spec.rb `
  spec/qualification/pp05_1_photo_search_contract_qualification_spec.rb `
  spec/services/partilprova/public_portal/photo_catalog_spec.rb `
  spec/qualification/pp04_5_photo_gallery_qualification_spec.rb

docker compose exec web bundle exec rails zeitwerk:check
```

Note: this corrects the fixture mismatch based on the source archive; tests must be run in the user's Docker environment.
