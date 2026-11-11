# Correction PP03.6.1 — Alinhamento da regressão de resultados

Atualiza o teste legado de RaceResults para o contrato PP03.6: a API Atlas v1 suporta paginação, mas não aplica os filtros `q` e `category`. A implementação protege o usuário retornando `filters_unsupported` antes de consultar a API.

## Aplicação
Extrair o ZIP na raiz `C:\partilprova`, sobrescrevendo o teste existente. Nenhuma migration necessária.

## Testes
```powershell
docker compose exec web bundle exec rspec `
  spec/services/partilprova/public_portal/race_results_spec.rb `
  spec/services/partilprova/public_portal/pp03_6_atlas_results_compatibility_spec.rb

docker compose exec web bundle exec rspec `
  spec/requests/public_portal `
  spec/services/partilprova `
  spec/qualification
```

Nenhuma mudança no código de produção. Qualificação RSpec pendente no ambiente Docker do usuário.
