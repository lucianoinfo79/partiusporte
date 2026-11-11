# PP02.3 — Atlas Public API Client

## Objetivo
Criar a fronteira HTTP do PartilProva para consumo da API pública do Atlas, sem acoplar controllers/views a `Net::HTTP` e sem depender de Atlas online durante a suíte.

## Entregue
- `Partilprova::AtlasApi::Client` com GET, query params e headers;
- `NetHttpTransport` isolando `Net::HTTP`;
- uso dos timeouts já definidos em `Configuration`;
- parsing JSON e suporte a resposta 204/vazia;
- `Response` tipada com status, headers, payload, raw body e request-id;
- erros tipados para HTTP, timeout, transporte e JSON inválido;
- testes unitários com transporte fake, sem chamada de rede;
- qualification gate da fronteira Atlas Public API.

## Fora do escopo
Endpoints concretos de catálogo/eventos e DTOs de domínio entram nas próximas constructions, quando o contrato público correspondente do Atlas estiver sendo consumido. Cache/fallback/observabilidade completa permanecem para PP02.11.

## Aplicação
Extrair o ZIP na raiz `C:\partilprova`, substituindo/adicionando os arquivos.

## Comandos
Não há migration, `bundle install`, `db:prepare` ou assets.

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

Regressão do portal até PP02.3:

```powershell
docker compose exec web bundle exec rspec `
  spec/services/partilprova/atlas_api/configuration_spec.rb `
  spec/services/partilprova/atlas_api/client_spec.rb `
  spec/services/partilprova/atlas_api/net_http_transport_spec.rb `
  spec/requests/public_portal/home_spec.rb `
  spec/requests/public_portal/pp02_2_public_shell_spec.rb `
  spec/requests/public_portal/pp02_2_1_session_serialization_spec.rb `
  spec/qualification/pp02_1_project_bootstrap_architecture_qualification_spec.rb `
  spec/qualification/pp02_2_design_system_public_shell_qualification_spec.rb `
  spec/qualification/pp02_3_atlas_public_api_client_qualification_spec.rb
```
