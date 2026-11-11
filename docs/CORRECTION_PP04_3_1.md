# Correction PP04.3.1 — Compatibilidade de URLs e Renderização Segura

## Objetivo
O Atlas responde 200 e entrega JPEG protegido; o catálogo PartilProva descarta a URL HTTP. A correção preserva HTTPS em produção e oferece um proxy local **somente em desenvolvimento e com opt-in**.

## Arquivos
- `app/services/partilprova/public_portal/photo_catalog.rb`
- `app/controllers/public_portal/photos_controller.rb`
- `config/routes.rb`
- `spec/services/partilprova/public_portal/pp04_3_1_preview_url_spec.rb`

## Aplicação
Extrair sobre `C:\partilprova`, mantendo cópia de segurança dos arquivos alterados. **Atenção**: base analisada foi o snapshot `partilprova(20261009-004739).zip`; se houver mudanças posteriores nesses arquivos, mesclar em vez de sobrescrever.

## Configuração de desenvolvimento
Adicionar no serviço `web` do Compose do PartilProva:
`PP0431_LOCAL_PREVIEW_PROXY: "true"`

Recriar o serviço: `docker compose up -d --force-recreate web`.
A origem da API deve permanecer `ATLAS_PUBLIC_API_BASE_URL=http://host.docker.internal:3000/api/public/v1`.
**Nunca habilitar em produção.** Em produção configurar URL pública HTTPS para o Atlas e seus links assinados.

## Comandos
```powershell
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec web bundle exec rails routes -g local_public_event_photo_preview
docker compose exec web bundle exec rspec spec/services/partilprova/public_portal/photo_catalog_spec.rb spec/services/partilprova/public_portal/pp04_3_1_preview_url_spec.rb spec/requests/public_portal/pp02_9_photos_spec.rb
```

Acessar `/eventos/evento-oportunidade-teste/fotos` na porta do PartilProva. Confirmar no Network que o `img` usa a rota local e retorna JPEG 200; conferir que não há `token=` no HTML. Reexecutar o script PP04.3 separadamente: seu 404 anterior ainda precisa ser diagnosticado; este patch não o altera.

## Limites
O proxy de desenvolvimento consulta a primeira página da galeria para confirmar elegibilidade; fotos de páginas posteriores não serão atendidas por essa rota nesta versão. O teste visual, os tokens adulterados/expirados e o gate HTTP completo permanecem pendentes. O proxy não deve ser usado como CDN ou mecanismo de produção.
