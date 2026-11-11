# PP05.2 — Busca por Número de Peito

## Escopo
- Busca no evento por número de peito, preservando zeros iniciais e paginação.
- Usa exclusivamente filtragem no servidor Atlas via `GET events/:id/photos?bib_number=...`.
- Nunca filtra apenas a página local: isso geraria resultados incompletos.
- Busca desligada por padrão: `PARTILPROVA_ATLAS_PHOTO_BIB_SEARCH=false`.
- Somente definir `true` depois de verificar que o Atlas implementa e qualifica `bib_number` no endpoint público, com escopo por evento, somente fotos publicadas e paginação consistente. Este ZIP NÃO implementa o endpoint no Atlas.
- Mantém preview protegido, lightbox e URLs existentes.

## Instalação
Extrair na raiz de C:\partilprova, substituindo os arquivos indicados.

## Qualificação
`docker compose exec web bundle exec rails zeitwerk:check`
`docker compose exec web bundle exec rspec spec/qualification/pp05_2_bib_search_qualification_spec.rb spec/services/partilprova/public_portal/pp05_2_photo_catalog_filter_spec.rb spec/services/partilprova/public_portal/photo_search_contract_spec.rb spec/qualification/pp05_1_photo_search_contract_qualification_spec.rb spec/services/partilprova/public_portal/photo_catalog_spec.rb spec/requests/public_portal/pp04_4_photo_gallery_spec.rb`

Sem migrations. Não ativar a flag sem qualificação no Atlas.
