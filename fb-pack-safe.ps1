# fb-pack-safe.ps1 - ASCII only to avoid encoding issues
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

# ===== PARAMETERS (edit these) =====
$PRICE     = '14,90 EUR'
$PAY_URL   = 'https://exemple-de-paiement.com/ton-produit'  # <-- put your real payment link
$SITE_URL  = 'https://860607.github.io/money-product/'
$SITE_NAME = 'Guide Pratique - Devenir Freelance'
$BRAND     = 'Devenir Freelance - Guide'
# ===================================

# FOLDERS
$mk  = Join-Path $PWD 'marketing'
$fb  = Join-Path $mk  'facebook'
$img = Join-Path $fb  'images'
New-Item -ItemType Directory -Force -Path $mk,$fb,$img | Out-Null

# ---------------- 1) TEXTS ----------------
$bio = @'
{BRAND}
Mini-guide pratique pour decrocher vos 1ers clients en 7 jours.
Scripts email/DM + checklists. Prix : {PRICE}.
{SITE_URL}
'@
$bio = $bio.Replace('{BRAND}',$BRAND).Replace('{PRICE}',$PRICE).Replace('{SITE_URL}',$SITE_URL)
$bio | Set-Content (Join-Path $fb 'bio.txt') -Encoding UTF8

$about = @'
Mini-guide pratique : methode simple en 7 jours pour vous lancer en freelance.
- Positionnement express
- Offre claire
- Scripts d email/DM
- Checklists
Apercu et achat : {SITE_URL}
'@
$about = $about.Replace('{SITE_URL}',$SITE_URL)
$about | Set-Content (Join-Path $fb 'a-propos.txt') -Encoding UTF8

$dm = @'
Merci pour votre message !
Apercu gratuit : {SITE_URL}preview.html?utm_source=fb-dm
Page produit : {SITE_URL}?utm_source=fb-dm
'@
$dm = $dm.Replace('{SITE_URL}',$SITE_URL)
$dm | Set-Content (Join-Path $fb 'reponse_instantanee_dm.txt') -Encoding UTF8

$pinned = @'
NOUVEAU - {BRAND} ({PRICE})

Methode simple en 7 jours pour decrocher vos 1ers clients :
- Positionnement express
- Scripts prets a l emploi (email/DM)
- Checklists et routine

Apercu gratuit : {SITE_URL}preview.html?utm_source=facebook-pinned
Acheter : {SITE_URL}?utm_source=facebook-pinned-cta
'@
$pinned = $pinned.Replace('{BRAND}',$BRAND).Replace('{PRICE}',$PRICE).Replace('{SITE_URL}',$SITE_URL)

$pinned | Set-Content (Join-Path $fb 'post_epingle.txt') -Encoding UTF8

# 7 posts courts
$tpl = @(
'J1 - 7 erreurs quand on debute en freelance. Apercu : {URL}preview.html?utm_source=facebook-j1',
'J2 - Script de DM qui ouvre des portes. Apercu : {URL}preview.html?utm_source=facebook-j2',
'J3 - Routine 7 jours : 30 min/jour. Apercu : {URL}preview.html?utm_source=facebook-j3',
'J4 - Offre irresistible : structure 3 points. Apercu : {URL}preview.html?utm_source=facebook-j4',
'J5 - Appel decouverte : deroule 20 min. Apercu : {URL}preview.html?utm_source=facebook-j5',
'J6 - Proposition et closing : simple. Apercu : {URL}preview.html?utm_source=facebook-j6',
'J7 - Bonus lancement : {PRICE}. Page : {URL}?utm_source=facebook-j7'
)
for($i=0;$i -lt $tpl.Count;$i++){
  $t = $tpl[$i].Replace('{URL}',$SITE_URL).Replace('{PRICE}',$PRICE)
  $fn = Join-Path $fb ("post_j{0}.txt" -f ($i+1))
  $t | Set-Content $fn -Encoding UTF8
}

# Planning CSV (J+1..J+7 a 10:00)
$rows = @("date;heure;fichier_post;image_suggeree")
$today = Get-Date
for($i=0;$i -lt 7;$i++){
  $d = $today.AddDays($i+1).ToString("yyyy-MM-dd")
  $postFile = "post_j{0}.txt" -f ($i+1)
  $imgName  = if($i -in 0,3,6) { "visuel_carrousel_1.svg" } else { "visuel_post.svg" }
  $rows += "$d;10:00;$postFile;$imgName"
}
$rows | Set-Content (Join-Path $fb 'planning_posts.csv') -Encoding UTF8

# ---------------- 2) IMAGES SVG (ASCII) ----------------
# Profil 1024
$svgProfil = @'
<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">
  <rect width="1024" height="1024" fill="#0f1720"/>
  <circle cx="512" cy="512" r="340" fill="#2563eb" opacity=".18"/>
  <text x="512" y="540" text-anchor="middle" font-family="Arial, sans-serif" font-size="92" fill="#e6eef8">Devenir Freelance</text>
  <text x="512" y="640" text-anchor="middle" font-family="Arial, sans-serif" font-size="48" fill="#a9b9d4">Guide pratique</text>
