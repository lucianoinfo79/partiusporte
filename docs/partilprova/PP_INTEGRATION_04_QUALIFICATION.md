# PP-INTEGRATION.04 — Qualificação Operacional Atlas → PartilProva

## Escopo deste incremento
Etapa de **qualificação**, sem alteração dos serviços Rails ou banco. O script `tools/qualification/pp_integration_04_smoke.ps1` verifica os endpoints públicos e o contrato de inscrição usando somente HTTP GET.

### Contratos verificados no código-fonte fornecido
- `Atlas::Partilprova::PublishCommercialEvent`: exige contrato ativo, oportunidade ganha e proposta; usa `ConvertContractToEvent`, atribui provedor e publica via `PublicationTransition`.
- `Atlas::Partilprova::CommercialServiceScope`: `atlas` requer serviço contratado `COR-INSC-001`; inscrição gerenciada contratada não pode ser publicada como `external` ou `unavailable`.
- `Atlas::PublicApi::V1::EventDetailSerializer`: expõe `registration.status`, `opens_at`, `closes_at`, `provider`, `target`.
- `Atlas::PublicApi::V1::RegistrationRouting`: `atlas` retorna rota pública relativa; `external` URL externa; `unavailable` sem target.
- PartilProva consome `events` e `events/:slug`; não replica a base do Atlas.

### Execução no PowerShell
Na raiz do PartilProva, ajuste URLs de acordo com a sua instalação:
```
powershell -ExecutionPolicy Bypass -File .\tools\qualification\pp_integration_04_smoke.ps1 `
  -AtlasApiBase "http://localhost:3000/api/public/v1" `
  -PartilprovaBase "http://localhost:3001" `
  -EventSlug "3-maratona-natalina" `
  -ExpectedProvider "unavailable"
```
`-ExpectedStatus` é opcional; informe somente se souber o status real do Atlas.

### Gates manuais antes de declarar E2E aprovado
1. Contrato ativo, oportunidade ganha, proposta aceita: publicar edição pelo workspace comercial do Atlas.
2. Proposta com `COR-INSC-001`: somente `atlas`; confirmar CTA público com destino autorizado e janela aberta.
3. Proposta sem `COR-INSC-001`: testar `external` com URL HTTPS e `unavailable` sem CTA.
4. Alterar dados públicos no Atlas e confirmar atualização no PartilProva (considerar cache).
5. Confirmar que evento não publicado não aparece no catálogo nem abre detalhe.
6. Validar inscrição real e retorno do Mercado Pago **em ambiente sandbox**, com callbacks, idempotência e confirmação no Atlas. O script NÃO executa pagamento.
7. Reexecutar RSpec e Zeitwerk nos dois projetos; guardar evidências.

### RSpec Atlas (caminhos do código inspecionado)
```
docker compose exec -e RAILS_ENV=test web bundle exec rspec \
  spec/services/atlas/partilprova/publish_commercial_event_spec.rb \
  spec/services/atlas/partilprova/commercial_service_scope_spec.rb \
  spec/services/atlas/public_api/v1/registration_routing_spec.rb \
  spec/requests/api/public/v1/events_spec.rb
```
Executar na instalação Atlas com PP-INTEGRATION.01–03 aplicadas.

### RSpec PartilProva
```
docker compose exec -e RAILS_ENV=test web bundle exec rspec \
  spec/services/partilprova/public_portal/home_discovery_spec.rb \
  spec/services/partilprova/public_portal/pp_integration_03_3_1_registration_states_spec.rb \
  spec/services/partilprova/public_portal/registration_handoff_spec.rb
```

### Critério de aceite
Smoke HTTP aprovado + RSpec e Zeitwerk aprovados + cenários comerciais e publicação verificados + pagamento sandbox validado quando aplicável. Não inferir aprovação E2E apenas de HTTP 200.
