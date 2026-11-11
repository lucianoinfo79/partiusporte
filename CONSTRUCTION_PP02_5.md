# PP02.5 — Catálogo de Eventos

Incremental baseado no partilprova(4).zip enviado.

## Escopo
- rota pública `/eventos` e navegação pelo header;
- busca, modalidade, UF, cidade, datas, status e ordenação;
- cards de eventos e paginação de 12 itens;
- cliente Atlas existente, `GET /api/public/v1/events`;
- estados vazio e indisponível, sem dados fictícios;
- responsividade e testes.

## Contrato esperado do Atlas
`GET /api/public/v1/events?q=&modality=&state=&city=&status=&order=&from=&to=&page=1&per_page=12`

Resposta: array de eventos ou `{ "events": [...], "meta": { "total": 123 } }`.
Os parâmetros e a forma de resposta são o contrato proposto pelo PartilProva;
é necessário validá-los/implementá-los no Atlas. Não foi feita alteração no Atlas.

PP02.6 implementará o destino real do botão de detalhes. Não há link falso nesta etapa.

## Comandos
```powershell
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec web bundle exec rspec `
  spec/services/partilprova/public_portal/event_catalog_spec.rb `
  spec/requests/public_portal/pp02_5_event_catalog_spec.rb `
  spec/qualification/pp02_5_event_catalog_qualification_spec.rb
docker compose restart web
```
Não há migration, bundle update ou db:prepare.
