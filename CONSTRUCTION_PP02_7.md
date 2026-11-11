# PP02.7 — Registration Handoff

Incremental sobre o `partilprova(6).zip` enviado.

## Contrato e limites
- Não cria inscrições nem recebe pagamentos: apenas entrega o usuário ao endereço publicado no Atlas.
- Inscrição patrocinada e responsabilidade financeira continuam sendo determinadas exclusivamente pelo Atlas.
- Somente URLs HTTPS com hostname exato explicitamente permitido são clicáveis.
- Nenhum domínio é liberado por padrão; `PARTILPROVA_REGISTRATION_ALLOWED_HOSTS` recebe hostnames separados por vírgula, **sem protocolo**.
- URLs não autorizadas e status `closed`, `cancelled`, `suspended`, `ended`, `sold_out` etc. não exibem CTA.
- O destino externo abre em nova aba, com `noopener noreferrer`.
- O contrato de `registration_url` e `registration_status` da PP02.6 permanece; sua implementação real no Atlas ainda precisa ser validada.

## Configuração
No serviço `web` do Docker Compose, configure uma variável de ambiente, substituindo pelos **domínios reais e confiáveis** de inscrição:

`PARTILPROVA_REGISTRATION_ALLOWED_HOSTS=inscricoes.seudominio.com.br,outra-plataforma-confiavel.com.br`

Recrie o container para aplicar a variável. Não copie os exemplos como domínios de produção.

## Comandos (PowerShell)
```powershell
docker compose exec web bundle exec rails zeitwerk:check

docker compose exec web bundle exec rspec `
  spec/services/partilprova/public_portal/registration_handoff_spec.rb `
  spec/qualification/pp02_7_registration_handoff_qualification_spec.rb `
  spec/services/partilprova/public_portal/event_detail_spec.rb `
  spec/requests/public_portal/pp02_6_event_detail_spec.rb

docker compose up -d --force-recreate web
```
Sem migrations ou bundle update.
