# PP02.3.1 — Zeitwerk Error Boundary Fix

## Causa
A PP02.3 definiu várias constantes irmãs (`Error`, `HttpError`, `TimeoutError`,
`TransportError`, `InvalidResponseError`) em `errors.rb`.

Pela convenção do Zeitwerk, `errors.rb` deve definir `Partilprova::AtlasApi::Errors`.
Assim, referências diretas a `Partilprova::AtlasApi::HttpError` etc. não
encontravam arquivos correspondentes para autoload.

## Correção
Cada classe de erro passa a residir em seu arquivo Zeitwerk-compatible:

- error.rb
- transport_error.rb
- timeout_error.rb
- invalid_response_error.rb
- http_error.rb

`errors.rb` permanece no projeto, mas agora define apenas o namespace `Errors`,
evitando erro de eager-load/zeitwerk:check.

## Comandos

```powershell
docker compose exec web bundle exec rails zeitwerk:check
```

```powershell
docker compose exec web bundle exec rspec `
  spec/services/partilprova/atlas_api/configuration_spec.rb `
  spec/services/partilprova/atlas_api/client_spec.rb `
  spec/services/partilprova/atlas_api/net_http_transport_spec.rb `
  spec/qualification/pp02_3_atlas_public_api_client_qualification_spec.rb
```

Não requer migration, bundle install/update, db:prepare ou assets.
