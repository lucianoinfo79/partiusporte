# PP05.4 — Interface de Resultados da Galeria

## Escopo
- Cabeçalho de resultados com contagem informada pela API pública e distinção entre total e itens da página.
- Estados específicos para galeria vazia, não publicada e temporariamente indisponível.
- Ação para limpar filtros e tentar novamente, preservando filtros na tentativa.
- Indicação de envio/carregamento nos formulários GET, com progressive enhancement e acessibilidade.
- Mantidos lightbox, paginação, proteção de previews e feature flags da PP05.2/PP05.3.

## Instalação
Extraia o ZIP incremental na raiz do PartilProva. Não há migrations.

## Qualificação (PowerShell)
```powershell
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec web bundle exec rspec `
  spec/qualification/pp05_4_gallery_results_qualification_spec.rb `
  spec/qualification/pp05_3_gallery_filters_qualification_spec.rb `
  spec/qualification/pp05_2_bib_search_qualification_spec.rb `
  spec/requests/public_portal/pp04_4_photo_gallery_spec.rb
```

A implementação não ativa filtros que ainda dependem de contratos públicos do Atlas.
