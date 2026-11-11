# PP03.8 — Sincronização e Disponibilidade

## Escopo
- `AtlasApi::Availability`: verificação sob demanda, somente leitura, via `GET events?page=1&per_page=1`, com header para não utilizar cache compartilhado. Diferencia `available`, `unavailable` e `invalid_response`. Não publica URL interna ou mensagens de exceção.
- `Client`: geração configurável para chaves de cache de descoberta (`PARTILPROVA_PUBLIC_CACHE_GENERATION`), permitindo invalidação operacional sem varrer chaves. Mantém TTL máximo existente de 300 segundos e não habilita cache de fotos, resultados ou requisições com headers personalizados.
- Nenhum fallback com dados potencialmente despublicados. A publicação é autoridade do Atlas.

## Operação
- Para invalidar cache após alteração editorial, alterar `PARTILPROVA_PUBLIC_CACHE_GENERATION` (por exemplo `20261009a`) e reiniciar/reimplantar os processos PartilProva. Alternativamente manter cache desabilitado com `PARTILPROVA_PUBLIC_CACHE_ENABLED=false` até existir sincronização de eventos com autenticação e replay.
- `Availability.new.call` pode ser utilizado em console/monitoramento privado; **não** disponibilizar o diagnóstico detalhado como endpoint público sem autenticação e limitação de chamadas.
- Este patch **não** implementa webhook Atlas→PartilProva, invalidação instantânea, job recorrente, healthcheck HTTP público ou disponibilidade garantida. Essas integrações dependem de contrato de eventos e infraestrutura de implantação.

## Aplicação
Extrair na raiz do PartilProva. Não requer migration.

```powershell
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec web bundle exec rspec spec/services/partilprova/atlas_api/pp03_8_availability_spec.rb
docker compose exec web bundle exec rspec spec/requests/public_portal spec/services/partilprova spec/qualification
```

## Verificação manual
```powershell
docker compose exec web bundle exec rails runner 'result = Partilprova::AtlasApi::Availability.new.call; puts "state=#{result.state} http_status=#{result.http_status || "none"}"'
```
