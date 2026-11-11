# PP02.1.1 — Docker Development Environment

## Baseline observed
The Rails-generated production Dockerfile declares Ruby 3.4.11.
The generated Gemfile does not include rspec-rails.

## Decisions
- Ruby 3.4.11 is the PartilProva project baseline.
- Keep the Rails-generated `Dockerfile` for production.
- Use `Dockerfile.dev` only for local development.
- Use PostgreSQL 18 and Redis 8-alpine.
- Publish PartilProva locally on host port 3001.
- Atlas remains on host port 3000.
- From the PartilProva container, Atlas is reached through:
  `http://host.docker.internal:3000/api/public/v1`
- No direct Atlas database connection is permitted.

## Apply
1. Copy Dockerfile.dev and compose.yaml to the project root.
2. Merge `.dockerignore.pp02_1_1` into `.dockerignore`.
3. Add `gem "rspec-rails"` to the existing `group :development, :test`.
4. Build the development image.
5. Generate RSpec files.
6. Prepare the database.
7. Apply the PP02.1 incremental ZIP if it has not yet been applied.
8. Run qualification.

## Commands (PowerShell)

    docker compose build
    docker compose run --rm web bundle exec rails generate rspec:install
    docker compose run --rm web bundle exec rails db:prepare
    docker compose up -d
    docker compose exec web bundle exec rails zeitwerk:check

After PP02.1 files are present:

    docker compose exec web bundle exec rspec `
      spec/services/partilprova/atlas_api/configuration_spec.rb `
      spec/requests/public_portal/home_spec.rb `
      spec/qualification/pp02_1_project_bootstrap_architecture_qualification_spec.rb

## Expected
- `zeitwerk:check` succeeds.
- PP02.1 qualification: 6 examples, 0 failures.
- PartilProva: http://localhost:3001
- Atlas development API: http://localhost:3000/api/public/v1

## Important
Do not run `bundle`, `rails`, or `rspec` using the Windows Ruby installation.
Use `docker compose run --rm web ...` before the web service is running and
`docker compose exec web ...` after it is running.
