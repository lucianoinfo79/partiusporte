# PP02.4.4 — Green Runner Hero Final

Mockup aprovado convertido em implementação incremental da Home.

## Alterações
- substitui o runner SVG anterior pelo visual verde aprovado;
- usa asset local `green-runner-hero.jpg`;
- renderiza pelo asset pipeline Rails;
- remove definitivamente a composição provisória 01 / PARTIL / PROVA;
- mantém busca, modalidades, eventos e integração Atlas intactos;
- mantém responsividade.

## Comandos
Não há migration, bundle install/update ou db:prepare.

```powershell
docker compose exec web bundle exec rails zeitwerk:check
```

```powershell
docker compose exec web bundle exec rspec `
  spec/qualification/pp02_4_4_green_runner_hero_qualification_spec.rb `
  spec/requests/public_portal/pp02_4_home_discovery_spec.rb `
  spec/qualification/pp02_4_home_discovery_qualification_spec.rb
```

```powershell
docker compose restart web
```

Valide em `http://localhost:3001` com `Ctrl+F5`.
