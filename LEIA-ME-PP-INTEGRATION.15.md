# PP-INTEGRATION.15 — Conteúdo público de eventos

## O que foi implementado

- Editor por edição no workspace esportivo, no menu **Conteúdo público**.
- Seções editáveis: Sobre, Programação, Kit do atleta e Regulamento.
- Percursos e distâncias vêm das provas com status **Ativa** já cadastradas na edição.
- Capa anexada ao Atlas como arquivo JPG, PNG ou WebP, até 10 MB.
- Regulamento anexado ao Atlas como PDF, até 20 MB.
- Os arquivos de rascunho e publicados têm anexos separados. Trocar um arquivo no rascunho não altera o arquivo que já está publicado; a troca passa ao site somente ao publicar.
- A API pública fornece URLs servidas pelo próprio Atlas para os anexos publicados. Nenhuma URL de hospedagem externa é cadastrada.
- Salvar rascunho não altera o conteúdo publicado. **Publicar conteúdo** grava uma cópia publicada independente do rascunho.

## Aplicação no Atlas

Extraia o ZIP incremental sobre a raiz do projeto Atlas, preservando os caminhos. As tabelas do Active Storage já fazem parte do projeto. Aplique as migrations:

```bash
docker compose exec web bundle exec rails db:migrate
```

O usuário precisa de acesso de escrita à edição/evento para salvar e publicar.

## Aplicação no partiusporte

Extraia o ZIP incremental sobre a raiz do projeto partiusporte. A alteração atualiza a apresentação de distância, modalidade e descrição dos percursos na página pública.

## Contrato público

A API de detalhe continua usando os campos consumidos pelo site:

- `description`: texto da seção Sobre.
- `distances`: provas ativas e suas distâncias/modalidades.
- `routes`: nome do percurso, distância e descrição, quando cadastrados.
- `schedule`: lista de objetos com `time` e `title` (até 30 itens).
- `kit_description`, `regulation_url` e `cover_url`: os dois últimos são URLs de acesso aos arquivos anexados e servidos pelo Atlas.

A publicação editorial é independente do estado de publicação do catálogo da edição. A página pública continua sujeita às regras atuais de visibilidade do catálogo.

## Comandos de teste

Estes testes existentes cobrem o contrato do detalhe e sua exibição. **Não foram executados nesta preparação.** Rode no Atlas:

```bash
docker compose exec -e RAILS_ENV=test web bundle exec rspec \
  spec/requests/api/public/v1/event_detail_spec.rb \
  spec/services/atlas/public_api/v1/event_detail_serializer_spec.rb \
  spec/qualification/pp01_4_event_detail_api_qualification_spec.rb
```

E no partiusporte:

```powershell
docker compose exec -e RAILS_ENV=test web bundle exec rspec `
  spec/requests/public_portal/pp02_6_event_detail_spec.rb `
  spec/services/partilprova/public_portal/event_detail_spec.rb `
  spec/qualification/pp02_6_event_detail_qualification_spec.rb
```
