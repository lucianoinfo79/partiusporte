# PP05.6 — Qualification & Regression Gate

## Entrega
- Gate de regressão HTTP para busca, filtros, paginação, visualizador e estados da galeria.
- Script de qualificação combinada com os testes PP04/PP05 existentes e Zeitwerk.
- Sem alterações no código de produção, migrations, assets ou dependências.

## Instalação
Extraia este ZIP na raiz de `C:\partilprova`, preservando a estrutura dos diretórios.

## Execução (PowerShell)
```powershell
docker compose exec web bash script/pp05_6_qualification.sh
```

## Critérios
- Zeitwerk sem erros e todos os exemplos RSpec aprovados.
- Flags `PARTILPROVA_ATLAS_PHOTO_BIB_SEARCH` e `PARTILPROVA_ATLAS_PHOTO_GALLERY_FILTERS` devem permanecer desabilitadas até a API Atlas implementar e qualificar filtros reais.
- Testes de request utilizam mocks do catálogo; **não homologam a integração real com Atlas**.
- Validar manualmente no navegador os previews protegidos, navegação por teclado e estados de erro.

## Observação
O comando exige que o contêiner `web` tenha `bash` disponível. Alternativa: executar diretamente os comandos dentro do script com `docker compose exec web`.
