# Correction PP03.5.1 — RSpec described_class

O grupo `RSpec.describe "PP03.5 operational registration handoff"` descreve uma String; portanto, `described_class` é `nil`. Substituímos a referência por `Partilprova::PublicPortal::RegistrationHandoff` no cenário HTTPS, sem alterar a implementação nem suas políticas de segurança.

Aplicar o ZIP na raiz do projeto PartilProva.

```powershell
docker compose exec web bundle exec rspec spec/services/partilprova/public_portal/pp03_5_operational_registration_spec.rb

docker compose exec web bundle exec rspec `
  spec/requests/public_portal `
  spec/services/partilprova `
  spec/qualification
```

Não exige migration. RSpec deve ser executado no Docker local.
