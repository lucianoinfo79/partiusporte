# PP02.8 — Resultados Públicos

Construction incremental sobre `partilprova(7).zip`.

- `/resultados`: entrada pública para localizar a prova pelo catálogo.
- `/eventos/:id/resultados`: classificação e tempos da prova, com busca por atleta/número de peito, filtro por categoria e paginação.
- Dados exclusivamente da API Atlas, sem resultados simulados.
- Estados de não publicado, não encontrado e indisponível.
- Integração da página de prova e navegação global.
- Não modifica o Atlas nem publica dados privados.

## Contrato a confirmar no Atlas
`GET /api/public/v1/events/:id/results?q=&category=&page=1&per_page=30`

Resposta esperada:
```json
{"event":{"name":"Corrida"},"published":true,"categories":["Geral"],"results":[{"position":1,"bib_number":"123","athlete_name":"Atleta","category_name":"Geral","net_time":"00:25:00","gross_time":"00:25:05","status":"finished"}],"meta":{"total":1}}
```
A API deve aplicar **no servidor Atlas** a autorização de publicação, a minimização dos dados pessoais e filtros/paginação. O PartilProva não é a fronteira de segurança para dados não publicados.

## Qualificação
```powershell
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec web bundle exec rspec `
  spec/services/partilprova/public_portal/race_results_spec.rb `
  spec/requests/public_portal/pp02_8_results_spec.rb `
  spec/qualification/pp02_8_public_results_qualification_spec.rb
docker compose restart web
```
Não há migrations ou mudanças em gems.
