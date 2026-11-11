# PP-INTEGRATION.03.3 — Detalhes do Evento e Inscrições

Patch incremental sobre PP-INTEGRATION.03.2.

- Projeta status, provedor, destino e período de inscrição do contrato público Atlas.
- Apresenta datas no formato brasileiro e status de inscrições em português.
- Não apresenta CTA quando o provedor é `unavailable` ou o status não é aberto.
- Provedor `external`: utiliza o `registration.target` emitido pelo Atlas.
- Provedor `atlas`: resolve apenas caminho público conhecido, usando origem pública HTTPS e allowlist.
- Mantém o bloqueio de domínios não autorizados e URLs inseguras.

Configuração para destinos HTTPS reais:
`PARTILPROVA_REGISTRATION_ALLOWED_HOSTS=dominio.atlas.com.br,inscricoes.organizador.com.br`
`PARTILPROVA_ATLAS_PUBLIC_ORIGIN=https://dominio.atlas.com.br`

Não altere a allowlist para aceitar endereços internos, localhost ou HTTP.
O evento exibido como `unavailable` depende de correção/publicação do provedor no Atlas.
Não há migrations.
