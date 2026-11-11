# PP03.5 — Integração Operacional das Inscrições

Base: partilprova(20261009-010128).zip; contrato Atlas examinado em atlas(20261009-005213).zip.

## Contrato Atlas

`registration.provider = atlas` envia `registration.target = /events/:event_public_id/editions/:edition_public_id/register`.
`registration.provider = external` envia URL externa no mesmo campo. `registration.status` controla disponibilidade.

## Mudanças

- Preserva `registration.target` no detalhe normalizado.
- Para `provider=atlas`, constrói o destino HTTPS usando `PARTILPROVA_ATLAS_PUBLIC_ORIGIN` (ex.: `https://atlas.exemplo.com.br`).
- Exige que o host da origem conste em `PARTILPROVA_REGISTRATION_ALLOWED_HOSTS`.
- Aceita somente o padrão de rota de inscrição do Atlas, sem query string, fragmentos, caminhos arbitrários ou redirect de origem não confiável.
- Para `provider=external`, mantém a verificação de HTTPS e allowlist já existente.
- Não cria inscrições, pagamentos ou dados pessoais no PartilProva.
- O destino externo abre em nova aba, conforme UI já existente.

## Configuração (exemplo; substituir pelo domínio público real)

`PARTILPROVA_ATLAS_PUBLIC_ORIGIN=https://atlas.exemplo.com.br`
`PARTILPROVA_REGISTRATION_ALLOWED_HOSTS=atlas.exemplo.com.br,inscricoes.organizador.com.br`

Não usar `http://web:3000` ou `localhost` como origem pública.

## Comandos

```powershell
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec web bundle exec rspec spec/services/partilprova/public_portal/pp03_5_operational_registration_spec.rb
docker compose exec web bundle exec rspec spec/requests/public_portal spec/services/partilprova spec/qualification
```

Sem migration. Homologar manualmente o fluxo completo Atlas/organizador no ambiente público antes de liberar produção.
