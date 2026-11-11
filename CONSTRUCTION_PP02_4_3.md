# PP02.4.3 — Runner Brand & Hero Visual Finalization

## Objetivo
Fechar a paridade visual da Home aprovada.

## Correções
- o corredor do logo passa a ser renderizado com `image_tag`, usando o asset pipeline do Rails;
- elimina o caminho CSS absoluto `/assets/...` que fazia o corredor desaparecer no header;
- remove completamente a composição provisória `01 / PARTIL / PROVA` do hero;
- renderiza o corredor do hero via `image_tag`;
- adiciona halo e linhas de movimento como composição esportiva;
- mantém busca, modalidades, agenda e integração Atlas inalteradas;
- mantém comportamento responsivo.

## Arquivos incrementais
- app/views/layouts/public_portal.html.erb
- app/views/public_portal/home/show.html.erb
- app/assets/stylesheets/pp02_4_3.css
- spec/qualification/pp02_4_3_runner_brand_hero_visual_qualification_spec.rb

Os SVGs `runner-mark.svg` e `runner-hero.svg` já existem no projeto atual e são reutilizados.

## Comandos

Não há migration, bundle install/update ou db:prepare.

```powershell
docker compose exec web bundle exec rails zeitwerk:check
```

```powershell
docker compose exec web bundle exec rspec `
  spec/qualification/pp02_4_3_runner_brand_hero_visual_qualification_spec.rb `
  spec/qualification/pp02_4_2_home_final_visual_parity_qualification_spec.rb `
  spec/qualification/pp02_4_1_visual_parity_home_qualification_spec.rb `
  spec/requests/public_portal/pp02_4_home_discovery_spec.rb `
  spec/qualification/pp02_4_home_discovery_qualification_spec.rb
```

```powershell
docker compose restart web
```

Validação visual:
`http://localhost:3001`

Use `Ctrl+F5`.
