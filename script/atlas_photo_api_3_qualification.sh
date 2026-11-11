#!/usr/bin/env bash
set -euo pipefail
bundle exec rails zeitwerk:check
bundle exec rspec spec/qualification/atlas_photo_api_3_integration_contract_spec.rb \
  spec/qualification/pp05_6_gallery_regression_gate_spec.rb \
  spec/qualification/pp05_5_protected_viewer_qualification_spec.rb
