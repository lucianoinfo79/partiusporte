# Correction PP05.5.1 — Protected Viewer Qualification

Correção incremental apenas do spec `spec/qualification/pp05_5_protected_viewer_qualification_spec.rb`.

- O texto "Fotografia 1" não existe isoladamente na renderização: a interface usa `aria-label="Ampliar fotografia 1"` no botão.
- O filtro `album_id` só é aceito com a flag `PARTILPROVA_ATLAS_PHOTO_GALLERY_FILTERS=true`. O teste habilita a flag de forma isolada, mantendo `ENV.fetch` normal para as demais configurações.
- Nenhuma mudança no código de produção, API, proteção das fotos, banco ou assets.

## Instalação

Extrair na raiz do projeto `C:\partilprova`, substituindo o arquivo existente.

## Testes (PowerShell)

```powershell
docker compose exec web bundle exec rspec `
  spec/qualification/pp05_5_protected_viewer_qualification_spec.rb `
  spec/qualification/pp05_4_gallery_results_qualification_spec.rb `
  spec/qualification/pp05_3_gallery_filters_qualification_spec.rb `
  spec/qualification/pp05_2_bib_search_qualification_spec.rb `
  spec/requests/public_portal/pp04_4_photo_gallery_spec.rb

docker compose exec web bundle exec rails zeitwerk:check
```

Esperado: 12 exemplos, 0 falhas (a confirmar no ambiente Docker do usuário).
