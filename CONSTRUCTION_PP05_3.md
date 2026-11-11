# PP05.3 — Filtros da Galeria (incremental)

Escopo: galeria **sempre vinculada ao evento da rota**; seleção opcional por álbum e sessão, com paginação no servidor e preservação de filtros. O PartilProva não lista fotos privadas, não filtra páginas localmente e mantém as proteções de preview e lightbox existentes.

## Contrato requerido do Atlas (não implementado neste pacote)

`GET /api/public/v1/events/:event_identifier/photos?page=1&per_page=24&album_id=a1&session_id=s1`

- O Atlas deve aplicar filtros por evento **AND** álbum **AND** sessão, antes de paginação, e retornar apenas fotografias publicadas.
- IDs públicos de álbum/sessão são strings alfanuméricas com `_`/`-`, máximo 80 caracteres.
- Opções de filtro são opcionais, obtidas de `data.filters.albums` e `data.filters.sessions`, cada uma uma lista de `{ "id": "a1", "name": "Largada" }`.
- A resposta mantém `data.event`, `data.photos`, `data.published`, `meta.total` e `meta.has_next` já existentes.
- Se não houver metadados públicos, não há seletores na interface; nunca inferir opções a partir de identificações privadas.
- Não ativar a feature flag sem contrato e testes do Atlas aprovados. Um filtro enviado com a flag desligada retorna HTTP 400 (fail-closed).

## Ativação

Por padrão `PARTILPROVA_ATLAS_PHOTO_GALLERY_FILTERS=false`. Após implementar e qualificar o contrato no Atlas, definir `PARTILPROVA_ATLAS_PHOTO_GALLERY_FILTERS=true` no ambiente do PartilProva e reiniciar `web`. A flag da busca por número de peito é independente.

## Instalação

Extrair o ZIP na raiz do PartilProva, preservando caminhos. Não há migrations, dependências ou assets novos.

## Testes

```powershell
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec web bundle exec rspec `
  spec/services/partilprova/public_portal/photo_gallery_filter_contract_spec.rb `
  spec/services/partilprova/public_portal/pp05_3_photo_catalog_filters_spec.rb `
  spec/qualification/pp05_3_gallery_filters_qualification_spec.rb `
  spec/qualification/pp05_2_bib_search_qualification_spec.rb `
  spec/services/partilprova/public_portal/pp05_2_photo_catalog_filter_spec.rb `
  spec/services/partilprova/public_portal/photo_catalog_spec.rb `
  spec/requests/public_portal/pp04_4_photo_gallery_spec.rb
```
