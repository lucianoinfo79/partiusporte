# PP03.6 — Integração Operacional dos Resultados

## Contrato auditado
Atlas `GET /api/public/v1/events/:slug/results` devolve `{data: [...], meta: {page, per_page, total}}` com `bib_number`, `athlete_name`, `category`, `net_seconds`, `gross_seconds`. A consulta Atlas v1 retorna apenas resultados `confirmed` de uma edição publicada e aceita `page` e `per_page`. A API **não implementa** `q` ou `category`; tampouco entrega posição/rank, estado editorial dos resultados, categorias disponíveis ou dados do evento neste endpoint.

## Mudanças
- Adaptar envelope `data` e tempos em segundos para HH:MM:SS, sem inventar posição.
- Preservar suporte aos formatos legados e estados 404/indisponível.
- Não enviar filtros não suportados; exibir aviso claro caso solicitados.
- Preservar segurança do Atlas: apenas ele decide quais resultados são públicos.

## Limites e próximos contratos
- Filtros por nome/peito/categoria exigem implementação no `EventResultsQuery` do Atlas antes de serem habilitados.
- A API não fornece ranking explícito; a coluna posição aparece como travessão.
- O retorno HTTP 200 com lista vazia não distingue 'sem resultados' de 'resultados não publicados'.
- A URL por slug seleciona a edição publicada resolvida pelo Atlas.
- Homologar contra Atlas em execução antes de encerrar a etapa.

## Aplicação e testes
Extrair na raiz `C:\partilprova`, preservando os caminhos.

```powershell
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec web bundle exec rspec spec/services/partilprova/public_portal/pp03_6_atlas_results_compatibility_spec.rb
docker compose exec web bundle exec rspec spec/requests/public_portal spec/services/partilprova spec/qualification
```

Sem migrations.
