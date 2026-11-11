# PP-INTEGRATION.03.1.1 — Correção do Contrato de Busca e Testes

Patch incremental para aplicar sobre PP-INTEGRATION.03.1.

- Home sem filtros: consulta destaques; se vazia, busca eventos publicados.
- Home com busca ou modalidade específica: consulta diretamente catálogo sem featured.
- Corrige expectativa desatualizada do teste.
- Remove redefinição da constante Response e acrescenta cenários de modalidade.

Não contém migrations nem alterações de configuração de banco.
Os testes requerem o banco partilprova_test já preparado, conforme spec/rails_helper.rb.