</svg>
'@
$svgProfil | Set-Content (Join-Path $img 'profil_1024.svg') -Encoding UTF8

# Couverture 1640x856
$svgCover = @'
<svg xmlns="http://www.w3.org/2000/svg" width="1640" height="856" viewBox="0 0 1640 856">
  <rect width="1640" height="856" fill="#0f1720"/>
  <rect x="60" y="120" width="830" height="320" rx="24" fill="#101a2a" stroke="#233452"/>
  <text x="100" y="240" font-family="Arial, sans-serif" font-size="72" fill="#e6eef8">Guide Pratique - Devenir Freelance</text>
  <text x="100" y="320" font-family="Arial, sans-serif" font-size="40" fill="#a9b9d4">Methode 7 jours + scripts</text>
  <text x="100" y="400" font-family="Arial, sans-serif" font-size="40" fill="#7ee2a1">Prix : {PRICE}</text>
  <text x="100" y="480" font-family="Arial, sans-serif" font-size="36" fill="#cfe0ff">{SITE_URL}</text>
</svg>
'@
$svgCover = $svgCover.Replace('{PRICE}',$PRICE).Replace('{SITE_URL}',$SITE_URL)
$svgCover | Set-Content (Join-Path $img 'couverture_1640x856.svg') -Encoding UTF8

# Post carre 1080
$svgPost = @'
<svg xmlns="http://www.w3.org/2000/svg" width="1080" height="1080" viewBox="0 0 1080 1080">
  <rect width="1080" height="1080" fill="#0f1720"/>
  <rect x="80" y="120" width="920" height="360" rx="24" fill="#101a2a" stroke="#233452"/>
  <text x="120" y="260" font-family="Arial, sans-serif" font-size="70" fill="#e6eef8">Devenir Freelance</text>
  <text x="120" y="340" font-family="Arial, sans-serif" font-size="40" fill="#a9b9d4">7 jours - scripts - checklists</text>
  <text x="120" y="420" font-family="Arial, sans-serif" font-size="44" fill="#7ee2a1">Prix : {PRICE}</text>
  <text x="120" y="920" font-family="Arial, sans-serif" font-size="36" fill="#cfe0ff">{SITE_URL}</text>
</svg>
'@
$svgPost = $svgPost.Replace('{PRICE}',$PRICE).Replace('{SITE_URL}',$SITE_URL)
$svgPost | Set-Content (Join-Path $img 'visuel_post.svg') -Encoding UTF8

# Carrousel 1..3
for($n=1;$n -le 3;$n++){
  $csvg = @'
<svg xmlns="http://www.w3.org/2000/svg" width="1080" height="1080" viewBox="0 0 1080 1080">
  <rect width="1080" height="1080" fill="#0f1720"/>
  <text x="70" y="160" font-family="Arial, sans-serif" font-size="60" fill="#e6eef8">Routine J{N}</text>
  <text x="70" y="260" font-family="Arial, sans-serif" font-size="42" fill="#cfe0ff">- Tache principale</text>
  <text x="70" y="330" font-family="Arial, sans-serif" font-size="42" fill="#cfe0ff">- Script rapide</text>
  <text x="70" y="400" font-family="Arial, sans-serif" font-size="42" fill="#cfe0ff">- Resultat attendu</text>
  <text x="70" y="990" font-family="Arial, sans-serif" font-size="34" fill="#a9b9d4">{SITE_URL}</text>
</svg>
'@
  $csvg = $csvg.Replace('{N}',$n).Replace('{SITE_URL}',$SITE_URL)
  $name = Join-Path $img ("visuel_carrousel_{0}.svg" -f $n)
  $csvg | Set-Content $name -Encoding UTF8
}

# ---------------- 3) UPDATE SITE (price + payment) ----------------
$buyPath = ".\dist\buy.html"
if(Test-Path $buyPath){
  $buy = Get-Content $buyPath -Raw
  $buy = $buy -replace 'https://example.com/your-payment-link', $PAY_URL
  $buy = [regex]::Replace($buy,'(?is)Prix\s*:\s*<b>.*?</b>',"Prix : <b>$PRICE</b>")
  $buy | Set-Content $buyPath -Encoding UTF8
}

$indexPath = ".\dist\index.html"
if(Test-Path $indexPath){
  $idx = Get-Content $indexPath -Raw
  $idx = [regex]::Replace($idx,'(?m)^\s*Prix\s*:\s*.*$',"Prix : $PRICE")
  $idx | Set-Content $indexPath -Encoding UTF8
}

# Deploy to /docs and push
if (Test-Path .\docs) { Remove-Item .\docs -Recurse -Force }
Copy-Item .\dist .\docs -Recurse -Force
New-Item -ItemType File -Path .\docs\.nojekyll -Force | Out-Null

git add .
git commit -m ("FB pack + images + MAJ prix=" + $PRICE + " + paiement") 2>$null | Out-Null
git push

# ---------------- 4) OPEN & RECAP ----------------
ii $fb
Start-Process ($SITE_URL + '?v=' + [int](Get-Random))
Get-ChildItem $fb -Recurse | Select-Object FullName,Length,LastWriteTime | Format-Table -Auto

