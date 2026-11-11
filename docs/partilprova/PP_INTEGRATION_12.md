# PP-INTEGRATION.12 — Gate de regressão da jornada PartilProva → Atlas

## Objetivo

Proteger o encaminhamento da página pública de evento para a inscrição do Atlas e preservar o comportamento de destinos externos e inscrições indisponíveis.

O gate é somente de regressão. Ele não chama o Atlas, o Mercado Pago, não cria inscrições e não altera dados financeiros.

## Teste PartilProva

O request spec `spec/qualification/pp_integration_12_registration_journey_gate_spec.rb` substitui a consulta de detalhes por dados locais e verifica que:

- o CTA do Atlas usa a origem pública confiável e abre na mesma aba;
- um destino externo abre em nova aba com `noopener noreferrer`;
- quando a inscrição está indisponível, o CTA não é renderizado.

## Aplicação e comandos (Windows PowerShell)

Extraia o ZIP na raiz do repositório PartilProva e execute:

```powershell
docker compose exec web bundle exec rspec `
  spec/qualification/pp_integration_12_registration_journey_gate_spec.rb `
  spec/requests/public_portal/pp02_6_event_detail_spec.rb `
  spec/services/partilprova/public_portal/pp_integration_04_4_registration_handoff_spec.rb

docker compose exec web bundle exec rails zeitwerk:check
```

## Critério de aceite

O gate passa quando os dois comandos terminam sem falhas, incluindo `zeitwerk:check`. A execução local desta entrega não foi possível porque o ambiente de preparação não tem Docker nem Ruby instalado; execute os comandos no ambiente PartilProva e registre os resultados para concluir a qualificação.
