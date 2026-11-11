# Correction PP05.2.1 — ENV.fetch RSpec isolation

## Mudança
No spec `spec/qualification/pp05_2_bib_search_qualification_spec.rb`, adiciona `allow(ENV).to receive(:fetch).and_call_original` antes dos dois stubs específicos da feature flag. Assim, leituras de `ATLAS_PUBLIC_API_BASE_URL` e outras configurações não são bloqueadas. Nenhum arquivo de produção foi alterado.

## Aplicação
Extrair o ZIP na raiz de `C:\partilprova`, preservando diretórios e substituindo o arquivo existente.

## Qualificação (PowerShell)
```powershell
cd C:\partilprova
docker compose exec web bundle exec rspec `
  spec/qualification/pp05_2_bib_search_qualification_spec.rb `
  spec/services/partilprova/public_portal/pp05_2_photo_catalog_filter_spec.rb `
  spec/services/partilprova/public_portal/photo_search_contract_spec.rb `
  spec/qualification/pp05_1_photo_search_contract_qualification_spec.rb `
  spec/services/partilprova/public_portal/photo_catalog_spec.rb `
  spec/requests/public_portal/pp04_4_photo_gallery_spec.rb
docker compose exec web bundle exec rails zeitwerk:check
```

Resultado esperado: 16 exemplos, 0 falhas; confirmar na execução local. Sem migrations ou assets.
