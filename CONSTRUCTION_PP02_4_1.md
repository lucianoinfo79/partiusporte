# PP02.4.1 — Visual Parity Home

## Motivo
A captura funcional da PP02.4 mostrou o HTML correto, mas a camada visual nova
não estava sendo aplicada com a fidelidade esperada. O shell PP02.2 aparecia
estilizado enquanto hero, modalidades e estados da Home tinham aparência de HTML
parcialmente estilizado.

## Correção
- separa a camada visual da Home em `app/assets/stylesheets/pp02_4.css`;
- carrega esse asset explicitamente no layout público;
- reforça composição do hero, busca, cards de modalidade, grid de eventos,
  empty/unavailable state e CTA;
- mantém o contrato PP02.4 com Atlas totalmente inalterado;
- mantém responsividade desktop/tablet/mobile.

## Comandos
Não há migration, bundle, db:prepare.

```powershell
docker compose exec web bundle exec rails zeitwerk:check
```

```powershell
docker compose exec web bundle exec rspec `
  spec/qualification/pp02_4_1_visual_parity_home_qualification_spec.rb `
  spec/requests/public_portal/pp02_4_home_discovery_spec.rb `
  spec/qualification/pp02_4_home_discovery_qualification_spec.rb
```

Reinicie o web para eliminar qualquer asset antigo mantido pelo processo:

```powershell
docker compose restart web
```

Valide em `http://localhost:3001` e force recarga com `Ctrl+F5`.
