# PP02.4.7 — Hero Runner Image Sizing & Framing

Corrige exclusivamente o enquadramento do artwork aprovado do corredor.

## Resultado esperado
- imagem menor na coluna direita;
- corredor inteiro preservado;
- sem crop agressivo;
- respiro interno ao redor da arte;
- hero continua em duas colunas;
- responsividade para tablet/mobile;
- nenhuma alteração no contrato Atlas, busca, modalidades ou eventos.

## Aplicação
Copie `app/assets/stylesheets/pp02_4_7.css`.

Em `app/views/layouts/public_portal.html.erb`, após o stylesheet da PP02.4.6:

```erb
<%= stylesheet_link_tag "pp02_4_7", "data-turbo-track": "reload" %>
```

## Comandos

Não há migration, bundle ou db:prepare.

```powershell
docker compose exec web bundle exec rails zeitwerk:check
```

```powershell
docker compose exec web bundle exec rspec `
  spec/qualification/pp02_4_7_hero_runner_image_sizing_framing_qualification_spec.rb `
  spec/qualification/pp02_4_6_official_logo_image_qualification_spec.rb `
  spec/requests/public_portal/pp02_4_home_discovery_spec.rb `
  spec/qualification/pp02_4_home_discovery_qualification_spec.rb
```

```powershell
docker compose restart web
```

Depois valide em `http://localhost:3001` com `Ctrl+F5`.
