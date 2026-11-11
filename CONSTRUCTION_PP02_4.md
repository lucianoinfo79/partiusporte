# PP02.4 — Home / Descobrir Provas

## Entrega
- Home funcional conforme direção visual aprovada;
- hero “Encontre seu próximo desafio”;
- busca pública por texto;
- filtro por modalidade;
- grade de eventos em destaque;
- `Partilprova::PublicPortal::HomeDiscovery` como fronteira de apresentação;
- consumo do endpoint público `events` pelo client PP02.3;
- degradação segura quando Atlas estiver indisponível;
- responsividade desktop/mobile;
- atualização do spec PP02.2, removendo a expectativa da antiga vitrine temporária.

## Contrato PP02.4 com Atlas
GET `events` com `q`, `modality`, `featured=true`, `limit=8`.
A resposta aceita coleção direta ou envelope `events`/`data`. A camada normaliza apenas campos públicos necessários à Home.

## Comandos
Não requer migration, bundle, db:prepare ou assets.

```powershell
docker compose exec web bundle exec rails zeitwerk:check
```

```powershell
docker compose exec web bundle exec rspec `
  spec/services/partilprova/public_portal/home_discovery_spec.rb `
  spec/requests/public_portal/pp02_4_home_discovery_spec.rb `
  spec/qualification/pp02_4_home_discovery_qualification_spec.rb
```

Regressão:
```powershell
docker compose exec web bundle exec rspec `
  spec/services/partilprova/atlas_api/configuration_spec.rb `
  spec/services/partilprova/atlas_api/client_spec.rb `
  spec/services/partilprova/atlas_api/net_http_transport_spec.rb `
  spec/services/partilprova/public_portal/home_discovery_spec.rb `
  spec/requests/public_portal/home_spec.rb `
  spec/requests/public_portal/pp02_2_public_shell_spec.rb `
  spec/requests/public_portal/pp02_4_home_discovery_spec.rb `
  spec/qualification/pp02_1_project_bootstrap_architecture_qualification_spec.rb `
  spec/qualification/pp02_2_design_system_public_shell_qualification_spec.rb `
  spec/qualification/pp02_3_atlas_public_api_client_qualification_spec.rb `
  spec/qualification/pp02_4_home_discovery_qualification_spec.rb
```

Validação visual: `http://localhost:3001`
