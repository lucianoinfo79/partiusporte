# Correction PP05.6.1 — Gallery Legacy Regression

Atualiza somente as expectativas do teste legado PP04.5 para os estados da interface PP05.4.
Preserva os testes de previews protegidos, lightbox, paginação e 404.

## Instalação
Extrair o ZIP na raiz de C:\partilprova preservando a estrutura.

## Comandos (PowerShell)
```powershell
cd C:\partilprova
docker compose exec web bash script/pp05_6_qualification.sh
docker compose exec web bundle exec rails zeitwerk:check
```

Sem migrations ou assets. Testes não executados no Docker neste ambiente.
