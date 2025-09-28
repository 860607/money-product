# svg2png.ps1  — Convertit les SVG marketing/facebook/images en PNG aux bons formats
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$imgDir = Join-Path $PWD "marketing\facebook\images"
if(!(Test-Path $imgDir)){ throw "Dossier introuvable: $imgDir" }

# Détection convertisseur
function Test-Tool($name){ $null -ne (Get-Command $name -ErrorAction SilentlyContinue) }
$hasMagick  = Test-Tool "magick"
$hasInkscape= Test-Tool "inkscape"

if(-not ($hasMagick -or $hasInkscape)){
  Write-Error "Aucun convertisseur trouvé. Installe ImageMagick (winget install ImageMagick.ImageMagick) ou Inkscape."
  exit 1
}

# Mapping tailles cibles
$targets = @(
  @{ in="profil_1024.svg";          out="profil_1024.png";          w=1024; h=1024 },
  @{ in="couverture_1640x856.svg";  out="couverture_1640x856.png";  w=1640; h=856  },
  @{ in="visuel_post.svg";           out="visuel_post.png";          w=1080; h=1080 },
  @{ in="visuel_carrousel_1.svg";    out="visuel_carrousel_1.png";   w=1080; h=1080 },
  @{ in="visuel_carrousel_2.svg";    out="visuel_carrousel_2.png";   w=1080; h=1080 },
  @{ in="visuel_carrousel_3.svg";    out="visuel_carrousel_3.png";   w=1080; h=1080 }
)

# Convertisseur générique
function Convert-One($src,$dst,$w,$h){
  if($hasMagick){
    # ImageMagick
    & magick -background none "$src" -resize "${w}x${h}" -density 300 -quality 100 "$dst"
  }elseif($hasInkscape){
    # Inkscape
    & inkscape "$src" --export-type=png --export-filename="$dst" --export-width=$w --export-height=$h
  }
}

# Conversion
Write-Host "Conversion SVG -> PNG dans $imgDir`n" -ForegroundColor Cyan
foreach($t in $targets){
  $src = Join-Path $imgDir $t.in
  $dst = Join-Path $imgDir $t.out
  if(Test-Path $src){
    Write-Host ("- {0} => {1} ({2}x{3})" -f $t.in,$t.out,$t.w,$t.h)
    Convert-One $src $dst $t.w $t.h
  }else{
    Write-Warning "Fichier manquant: $($t.in)"
  }
}

# Listing final
"`nFichiers PNG générés :" | Write-Host -ForegroundColor Green
Get-ChildItem $imgDir -Filter *.png | Select-Object Name,Length,LastWriteTime | Format-Table -Auto
