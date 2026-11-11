# PP04.4 — Experiência da Galeria de Fotografias

Base: partilprova(20261010-013633).zip.

## Escopo
- Abrir a prévia protegida em visualizador modal (sem acesso ao original).
- Navegar entre fotografias da página com botões e setas do teclado.
- Fechar com Escape, botão ou clique no fundo.
- Indicador de posição, estado de carregamento e erro de imagem.
- Manter identificação do fotógrafo, paginação e handoff existentes.
- A primeira fotografia continua eager; as demais continuam lazy.
- Nenhuma alteração no Atlas, Docker, banco ou rotas.

## Instalação (PowerShell)
Extrair a pasta `partilprova/` do ZIP sobre `C:\partilprova\`, preservando a estrutura e substituindo os arquivos correspondentes.

```powershell
cd C:\partilprova
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec web bundle exec rspec spec/requests/public_portal/pp04_4_photo_gallery_spec.rb spec/requests/public_portal/pp02_9_photos_spec.rb
```

Abra http://localhost:3001/eventos/evento-oportunidade-teste/fotos e clique na fotografia. Teste setas, Escape e responsividade.

## Observações
- Não foi possível executar RSpec contra o Docker local do usuário neste ambiente.
- Os previews continuam sendo URLs do catálogo, sem incorporar tokens novos.
- O desempenho do proxy (~16 s por preview observado anteriormente) permanece uma pendência independente.
