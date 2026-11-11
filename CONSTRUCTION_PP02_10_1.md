# Correction PP02.10.1 — SEO Routes & Rendering

Patch incremental sobre PP02.10. Corrige barras invertidas literais em routes e views, nomeia helpers robots/sitemap, corrige regex e separadores de linha de robots.txt.

## Aplicar
Extrair na raiz do projeto PartilProva, sobrescrevendo somente os arquivos do ZIP.

## Verificar (PowerShell)
```powershell
docker compose exec web bundle exec ruby -c config/routes.rb
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec web bundle exec rspec `
  spec/requests/public_portal/pp02_10_seo_spec.rb `
  spec/qualification/pp02_10_seo_sharing_discoverability_qualification_spec.rb
```

Observação: os testes dependem da PP02.10 já instalada.
