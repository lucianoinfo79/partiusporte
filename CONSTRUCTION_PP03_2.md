# PP03.2 — Publicação de eventos — Contrato e consumer gate

## Alcance desta entrega
Somente PartilProva foi disponibilizado. Este ZIP **não implementa nem certifica** a política de publicação no Atlas.

- Novo `PublicationVisibility`: predicado de defesa complementar para decisões explícitas do Atlas.
- RSpec para decisões explícitas, payloads legados e independência de inscrições.
- Nenhuma rota, view, migration ou comportamento existente é alterado nesta entrega. O predicado não é ligado ao catálogo até o contrato produtor ser auditado, para não gerar falsa segurança.

## Contrato proposto para Atlas (a validar no projeto Atlas)
A API pública deve listar **apenas** edições autorizadas para divulgação; detalhes de edições não publicadas devem retornar 404 sem revelar metadados privados.

Definir no Atlas:
1. Estado explícito de publicação por Edition (rascunho/publicado/oculto), com permissões e trilha de auditoria.
2. Regras de elegibilidade: Edition existente, vínculo com evento, autorização para divulgação, dados mínimos, publicação ativa; inscrição aberta **não é requisito**.
3. `GET /api/public/v1/events`: filtro obrigatório server-side, inclusive destaque, filtros, paginação e contagem.
4. `GET /api/public/v1/events/:id`: 404 para não publicado, independente de ID ou slug.
5. Campos públicos: `id`, `slug`, `name`, `starts_at`, `city`, `state`, `modality`, `cover_url`, `registration_status`, `publication_status` (ou boolean explícito acordado).
6. Revogação deve afetar listagem, detalhe, sitemap e cache; não publicar informações de participantes, inscrições privadas ou links internos.
7. Validar no Atlas a relação Program → Event → Edition, políticas e serializadores reais antes de implementar qualquer migration.

## Aplicação
Extrair na raiz de `C:\partilprova`.

```powershell
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec web bundle exec rspec spec/services/partilprova/public_portal/pp03_2_publication_visibility_spec.rb
docker compose exec web bundle exec rspec spec/requests/public_portal spec/services/partilprova spec/qualification
```

## Aceite
Os testes acima podem qualificar apenas o **contrato complementar do consumidor**. A PP03.2 completa depende de implementação e testes de integração no Atlas com ZIP atualizado desse projeto.
