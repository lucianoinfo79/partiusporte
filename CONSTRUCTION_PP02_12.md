# PP02.12 — End-to-End Qualification & Regression Gate

## Entrega
Patch incremental: adiciona testes de jornada pública, contrato de rotas e runner PowerShell. Não altera código de produção, dependências, banco ou migrations.

## Aplicação
Extrair este ZIP em `C:\partilprova` (raiz do repositório; **não** dentro de uma pasta adicional).

## Execução
```powershell
.\RUN_PP02_12.ps1
```
Ou, individualmente:
```powershell
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec web bundle exec rspec spec/requests/public_portal/pp02_12_public_journey_spec.rb spec/qualification/pp02_12_end_to_end_regression_gate_spec.rb
docker compose exec web bundle exec rspec spec/requests/public_portal spec/services/partilprova spec/qualification
```

## Gate de aceite
- `zeitwerk:check` aprovado;
- specs novas aprovadas;
- suites existentes de request, serviços e qualificação aprovadas;
- inspeção manual em navegador: Home, Eventos, detalhe, resultados, fotos, handoff de inscrição e participante, responsividade, tema e links externos;
- ambiente de staging com Atlas Public API real: verificar contrato, latência, falhas transitórias, robots/sitemap, variáveis de ambiente e cache compartilhado;
- registrar número de exemplos/falhas, seed, SHA do commit, data e ambiente.

**Nota:** os testes de request usam stubs nos pontos de integração; não comprovam conectividade real com Atlas, entrega de fotos/resultados reais ou experiência de navegador. O gate só deve ser fechado após evidências de execução e checklist manual.
