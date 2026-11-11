#!/usr/bin/env bash
set -euo pipefail
bundle exec rails zeitwerk:check
bundle exec rspec \
  spec/services/partilprova/public_portal/photo_search_contract_spec.rb \
  spec/services/partilprova/public_portal/photo_gallery_filter_contract_spec.rb \
  spec/services/partilprova/public_portal/pp05_2_photo_catalog_filter_spec.rb \
  spec/services/partilprova/public_portal/pp05_3_photo_catalog_filters_spec.rb \
  spec/services/partilprova/public_portal/photo_catalog_spec.rb \
  spec/qualification/pp05_1_photo_search_contract_qualification_spec.rb \
  spec/qualification/pp05_2_bib_search_qualification_spec.rb \
  spec/qualification/pp05_3_gallery_filters_qualification_spec.rb \
  spec/qualification/pp05_4_gallery_results_qualification_spec.rb \
  spec/qualification/pp05_5_protected_viewer_qualification_spec.rb \
  spec/qualification/pp05_6_gallery_regression_gate_spec.rb \
  spec/qualification/pp04_5_photo_gallery_qualification_spec.rb \
  spec/requests/public_portal/pp04_4_photo_gallery_spec.rb
