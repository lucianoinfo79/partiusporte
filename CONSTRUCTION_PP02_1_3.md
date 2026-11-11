# PP02.1.3 — Test Environment & Zeitwerk Boundary Fix

## Correções

1. `config/environments/test.rb`
   - autoriza `www.example.com`, host padrão dos request specs do Rails/RSpec;
   - elimina o 403 de `ActionDispatch::HostAuthorization`.

2. `Partilprova::AtlasApi::Configuration`
   - mantém o namespace canônico já implementado no arquivo
     `app/services/partilprova/atlas_api/configuration.rb`;
   - o nome `Partilprova` corresponde à inflexão Zeitwerk do diretório `partilprova`;
   - corrige o qualification spec que usava incorretamente `PartilProva`.

3. Qualification spec
   - permanece explicitamente `type: :request`;
   - usa `get "/"`, sem depender de helper de rota no gate.

## Aplicação

Extrair este ZIP na raiz `C:\partilprova`, permitindo substituir os arquivos.

## Validação

```powershell
docker compose exec web bundle exec rails zeitwerk:check

docker compose exec web bundle exec rspec `
  spec/services/partilprova/atlas_api/configuration_spec.rb `
  spec/requests/public_portal/home_spec.rb `
  spec/qualification/pp02_1_project_bootstrap_architecture_qualification_spec.rb
```

Esperado:

`6 examples, 0 failures`
