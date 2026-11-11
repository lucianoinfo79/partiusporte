# PP02.2 — Design System & Public Shell

## Objetivo
Implementar a fundação visual aprovada do PartilProva sem antecipar a Home funcional da PP02.4.

## Entregue
- tokens CSS PartilProva;
- shell público com header sticky e footer;
- navegação Eventos / Calendário / Resultados / Fotos / Sobre / Contato;
- ações Entrar / Criar conta como placeholders visuais;
- menu responsivo mobile;
- acessibilidade básica (skip link, foco, labels, reduced motion);
- botões, badges, busca e card de evento reutilizáveis;
- vitrine temporária de qualificação visual na raiz;
- specs de request e qualification.

## Limite de escopo
A Home definitiva, dados reais, catálogo, calendário, resultados e fotos não são implementados aqui. Eles entram nas constructions específicas do roadmap.

## Aplicação
Extrair este ZIP na raiz `C:\partilprova`, substituindo os arquivos.

## Comandos
Não há migration, bundle install ou db:prepare.

```powershell
docker compose exec web bundle exec rails zeitwerk:check

docker compose exec web bundle exec rspec `
  spec/requests/public_portal/home_spec.rb `
  spec/requests/public_portal/pp02_2_public_shell_spec.rb `
  spec/qualification/pp02_1_project_bootstrap_architecture_qualification_spec.rb `
  spec/qualification/pp02_2_design_system_public_shell_qualification_spec.rb
```

Meta: 8 examples, 0 failures (considerando os specs PP02.1 existentes com a contagem atual).

Validação visual:
`http://localhost:3001`

Se CSS antigo permanecer no navegador, use Ctrl+F5.
