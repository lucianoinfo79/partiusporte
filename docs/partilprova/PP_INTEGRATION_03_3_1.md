# PP-INTEGRATION.03.3.1 — Consistência dos Estados de Inscrição

Patch incremental sobre PP-INTEGRATION.03.3.

- O status `unavailable` prevalece mesmo sem `registration_provider`.
- `upcoming`/`not_open` não são confundidos com indisponibilidade.
- `closed`, `cancelled` e `sold_out` possuem estados e mensagens distintos.
- Status desconhecidos bloqueiam o botão de inscrição (fail-closed).
- Badge e mensagem da página usam a MESMA classificação de RegistrationHandoff.
- URLs HTTPS continuam submetidas à allowlist de hosts.

Não há migration, alteração de dados ou configuração.
Executar os specs novos e existentes para validar a compatibilidade.
