# PP02.4.6 — Official Logo Image
Substitui runner + wordmark reconstruídos pela imagem de logo enviada e aprovada.

## Comandos
```powershell
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec web bundle exec rspec `
  spec/qualification/pp02_4_6_official_logo_image_qualification_spec.rb
docker compose restart web
```
Valide em `http://localhost:3001` com `Ctrl+F5`.
Não há migration, bundle ou db:prepare.
