# PP02.9 — Fotos & Participant Handoff

ZIP incremental baseado em `partilprova(8).zip`.

- `/fotos`: entrada pública de fotos.
- `/eventos/:id/fotos`: grade responsiva de previews públicos protegidos, com paginação.
- Handoff ao Portal do Atleta somente por URLs HTTPS com host na allowlist.
- Nenhum master/original, compra, reconhecimento facial ou reivindicação de foto exposto pelo PartilProva.
- Estados não publicado, vazio, 404 e indisponível.
- O Atlas é responsável por autorização de publicação, previews protegidos, marca d'água, URLs temporárias, rate limits e LGPD.

## Contrato de API proposto (a confirmar/implementar no Atlas)
GET /api/public/v1/events/:id/photos?page=1&per_page=24

Resposta esperada:
`{"event":{"name":"Corrida"},"published":true,"photos":[{"id":1,"preview_url":"https://cdn.example.com/preview.jpg","photographer_name":"Fotógrafo"}],"meta":{"total":1},"participant_url":"https://portal-autorizado.example/participant/photos"}`

O Atlas deve emitir somente fotos publicadas e links para previews protegidos.
A presença de `published` no JSON não substitui o controle de publicação no backend.

## Configuração
No ambiente do container `web`, configurar:
PARTILPROVA_PARTICIPANT_ALLOWED_HOSTS=portal.exemplo.com.br,atlas.exemplo.com.br

Use os hosts reais, sem protocolo e sem caminho. Sem allowlist, o handoff fica bloqueado.

## Comandos (PowerShell)
```powershell
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec web bundle exec rspec `
  spec/services/partilprova/public_portal/photo_catalog_spec.rb `
  spec/requests/public_portal/pp02_9_photos_spec.rb `
  spec/qualification/pp02_9_photos_participant_handoff_qualification_spec.rb
docker compose up -d --force-recreate web
```
Sem migration, bundle update ou db:prepare.
