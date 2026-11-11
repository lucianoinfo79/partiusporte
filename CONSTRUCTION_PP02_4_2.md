# PP02.4.2 — Home / Descobrir Provas — Final Visual Parity

Atualização incremental da página inicial conforme o último mockup aprovado.

## Alterações
- remove definitivamente a seta verde do logo;
- adiciona marca com corredor em navy/verde;
- adiciona ilustração esportiva do hero;
- reforça composição visual do hero, busca, modalidades, eventos e CTA;
- preserva integralmente o contrato funcional PP02.4 com Atlas;
- mantém responsividade.

## Arquivos
- app/views/layouts/public_portal.html.erb
- app/assets/stylesheets/pp02_4.css
- app/assets/images/partilprova/runner-mark.svg
- app/assets/images/partilprova/runner-hero.svg
- spec/qualification/pp02_4_2_home_final_visual_parity_qualification_spec.rb

## Comandos
Não há migration, bundle install/update ou db:prepare.

```powershell
docker compose exec web bundle exec rails zeitwerk:check
```

```powershell
docker compose exec web bundle exec rspec `
  spec/qualification/pp02_4_2_home_final_visual_parity_qualification_spec.rb `
  spec/qualification/pp02_4_1_visual_parity_home_qualification_spec.rb `
  spec/requests/public_portal/pp02_4_home_discovery_spec.rb `
  spec/qualification/pp02_4_home_discovery_qualification_spec.rb
```

```powershell
docker compose restart web
```

Depois: `http://localhost:3001` e `Ctrl+F5`.
