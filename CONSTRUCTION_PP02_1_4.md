# PP02.1.4 — RSpec Host Authorization Fix

## Escopo incremental

Substitui somente:

- `config/environments/test.rb`

A correção mantém explicitamente autorizados no ambiente `test`:

```ruby
config.hosts << "www.example.com"
config.hosts << "example.com"
```

Não utiliza `config.hosts.clear`.

## Aplicação

Extraia o ZIP na raiz:

`C:\partilprova`

permitindo substituir o arquivo existente.

## Validação

```powershell
docker compose exec web bundle exec rails runner -e test "puts Rails.application.config.hosts.inspect"
```

Esperado: ambos `www.example.com` e `example.com`.

```powershell
docker compose exec web bundle exec rails runner -e test "request = Rack::MockRequest.new(Rails.application); ['www.example.com','example.com'].each { |host| response = request.get('/', 'HTTP_HOST' => host); puts host + ' => ' + response.status.to_s }"
```

Esperado:

```text
www.example.com => 200
example.com => 200
```

Gate PP02.1:

```powershell
docker compose exec web bundle exec rspec `
  spec/services/partilprova/atlas_api/configuration_spec.rb `
  spec/requests/public_portal/home_spec.rb `
  spec/qualification/pp02_1_project_bootstrap_architecture_qualification_spec.rb
```

Meta:

`6 examples, 0 failures`

Não requer migration, bundle install, rebuild, assets ou db:prepare.
