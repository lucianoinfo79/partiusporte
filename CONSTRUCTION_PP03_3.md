# PP03.3 — Catálogo Operacional

## Escopo
Integra o filtro defensivo `PublicationVisibility` ao catálogo real, preservando a autoridade de publicação do Atlas. Mantém edições publicadas mesmo com inscrições encerradas; impede a exibição de registros explicitamente privados. Não usa o campo genérico `status` como status de inscrição. Mantém paginação e filtros repassados à API.

**Limite:** o Atlas deve filtrar a publicação antes da paginação e do cálculo de `meta.total`; o filtro local é apenas defesa complementar. Registros legados sem campos editoriais explícitos continuam compatíveis. A integração em ambiente real permanece pendente.

## Aplicação
Extraia este ZIP na raiz C:\partilprova, sobrescrevendo os arquivos listados. Sem migrations.

```powershell
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec web bundle exec rspec spec/services/partilprova/public_portal/pp03_3_operational_catalog_spec.rb
docker compose exec web bundle exec rspec spec/requests/public_portal spec/services/partilprova spec/qualification
```
