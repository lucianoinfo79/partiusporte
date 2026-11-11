# Construction PP03.4 — Página Operacional da Prova

Base: partilprova(20261009-005808).zip; contrato comparado com atlas(20261009-005213).zip.

## Alterações
- Adapta `data` do Atlas Public API v1 e campos aninhados `location`, `registration`, `results` e `photos`.
- Reconhece `location.venue` e `registration.status`.
- Para inscrições externas, utiliza `registration.target` somente quando a URL é HTTP(S); o `RegistrationHandoff` continua exigindo HTTPS e host permitido.
- Não converte automaticamente o target relativo de inscrições Atlas em URL externa; isso pertence à PP03.5.
- Bloqueia defensivamente detalhes com status editorial explicitamente privado.
- Mantém a apresentação atual e o tratamento de erros HTTP.

## Aplicação
Extrair o ZIP incremental na raiz do PartilProva.

```powershell
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec web bundle exec rspec spec/services/partilprova/public_portal/pp03_4_operational_detail_spec.rb
docker compose exec web bundle exec rspec spec/requests/public_portal spec/services/partilprova spec/qualification
```

Não requer migration. Sintaxe Ruby verificada localmente; RSpec requer Docker do projeto.
