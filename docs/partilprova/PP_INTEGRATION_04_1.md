# PP-INTEGRATION.04.1 — Correção do Smoke Test

Patch incremental sobre PP-INTEGRATION.04. Corrige conflito com variável automática `$HOME` do PowerShell, utilizando `$homeResponse`. Exibe provedor e status devolvidos pelo Atlas sem expor URLs ou credenciais. Mantém verificação explícita de `-ExpectedProvider`, que não deve ser ajustada apenas para tornar o teste verde.

## Executar
```powershell
powershell -ExecutionPolicy Bypass -File .\tools\qualification\pp_integration_04_smoke.ps1 `
  -AtlasApiBase "http://localhost:3000/api/public/v1" `
  -PartilprovaBase "http://localhost:3001" `
  -EventSlug "3-maratona-natalina"
```

Sem `-ExpectedProvider`, o script valida apenas que o valor pertence ao contrato conhecido. Após conferir o modelo comercial no Atlas, execute novamente com `-ExpectedProvider "atlas"`, `"external"` ou `"unavailable"` conforme o contrato real.

## Importante
`provider=atlas` não significa necessariamente que as inscrições estão abertas; conferir também `registration.status`, destino, janela e serviço contratado `COR-INSC-001`. Nenhuma alteração de banco ou código Rails. O script é somente leitura.
