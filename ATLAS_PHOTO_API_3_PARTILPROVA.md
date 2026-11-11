# ATLAS-PHOTO-API.3 — Gate PartilProva

Extraia na raiz de `C:\partilprova`.

```powershell
cd C:\partilprova
docker compose exec web bash script/atlas_photo_api_3_qualification.sh
```

Flags **permanecem desligadas por padrão**. Habilitar apenas após homologação real Atlas ↔ PartilProva: `PARTILPROVA_ATLAS_PHOTO_BIB_SEARCH=true` e `PARTILPROVA_ATLAS_PHOTO_GALLERY_FILTERS=true`. O gate não depende de credenciais reais nem ativa produção.
