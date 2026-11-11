CORRECTION PP04.3.1.2 — Recuperacao Docker Compose

Extraia os dois arquivos na raiz C:\partilprova, apos backup dos arquivos atuais.
compose.yaml: restaurado do snapshot partilprova(20261009-004739).zip, com timeout da API Atlas em 30 segundos.
compose.override.yaml: ativa proxy de previews SOMENTE em desenvolvimento.

Comandos PowerShell:
cd C:\partilprova
Copy-Item .\compose.yaml .\compose.broken.backup.yaml -Force
# Extraia o ZIP sobrescrevendo compose.yaml
docker compose config --quiet
docker compose config | Select-String 'PP0431_LOCAL_PREVIEW_PROXY|ATLAS_PUBLIC_API_READ_TIMEOUT'
docker compose ps
# Somente se necessario apos config valido:
docker compose up -d --no-deps web
docker compose exec web printenv PP0431_LOCAL_PREVIEW_PROXY

NAO executar docker compose down -v nem remover volumes.
Nao levar compose.override.yaml para producao.
Confira credenciais locais antes de uso fora do ambiente de desenvolvimento.
