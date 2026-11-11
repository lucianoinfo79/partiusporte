# PP-INTEGRATION.03.2 — Padronização Visual dos Cards e Navegação

- Partial compartilhado `public_portal/events/_card.html.erb` para Home e Catálogo.
- Link de título e CTA apontam para a mesma rota pública `/eventos/:id`, com preferência pelo slug.
- Placeholder PartilProva quando capa ausente ou URL não HTTP(S).
- Cards responsivos com mesma estrutura e dimensões em ambas as páginas.
- Testes de view cobrindo slug, id e URL de imagem inválida.

Sem migrations ou mudanças em credenciais. Aplicar sobre PP-INTEGRATION.03.1.1.
