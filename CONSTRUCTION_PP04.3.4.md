# Correction PP04.3.4 — Prioridade de carregamento da primeira fotografia

## Escopo
Somente PartilProva. Substituir `app/views/public_portal/photos/show.html.erb`.

## Alterações
- Primeira fotografia: `loading="eager"` e `fetchpriority="high"`.
- Demais fotografias: mantêm `loading="lazy"`.
- Nenhuma mudança em proxy, API Atlas, CSS ou autorização.

## Instalação
Extraia o ZIP na raiz `C:\partilprova`, preservando os diretórios.

## Validação (PowerShell)
```powershell
cd C:\partilprova
docker compose exec web bundle exec rails runner 'puts ActionView::Template::Handlers::ERB.call(ActionView::Template.new(%q[test], %q[app/views/public_portal/photos/show.html.erb], ActionView::Template::Handlers::ERB, virtual_path: %q[test])).class'
```

Abra `http://localhost:3001/eventos/evento-oportunidade-teste/fotos` e aguarde o carregamento da primeira imagem. Se permanecer branco, inspecione o status e o tempo da requisição `/preview` na aba Rede do navegador. A alteração de prioridade não garante solução de erros de rede ou políticas de segurança do navegador.
