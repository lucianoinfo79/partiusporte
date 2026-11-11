# PP05.5 — Integração com Visualizador Protegido

## Escopo
- Mantém o lightbox na página de resultados da galeria e a navegação apenas entre as fotos da página corrente.
- Exibe o contexto da página e informa quando existem filtros aplicados.
- Reutiliza exclusivamente a URL de prévia protegida já renderizada pelo catálogo público; nenhuma rota nova, download ou acesso ao original.
- Melhora a navegação por teclado: foco inicial no botão de fechar, retorno ao cartão de origem ao encerrar e Escape nativo do dialog.
- Evita reset desnecessário da imagem quando a prévia já está carregada.

## Instalação
Extraia o ZIP na raiz do projeto PartilProva, preservando os caminhos relativos.

## Verificação (PowerShell)
```powershell
docker compose exec web bundle exec rails zeitwerk:check
docker compose exec web bundle exec rspec `
  spec/qualification/pp05_5_protected_viewer_qualification_spec.rb `
  spec/qualification/pp05_4_gallery_results_qualification_spec.rb `
  spec/qualification/pp05_3_gallery_filters_qualification_spec.rb `
  spec/qualification/pp05_2_bib_search_qualification_spec.rb `
  spec/requests/public_portal/pp04_4_photo_gallery_spec.rb
```

Sem migrations, gems ou alterações no Atlas. A qualificação no ambiente Docker do usuário ainda é necessária.
