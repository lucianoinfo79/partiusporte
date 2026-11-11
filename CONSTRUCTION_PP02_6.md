# PP02.6 — Página Pública da Prova
Incremental sobre `partilprova(5).zip`.

- `/eventos/:id`, com slug ou ID público, busca `GET /api/public/v1/events/:id` no Atlas.
- Hero, dados da prova, percursos, programação, kit, regulamento, organizador e links públicos opcionais.
- `Ver detalhes` no catálogo PP02.5; não inventa links de inscrição, fotos ou resultados.
- Diferencia 404 de falha da API e renderiza fallback.
- Contrato de detalhe **proposto**, a validar no Atlas; nenhum endpoint Atlas foi implementado aqui.
- URLs externas somente HTTP(S); a integração definitiva de inscrição será PP02.7.

## Comandos (PowerShell)
```powershell
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec web bundle exec rspec `
  spec/services/partilprova/public_portal/event_detail_spec.rb `
  spec/requests/public_portal/pp02_6_event_detail_spec.rb `
  spec/qualification/pp02_6_event_detail_qualification_spec.rb
docker compose restart web
```
Sem migration, bundle update ou db:prepare.
