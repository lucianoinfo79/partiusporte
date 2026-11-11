# Correction PP02.10.2 — conflito de robots.txt estatico

O Rails serve `public/robots.txt` antes de encaminhar `/robots.txt` ao controller. O projeto contem o arquivo padrao do Rails, que prevalece sobre a rota PP02.10.

## Aplicacao (PowerShell, na raiz C:\partilprova)

```powershell
.\APPLY_PP02_10_2.ps1
# Alternativa direta: Remove-Item .\public\robots.txt -Force

docker compose exec web bundle exec rspec `
  spec/requests/public_portal/pp02_10_seo_spec.rb `
  spec/qualification/pp02_10_seo_sharing_discoverability_qualification_spec.rb
```

Se o script estiver bloqueado pela politica de execucao, use o comando `Remove-Item` diretamente. Nao precisa migration nem reiniciar o container em ambiente de desenvolvimento, salvo se o arquivo estiver em imagem Docker em vez de volume montado.

Em deploy, garanta que `public/robots.txt` nao seja recriado pela imagem ou pipeline.
