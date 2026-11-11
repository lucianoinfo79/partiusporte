# PP02.2.1.1 — RSpec Request Session Probe Fix

Corrige somente o spec de regressão da PP02.2.1.

## Causa
`controller(ApplicationController)` é DSL de controller specs e não está disponível
neste request spec. O erro ocorreu durante o carregamento do arquivo, portanto o
teste de serialização de sessão nunca chegou a executar.

## Correção
O request spec agora cria um controller temporário com `stub_const`, instala uma
rota temporária, grava a sessão por uma requisição HTTP real e restaura as rotas
ao final.

## Comando
```powershell
docker compose exec web bundle exec rspec `
  spec/requests/public_portal/pp02_2_1_session_serialization_spec.rb
```

Nenhuma migration, bundle update, db:prepare ou assets é necessária para esta
correção do spec. O pin da gem json realizado pela PP02.2.1 permanece inalterado.
