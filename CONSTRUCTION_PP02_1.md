# PP02.1 — Project Bootstrap & Architecture

## Goal
Bootstrap the standalone PartilProva application and freeze the architectural
boundary with Atlas.

## Recommended bootstrap
Create the repository outside Atlas:

    cd C:\
    rails _8.0.5_ new partilprova --database=postgresql
    cd C:\partilprova

Then overlay this incremental ZIP.

## Architecture
PartilProva is a standalone Rails application. It does not share Atlas DB,
Redis/cache, models or internal services. Atlas is consumed only through the
versioned public API.

## Configuration
Copy `.env.example` values into the deployment/environment configuration.
Do not commit production secrets.

## No migration
This Construction adds no domain persistence.

## Validation
    bundle exec rails zeitwerk:check
    bundle exec rspec spec/services/partilprova/atlas_api/configuration_spec.rb spec/requests/public_portal/home_spec.rb spec/qualification/pp02_1_project_bootstrap_architecture_qualification_spec.rb
