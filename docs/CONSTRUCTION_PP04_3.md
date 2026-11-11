# PP04.3 — Homologação HTTP e Visual da Galeria

## Instalação

Pacote incremental para **PartilProva**, não para Atlas. Extraia na raiz `C:\partilprova`. Nenhuma migration, alteração de modelo ou publicação é executada. Baseado no Atlas `atlas(20261010-003503).zip` e PartilProva `partilprova(20261009-004739).zip`.

## Execução (PowerShell)

No `C:\partilprova`, com Atlas e PartilProva em execução:

```powershell
docker compose exec web ruby -c script/pp04_3_gallery_http_probe.rb

docker compose exec `
  -e PP043_ATLAS_ORIGIN=http://host.docker.internal:3000 `
  -e PP043_PORTAL_ORIGIN=http://localhost:3000 `
  web ruby script/pp04_3_gallery_http_probe.rb evento-oportunidade-teste
```

Se as aplicações usam portas distintas, substitua as duas origens por endereços **acessíveis a partir do container do PartilProva**. `PP043_ATLAS_ORIGIN` é a origem da aplicação Atlas (sem `/api/public/v1`). `PP043_PORTAL_ORIGIN` é a origem do PartilProva.

## Interpretação

- `PASS`: comportamento confirmado por HTTP.
- `PENDING`: etapa que requer HTTPS real, navegador ou serviço acessível; não significa sucesso.
- `FAIL`: violação do contrato HTTP esperado. Exit code 1; PENDING sem FAIL gera exit code 2; tudo PASS gera 0.

O probe valida envelope da galeria, existência de foto, cache-control, campos privados, host da prévia, download real e assinatura da imagem, ausência de token, token adulterado, página PartilProva e presença da imagem no HTML. Não imprime token nem URL assinada.

**Importante:** o `PhotoCatalog` atual do PartilProva só aceita `https://` para `preview_url`. Em desenvolvimento, a API Atlas gera URLs conforme o protocolo da requisição, normalmente `http://`. O diagnóstico apontará `preview_https_browser=PENDING` e possivelmente `portal_image_markup=PENDING` nesse cenário. Não desabilite o filtro HTTPS; a homologação positiva exige origem HTTPS acessível pelo navegador, por exemplo um reverse proxy de desenvolvimento com certificado confiável.

## Validação visual manual

Abra `http://localhost:3000/eventos/evento-oportunidade-teste/fotos` no navegador (ajuste a porta). Com o ambiente HTTPS configurado, confirme: uma imagem visível, sem ícone quebrado; marca d'água aplicada; responsividade desktop/mobile; navegação; sem acesso ao original; aba Network mostra GET de imagem com HTTP 200, `Content-Type: image/jpeg`, `Cache-Control: private, no-store`; URL assinada expira em aproximadamente 5 minutos. Não compartilhe o token em logs públicos ou screenshots.

## Gate final

Somente declare PP04.3 concluída quando: checks HTTP sem FAIL/PENDING, visual aprovado e prévia expirada rejeitada. A verificação de expiração não é automatizada por este script, pois exige aguardar o TTL. Se houver incompatibilidade de protocolo, resolver a infraestrutura HTTPS antes de encerrar o gate.
