# Correction PP04.3.3 — Proxy local de previews

## Alteração
Corrige `NoMethodError: undefined method 'headers' for Net::HTTPOK` em `PublicPortal::PhotosController#local_preview`.

O objeto da resposta upstream foi renomeado para `upstream_response` para evitar confusão com a resposta Rails. Os cabeçalhos de segurança são aplicados via `self.response.headers`, mantendo `private, no-store` e `nosniff`.

## Instalação
Extraia o ZIP em `C:\partilprova` preservando as pastas e confirme a substituição do controlador.

## Verificação (PowerShell)
```powershell
cd C:\partilprova
docker compose exec web ruby -c app/controllers/public_portal/photos_controller.rb
```

Abra ou atualize:
`http://localhost:3001/eventos/evento-oportunidade-teste/fotos`

A imagem deve carregar caso a API Atlas e o preview assinado permaneçam disponíveis. Nenhuma migration ou alteração no Atlas é necessária.
