$ErrorActionPreference = 'Stop'
$path = Join-Path (Get-Location) 'public/robots.txt'
if (Test-Path -LiteralPath $path -PathType Leaf) {
  Remove-Item -LiteralPath $path -Force
  Write-Host 'Removido public/robots.txt (arquivo padrao que interceptava a rota dinamica).'
} else {
  Write-Host 'public/robots.txt ja esta ausente; nenhuma alteracao necessaria.'
}
