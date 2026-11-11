# Construction PP03.7 — Integração Operacional das Fotos

## Escopo implementado (PartilProva)
- Compatibilidade com envelopes JSON `{data: {...}, meta: {...}}` da API Atlas.
- Bloqueio complementar de edições explicitamente não publicadas.
- Somente previews HTTPS; nunca fallback para `original_url` ou arquivos privados.
- Handoff do participante apenas para HTTPS e hosts configurados em `PARTILPROVA_PARTICIPANT_ALLOWED_HOSTS`.
- Preserva paginação, estados e interface existente; sem migrations.

## Dependência Atlas (ainda não implementada neste patch)
A rota `GET /api/public/v1/events/:identifier/photos` deve existir no Atlas e:
1. Resolver a edição publicada correta, sem expor edições privadas.
2. Retornar somente fotografias efetivamente publicadas e previews derivados/protegidos; nunca masters, fingerprints ou URLs de storage privado.
3. Responder 404 para evento inexistente/não público e diferenciar álbum ainda não publicado de álbum vazio.
4. Expor metadados de paginação, e links de handoff ao portal autenticado quando permitidos.
5. Impor autorização e proteção de entrega no servidor, não confiar no filtro do consumidor.

## Aplicação e testes (PowerShell)
Extraia na raiz C:\partilprova.

```powershell
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec web bundle exec rspec spec/services/partilprova/public_portal/pp03_7_operational_photos_spec.rb spec/services/partilprova/public_portal/photo_catalog_spec.rb
docker compose exec web bundle exec rspec spec/requests/public_portal spec/services/partilprova spec/qualification
```

O RSpec deve ser executado no ambiente Docker do projeto. A integração real depende do endpoint Atlas.
