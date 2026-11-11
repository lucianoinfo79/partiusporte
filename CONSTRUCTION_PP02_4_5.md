# PP02.4.5 — Runner Icon Header

Atualização incremental aprovada para colocar o ícone verde do corredor
imediatamente antes da palavra `partilprova`.

## Arquivos
- app/views/layouts/public_portal.html.erb
- app/assets/stylesheets/pp02_4_5.css
- app/assets/images/partilprova/runner-mark.svg
- spec/qualification/pp02_4_5_runner_icon_header_qualification_spec.rb

## Comandos
Não há migration, bundle ou db:prepare.

```powershell
docker compose exec web bundle exec rails zeitwerk:check
```

```powershell
docker compose exec web bundle exec rspec `
  spec/qualification/pp02_4_5_runner_icon_header_qualification_spec.rb
```

```powershell
docker compose restart web
```

Depois valide `http://localhost:3001` com `Ctrl+F5`.
