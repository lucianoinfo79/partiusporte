# PP-INTEGRATION.04.4.1 — Direcionamento Local Seguro

## Regra implementada
Somente no ambiente Rails `development`, e somente para `registration_provider=atlas`, permite `http://localhost:3000` com rota exata `/events/:event/editions/:edition/register`. Não habilita HTTP para links externos, não aceita outra porta, IP, credenciais, parâmetros ou fragmentos, e não muda a validação HTTPS/allowlist para produção e teste.

## Configurar no Docker Compose do PartilProva
No `.env` usado pelo Compose:
```
PARTILPROVA_ATLAS_PUBLIC_ORIGIN=http://localhost:3000
PARTILPROVA_REGISTRATION_ALLOWED_HOSTS=
```
Atenção: a variável deve estar no **ambiente do contêiner**, não apenas no `.env` de interpolação do Compose. Se necessário, no serviço `web` de `compose.yml` / `docker-compose.yml` acrescente em `environment:`:
```
PARTILPROVA_ATLAS_PUBLIC_ORIGIN: ${PARTILPROVA_ATLAS_PUBLIC_ORIGIN:-}
PARTILPROVA_REGISTRATION_ALLOWED_HOSTS: ${PARTILPROVA_REGISTRATION_ALLOWED_HOSTS:-}
```
Faça o mesmo no serviço de jobs somente se ele utilizar RegistrationHandoff. Não substitua o restante da configuração do Compose.

Recriar serviço (no PowerShell):
```
docker compose up -d --force-recreate web
docker compose exec web printenv PARTILPROVA_ATLAS_PUBLIC_ORIGIN
docker compose exec web bundle exec rails runner 'puts Rails.env'
```
Esperado: `http://localhost:3000` e `development`.

## Testes (PowerShell)
```
docker compose exec -e RAILS_ENV=test web bundle exec rspec spec/services/partilprova/public_portal/pp_integration_04_4_1_local_handoff_spec.rb spec/services/partilprova/public_portal/pp_integration_04_4_registration_handoff_spec.rb spec/services/partilprova/public_portal/pp_integration_03_3_1_registration_states_spec.rb spec/services/partilprova/public_portal/registration_handoff_spec.rb
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec -e PP_EVENT_SLUG=3-maratona-natalina web bundle exec rails runner tools/qualification/pp_integration_04_4.rb
```
O diagnóstico PP-INTEGRATION.04.4 anterior exige HTTPS e allowlist mesmo em desenvolvimento; os checks `atlas_public_origin_https` e `atlas_origin_host_allowlisted` são **incompatíveis com a exceção local**. O resultado `handoff_available` e os testes de regressão são o gate desta etapa. A qualificação de browser deve confirmar clique real no CTA e a resposta da rota do Atlas. Não confundir a porta acessível ao navegador (`localhost:3000`) com o hostname da API Docker interna.

## Segurança
A exceção depende de `Rails.env.development?`, não de uma variável booleana de configuração que pudesse ser ligada em produção. Não utilizar `RAILS_ENV=development` em implantação pública. Nenhum evento ou banco de dados é modificado.
