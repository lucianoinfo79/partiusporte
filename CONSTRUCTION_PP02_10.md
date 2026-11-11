# PP02.10 — SEO, Sharing & Discoverability

ZIP incremental baseado no `partilprova(9).zip`.

Inclui:
- títulos e descrições SEO, Open Graph, Twitter Card e canonical sem query;
- SportsEvent JSON-LD na página individual da prova;
- noindex para filtros, páginas de resultados/fotos por prova e indisponibilidade;
- robots.txt e sitemap.xml com páginas públicas estáveis;
- **sem publicar URLs de provas no sitemap até existir um feed de eventos publicados no Atlas**;
- política fail-closed: sem host público HTTPS configurado, noindex e sitemap 404.

## Configuração obrigatória no ambiente do container web
`PARTILPROVA_PUBLIC_BASE_URL=https://partilprova.com.br`

Configure apenas quando o domínio estiver apontado para o ambiente público real. O sitemap é deliberadamente restrito a páginas estáveis e não lista provas que possam estar não publicadas.

## Comandos PowerShell
```powershell
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec web bundle exec rspec `
  spec/requests/public_portal/pp02_10_seo_spec.rb `
  spec/qualification/pp02_10_seo_sharing_discoverability_qualification_spec.rb
docker compose up -d --force-recreate web
```
Sem migrations ou alterações de gems.

## Pendente para o launch
- confirmar a base pública real e os cabeçalhos do proxy;
- sitemap dinâmico de eventos **somente após** contrato Atlas de eventos publicados;
- validar Open Graph em previews sociais e indexação em produção.
