# Correction PP04.3.1.1 — Ativação do proxy local via Docker Compose

## Motivo
A rota `/eventos/:id/fotos/:photo_id/preview` e os testes da Correction PP04.3.1 já existem, mas `PP0431_LOCAL_PREVIEW_PROXY` não chega ao container `web`.

## Escopo incremental
Adiciona apenas `compose.override.yaml` na raiz do PartilProva. O Docker Compose mescla esse arquivo automaticamente com `compose.yaml` sem substituir o arquivo existente. Nenhum código Ruby, banco, migration ou segredo é alterado.

**Atenção:** este override habilita o proxy somente para desenvolvimento local. Não implante o arquivo em produção. Se já existir `compose.override.yaml`, **não o substitua**: adicione somente `PP0431_LOCAL_PREVIEW_PROXY: "true"` ao `services.web.environment` do override existente.

## Aplicação (PowerShell em C:\partilprova)

Extraia o ZIP na raiz do projeto.

```powershell
docker compose config --quiet
docker compose config | Select-String "PP0431_LOCAL_PREVIEW_PROXY"
docker compose up -d --force-recreate web
docker compose exec web printenv PP0431_LOCAL_PREVIEW_PROXY
```

A última linha deve mostrar `true`.

## Testes

```powershell
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec web bundle exec rspec `
  spec/services/partilprova/public_portal/pp04_3_1_preview_url_spec.rb `
  spec/requests/public_portal/pp02_9_photos_spec.rb
```

## Homologação visual

Abra `http://localhost:3001/eventos/evento-oportunidade-teste/fotos`.

No Network do navegador, a prévia deve vir de uma rota do PartilProva, não de `host.docker.internal`. Verifique a imagem e os cabeçalhos de cache. Não declare a homologação visual concluída sem observação no navegador.

## Reversão

Remova o arquivo `compose.override.yaml` **somente se ele foi criado por esta Correction**, e execute `docker compose up -d --force-recreate web`.
