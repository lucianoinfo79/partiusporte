# Correction PP02.12.1 — Visual Regression Gate

Corrige somente quatro specs de qualificação visual legados (seis falhas). A identidade aprovada usa `partilprova-logo.png` no header, `green-runner-hero.jpg` na Home e os estilos `pp02_4` / `pp02_4_6`. Nenhuma view, CSS, rota, serviço ou migration foi alterado.

## Aplicação

Extraia o ZIP na raiz `C:\partilprova` com substituição dos quatro arquivos em `spec/qualification`.

## Validação

```powershell
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec web bundle exec rspec `
  spec/qualification/pp02_4_2_home_final_visual_parity_qualification_spec.rb `
  spec/qualification/pp02_4_3_runner_brand_hero_visual_qualification_spec.rb `
  spec/qualification/pp02_4_4_green_runner_hero_qualification_spec.rb `
  spec/qualification/pp02_4_5_runner_icon_header_qualification_spec.rb

docker compose exec web bundle exec rspec `
  spec/requests/public_portal `
  spec/services/partilprova `
  spec/qualification
```

Não executado localmente: o RSpec deve ser qualificado no Docker do projeto.
