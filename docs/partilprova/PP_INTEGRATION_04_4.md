# PP-INTEGRATION.04.4 — Qualificação do Direcionamento e Fluxo de Inscrição

## Evidência inicial
Na captura da 3ª Maratona Natalina, a etiqueta diz **Inscrições abertas**, mas o CTA está ausente e aparece a mensagem genérica **Inscrições: informações em breve**. Isso indica status `open` com `RegistrationHandoff` bloqueado. A causa provável é a ausência de `PARTILPROVA_ATLAS_PUBLIC_ORIGIN`, a allowlist vazia ou um target ausente/inválido; confirmar com o diagnóstico, não assumir.

## Segurança
O PartilProva **não deve** redirecionar o participante para host arbitrário. O `RegistrationHandoff` exige HTTPS, host explicitamente permitido, porta 443 e rota relativa emitida pelo Atlas. Não liberar `localhost`, IP ou HTTP como exceção em produção. Para testes locais, usar um domínio de desenvolvimento com HTTPS e roteamento confiável para o Atlas, ou testar via RSpec com domínio de exemplo.

## Executar no PartilProva (Linux/WSL)
```
docker compose exec -e PP_EVENT_SLUG=3-maratona-natalina web bundle exec rails runner tools/qualification/pp_integration_04_4.rb
docker compose exec -e RAILS_ENV=test web bundle exec rspec spec/services/partilprova/public_portal/pp_integration_04_4_registration_handoff_spec.rb spec/services/partilprova/public_portal/pp_integration_03_3_1_registration_states_spec.rb
docker compose exec web bundle exec rails zeitwerk:check
```
O runner informa apenas host/estado, não expõe URL completa, tokens ou credenciais.

## Configuração (somente após confirmar o diagnóstico)
No serviço `web` do PartilProva, configurar os valores de ambiente adequados ao domínio público real do Atlas:
```
PARTILPROVA_ATLAS_PUBLIC_ORIGIN=https://<dominio-publico-atlas>
PARTILPROVA_REGISTRATION_ALLOWED_HOSTS=<dominio-publico-atlas>
```
Aplicar e recriar serviço conforme sua configuração Docker Compose. Evitar copiar placeholders literalmente.

## Gate de ponta a ponta
1. `registration.status=open` na API do Atlas.
2. `RegistrationHandoff.state=available` com URL HTTPS aprovada e rota correta.
3. Clique real no botão e abertura da página de inscrição do Atlas.
4. Formulário de inscrição, lotes, vagas, pagamento sandbox (ou responsabilidade do contratante), confirmação e retorno ao portal.
5. Bloqueio de inscrição quando o status mudar para `closed` ou `unavailable`.
Este incremento **não** afirma que os passos 3–5 foram concluídos.
