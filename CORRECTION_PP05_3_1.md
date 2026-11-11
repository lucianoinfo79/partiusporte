# Correction PP05.3.1 — RSpec compatibility

Corrige a expectativa do teste PP05.2 após a introdução dos filtros opcionais da PP05.3.

## Alteração

`spec/qualification/pp05_2_bib_search_qualification_spec.rb`: não exige `album_id: nil` e `session_id: nil` quando os filtros não foram informados. O controller omite esses parâmetros corretamente.

## Aplicação

Extrair na raiz de `C:\partilprova`, preservando diretórios e substituindo o arquivo de teste.

## Qualificação (PowerShell)

```powershell
docker compose exec web bundle exec rspec `
  spec/services/partilprova/public_portal/photo_gallery_filter_contract_spec.rb `
  spec/services/partilprova/public_portal/pp05_3_photo_catalog_filters_spec.rb `
  spec/qualification/pp05_3_gallery_filters_qualification_spec.rb `
  spec/qualification/pp05_2_bib_search_qualification_spec.rb `
  spec/services/partilprova/public_portal/pp05_2_photo_catalog_filter_spec.rb `
  spec/services/partilprova/public_portal/photo_catalog_spec.rb `
  spec/requests/public_portal/pp04_4_photo_gallery_spec.rb

docker compose exec web bundle exec rails zeitwerk:check
```

Sem migrations, assets ou mudanças de código de produção.
