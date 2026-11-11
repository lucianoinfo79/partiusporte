# PP02.1.5 — RSpec Test Environment Isolation Fix

## Causa confirmada no ZIP atual

O serviço `web` do Compose exporta:

- `RAILS_ENV=development`
- `DATABASE_URL=.../partilprova_development`

O `spec/rails_helper.rb` usava:

```ruby
ENV['RAILS_ENV'] ||= 'test'
```

Como `RAILS_ENV` já chegava definido como `development`, o RSpec iniciado por
`docker compose exec web ...` carregava o ambiente de desenvolvimento. Por isso
as regras de `config/environments/test.rb` não governavam os request specs e o
HostAuthorization continuava retornando 403.

Além disso, o `DATABASE_URL` herdado apontava para o banco de desenvolvimento,
o que não é aceitável para a suíte de testes.

## Correção

### `spec/rails_helper.rb`

Antes de carregar `config/environment`:

```ruby
ENV['RAILS_ENV'] = 'test'
ENV['DATABASE_URL'] = ENV.fetch(
  'TEST_DATABASE_URL',
  'postgresql://postgres:postgres@db:5432/partilprova_test'
)
```

### `compose.yaml`

Adiciona ao serviço `web`:

```yaml
TEST_DATABASE_URL: postgresql://postgres:postgres@db:5432/partilprova_test
```

O `DATABASE_URL` normal continua apontando para `partilprova_development`, de
modo que o servidor de desenvolvimento não muda de banco.

## Aplicação

Extrair na raiz `C:\partilprova`, substituindo os dois arquivos.

Como `compose.yaml` mudou, recrie o container web:

```powershell
docker compose up -d --force-recreate web
```

Prepare o banco de teste explicitamente:

```powershell
docker compose exec web bundle exec rails runner "puts 'WEB_ENV=' + Rails.env.to_s; puts 'WEB_DB=' + ActiveRecord::Base.connection_db_config.database"
```

O comando acima deve continuar mostrando development para o servidor normal.

```powershell
docker compose exec web sh -lc 'RAILS_ENV=test DATABASE_URL="$TEST_DATABASE_URL" bundle exec rails db:prepare'
```

Valide o bootstrap do RSpec:

```powershell
docker compose exec web bundle exec rspec spec/services/partilprova/atlas_api/configuration_spec.rb --format documentation
```

Depois execute o gate:

```powershell
docker compose exec web bundle exec rspec `
  spec/services/partilprova/atlas_api/configuration_spec.rb `
  spec/requests/public_portal/home_spec.rb `
  spec/qualification/pp02_1_project_bootstrap_architecture_qualification_spec.rb
```

Meta:

`6 examples, 0 failures`

## Sem necessidade

- bundle install
- migration nova
- assets
- rebuild da imagem
