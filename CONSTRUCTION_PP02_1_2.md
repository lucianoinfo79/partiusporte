PP02.1.2 — Public Home Test & Qualification Gate Fix

1. config/environments/test.rb.patch is NOT a complete replacement file.
   Add:
       config.hosts << "www.example.com"
   inside Rails.application.configure do ... end in config/environments/test.rb.

2. Replace:
   spec/qualification/pp02_1_project_bootstrap_architecture_qualification_spec.rb
   with the file included in this package.

Reason:
- Rails HostAuthorization returned 403 for RSpec's default host www.example.com.
- The qualification spec was outside request-spec inference, so root_path/get helpers
  were unavailable. It is now explicitly type: :request and uses GET "/".

Validation:
docker compose exec web bundle exec rspec \
  spec/services/partilprova/atlas_api/configuration_spec.rb \
  spec/requests/public_portal/home_spec.rb \
  spec/qualification/pp02_1_project_bootstrap_architecture_qualification_spec.rb

Expected: 6 examples, 0 failures.
