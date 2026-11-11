# PP-INTEGRATION.04.4.2 — Diagnóstico do `detail_state: not_found`

Este incremento **não altera** o fluxo de inscrições, os eventos ou as regras de segurança. Ele distingue `404` na API Atlas, rejeição por visibilidade, formato inesperado de payload e erro na normalização do detalhe. Não registra URLs completas, credenciais nem tokens.

## Instalação
Copie somente `partilprova/tools/qualification/pp_integration_04_4_2.rb` para a mesma pasta no projeto PartilProva.

## PowerShell
```
docker compose exec -e PP_EVENT_SLUG=3-maratona-natalina web bundle exec rails runner tools/qualification/pp_integration_04_4_2.rb
```

## Conferência independente
No navegador, verifique `http://localhost:3001/eventos/3-maratona-natalina`. Se a página abre mas o runner indica `not_found`, investigue diferenças entre o ambiente/configuração da aplicação web e o runner. A saída `api_status`, `visibility_accepted` e `detail_state` orienta a próxima correção.

Não execute migrations ou altere status de publicação para contornar um erro de diagnóstico.
