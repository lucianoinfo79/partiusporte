# PP-INTEGRATION.10.6 — Orders no checkout público em homologação

Base Atlas: atlas(20261030-213819).zip + 10.5-B + 10.5-B.1. Base PartilProva consultada: partilprova(3).zip, de 26/10/2026. O incremental PartilProva adiciona apenas testes, sem substituir seu código funcional.

## Resultado implementado

PartilProva mantém o link confiável de inscrição fornecido pelo Atlas. O participante cria sua inscrição no fluxo público, aceita os termos, escolhe PIX e aciona Simular pagamento PIX na tela de checkout existente. O Atlas cria uma Orders de teste APRO pelo valor do pedido, consulta a resposta e recebe o webhook para confirmar pedido/pagamento/inscrições. Nenhum segredo passa pelo PartilProva ou navegador.

É homologação: produção bloqueada, edição publicada explicitamente ativada, limite de R$50 por pedido, uma tentativa por pedido, sem transferência bancária. A simulação aparece claramente identificada na tela existente, usando seus componentes e estilos. QR/copia e cola de transferência não são exibidos para essa simulação. Não é ativação do Orders em produção.

OrdersTestIntegration da 10.5-B é reutilizado para idempotência, locks, claim antes do POST, validação completa do GET, identidade financeira e confirmação transacional. O novo gateway aplica escopo por edição, mantendo credencial e segredo separados de Payments. A autorização é específica da nova configuração TEST; a autorização legada Payments permanece intacta. Sem configuração válida, não há emissão Orders no checkout.

A configuração criptografada da 10.6 importa a credencial Orders e o segredo já qualificados na 10.5-B, sem alterar aquele arquivo nem o token global. tmp/qualification/pp106/public_orders_test.enc é persistente, criado uma única vez. Não apagar para resetar tentativas, não versionar ou distribuir. Preservar segredo Rails e o volume. Todas as operações novas exigem Rails development/test. Despublicar a edição bloqueia novas emissões, preservando conciliação de pagamentos já emitidos.

O novo webhook consulta uma vez para localizar a referência local e outra vez pelo conciliador qualificado para validar e liquidar. GETs de páginas públicas não emitem nem consultam o provedor: Atualizar situação recarrega o estado local. O runner sync é a alternativa operacional para perda de webhook; ele não emite.

## Aplicar no Atlas (WSL/bash)

```bash
cd ~/projetos/atlas
unzip -o ~/Downloads/PP-INTEGRATION.10.6-Atlas.zip -d .
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec -e RAILS_ENV=test web bundle exec rspec \
  spec/qualification/pp_integration_10_6_public_orders_spec.rb \
  spec/qualification/pp_integration_10_5_b_orders_spec.rb \
  spec/qualification/pp_integration_10_5_b1_cancel_legacy_spec.rb \
  spec/requests/pp_integration_08_5_4_financial_checkout_e2e_spec.rb \
  spec/services/atlas/payments/mercado_pago/synchronize_payment_spec.rb
```

Sem migração e sem alteração de assets. config/routes.rb está completo no incremental. Faça backup/versionamento antes de extrair se houve alterações locais nesses arquivos após a base.

## PartilProva (PowerShell)

Extraia o ZIP PartilProva na raiz do projeto:

```powershell
Set-Location C:\partilprova
Expand-Archive -Path "$HOME\Downloads\PP-INTEGRATION.10.6-PartilProva.zip" -DestinationPath . -Force
docker compose exec web bundle exec rspec `
  spec/qualification/pp_integration_10_6_orders_handoff_spec.rb `
  spec/services/partilprova/public_portal/pp_integration_04_4_registration_handoff_spec.rb
```

A origem pública e os hosts confiáveis já configurados no PartilProva continuam necessários. O destino deve ser o Atlas acessível no navegador, não um nome interno Docker. Se Inscreva-se agora não aparecer, diagnosticar a publicação, janela de inscrição e destino confiável; não contornar o portal usando um link direto para declarar E2E concluído.

## Ativar no Atlas

Após os testes passarem:

