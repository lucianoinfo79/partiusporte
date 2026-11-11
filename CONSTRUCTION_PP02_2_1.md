# PP02.2.1 — Rails/JSON Session Serialization Compatibility

## Diagnóstico

Runtime observado:

- Rails 8.0.5.1
- ActiveSupport 8.0.5.1
- json 3.0.2

A falha ocorre no commit de cookie/sessão JSON com:

`ArgumentError: unknown keyword: quirks_mode`

A linha 3.x da gem `json` passou a rejeitar opções desconhecidas. Esta Construction
mantém o Rails atual e fixa `json` na linha 2.21.x compatível, sem monkey patch e
sem desabilitar sessões.

## Alterações

- `Gemfile`: adiciona `gem "json", "~> 2.21.2"`.
- adiciona regression spec que grava uma sessão e exige emissão de `Set-Cookie`.

O `Gemfile.lock` não é distribuído neste incremental: ele deve ser recalculado
pelo Bundler dentro do Docker, preservando a plataforma real do projeto.

## Aplicação

Extraia na raiz `C:\partilprova`, substituindo/adicionando os arquivos.

## Comandos obrigatórios

Atualize somente a dependência JSON:

```powershell
docker compose run --rm web bundle update json
```

Confirme:

```powershell
docker compose run --rm web bundle exec ruby -e "require 'json'; puts JSON::VERSION"
```

Esperado: `2.21.x`.

Como o bundle está em volume Docker, recrie o processo web para eliminar o
processo Rails que carregou json 3.0.2:

```powershell
docker compose up -d --force-recreate web
```

Gate específico:

```powershell
docker compose exec web bundle exec rspec `
  spec/requests/public_portal/pp02_2_1_session_serialization_spec.rb
```

Regressão PP02.1 + PP02.2:

```powershell
docker compose exec web bundle exec rspec `
  spec/services/partilprova/atlas_api/configuration_spec.rb `
  spec/requests/public_portal/home_spec.rb `
  spec/requests/public_portal/pp02_2_public_shell_spec.rb `
  spec/requests/public_portal/pp02_2_1_session_serialization_spec.rb `
  spec/qualification/pp02_1_project_bootstrap_architecture_qualification_spec.rb `
  spec/qualification/pp02_2_design_system_public_shell_qualification_spec.rb
```

Depois valide no navegador:

`http://localhost:3001`

Não requer migration, `db:prepare` ou assets.