```bash
docker compose exec -e PP106_MODE=activate web bundle exec rails runner \
  script/qualification/pp_integration_10_6_public_orders.rb
docker compose restart web
```

Por padrão seleciona a edição do pedido 7 já qualificado, e exige que esteja publicada. Não altera o pedido 7, o pagamento 8 ou a inscrição 37. Para escolher outra edição antes da primeira ativação, usar -e PP106_EDITION_ID=ID_DA_EDICAO. Não há emissão no comando activate.

Na aplicação Orders em Teste, mantenha Order (Mercado Pago) selecionado e atualize a URL para o túnel atual seguido de:

`/webhooks/mercado_pago_orders_public_test`

Para o túnel usado na 10.5:
https://candle-relieve-upturned.ngrok-free.dev/webhooks/mercado_pago_orders_public_test

Mantenha a mesma assinatura secreta já configurada. Não a regenere: o arquivo da 10.6 reutiliza a assinatura da 10.5-B. O endpoint anterior continua no código, mas a qualificação do novo fluxo deve usar o endpoint público acima.

## Execução ponta a ponta real

1. Abra o evento publicado no PartilProva e clique Inscreva-se agora.
2. No Atlas, faça uma nova inscrição de homologação na edição ativada, usando um participante de teste sem pedido conflitante. A inscrição 37 já paga não será reutilizada.
3. Selecione itens cujo total esteja entre R$0,01 e R$50, aceite os termos e escolha PIX. Pedidos sem cobrança seguem o fluxo gratuito existente.
4. Na tela existente, confira o aviso PIX de homologação e clique uma vez em Simular pagamento PIX.
5. Aguarde o webhook; use Atualizar situação do pagamento para recarregar a página. O resultado esperado é Pagamento de teste confirmado, pedido paid e inscrição active/paid.
6. No ngrok/painel, registre action=order.processed, data.id da nova order e HTTP 200 no novo endpoint. Não enviar assinatura, token de acesso ao pedido, QR ou credenciais.

## Auditoria e recuperação

Use o ID interno do novo pedido observado no Atlas:

```bash
docker compose exec -e PP106_ORDER_ID=ID_DO_NOVO_PEDIDO web bundle exec rails runner \
  script/qualification/pp_integration_10_6_public_orders.rb
```

Se o webhook não confirmar, consulte com GET autenticado:

```bash
docker compose exec -e PP106_MODE=sync -e PP106_ORDER_ID=ID_DO_NOVO_PEDIDO \
  web bundle exec rails runner script/qualification/pp_integration_10_6_public_orders.rb
```

Se a emissão teve resposta perdida, é necessário recuperar no provedor a order exata vinculada à referência local; sync aceita PP106_RECOVER_ORDER_ID quando o identificador ainda não está gravado. Não gerar outra order, apagar metadata ou cancelar localmente para repetir. Sem ID conhecido, preservar o bloqueio para investigação. Resultado pending, timeout e HTTP 4xx nunca liberam novo POST automaticamente.

Para fechar a qualificação do caminho webhook, primeiro colher sua entrega e o estado local confirmado; usar sync antes disso permite recuperação, mas pode impedir atribuir a confirmação exclusivamente ao webhook.

## Evidências e limites

Guardar a sequência PartilProva → inscrição Atlas → checkout público; novos IDs de pedido/pagamento/inscrição; order e referência correlacionadas; status final; webhook 200; repetição de consulta sem duplicação. O E2E real depende da execução no ambiente do usuário.

Validação aqui: sintaxe dos sete arquivos Ruby modificados/adicionados entre os dois projetos aprovada em Ruby 3.2. A suíte Rails/PostgreSQL, renderização visual clara/escura e operação real com o provedor ainda precisam ser executadas no ambiente Docker. O contrato financeiro de base foi qualificado na 10.5; isso não substitui qualificar este novo caminho público. Nenhuma chamada financeira feita na preparação.

Etapa atual: implementação entregue. Pendências: testes nos dois projetos; ativação e configuração do webhook; E2E real e evidências de interface. Não declarar 10.6 concluída antes dessas evidências. A próxima Construction será definida pelos resultados desse gate, sem habilitar produção.
