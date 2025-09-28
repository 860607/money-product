<#
make-money-all-in-one.ps1 — version complète
"One-button" pipeline: scaffold -> build (PDF/ZIP) -> sales pages -> Git init -> GitHub repo -> GitHub Pages deploy.
Compatibilité : Windows PowerShell 5.1+ / PowerShell 7+
#>

#region === CONFIG ===
$ProductName   = "Guide Pratique : Devenir Freelance"
$Author        = "BIBI ONDOUA"
$Version       = "1.0.0"
$Price         = "9.99"
$Currency      = "EUR"
$Tagline       = "Un plan simple pour trouver vos 1ers clients en 30 jours."
$Keywords      = "freelance, prospection, portfolio, tarifs"
$PaymentLink   = "https://example.com/ton-lien-de-paiement"  # <-- Mets ton vrai lien

# Déploiement GitHub
$GithubUser    = "<ton-user-github>"   # ex: bibiondoua
$RepoName      = ($ProductName -replace '[^0-9A-Za-z\- ]','' -replace ' +','-').ToLower()
$RepoPrivate   = $false
$UseGitHubPages= $true
$CustomDomain  = ""  # ex: "sos-monde.com" (facultatif)

# Utiliser le dossier du script comme racine (corrige le piège System32)
$Root          = $PSScriptRoot
$SrcDir        = Join-Path $Root "product"
$ContentDir    = Join-Path $SrcDir "content"
$AssetsDir     = Join-Path $SrcDir "assets"
$DistDir       = Join-Path $Root "dist"
$DocsDir       = Join-Path $Root "docs"
#endregion

#region === UTILS ===
function Has-Cmd([string]$name){ return (Get-Command $name -ErrorAction SilentlyContinue) -ne $null }
function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]   $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Err($m){ Write-Host "[ERR]  $m" -ForegroundColor Red }
#endregion

Write-Host "`n=== 🚀 Pipeline ALL-IN-ONE : $ProductName ===`n" -ForegroundColor Magenta

#region === CHECK TOOLS ===
$hasGit    = Has-Cmd git
$hasGh     = Has-Cmd gh
$hasPandoc = Has-Cmd pandoc
if(-not $hasGit){ Warn "git non détecté. Le dépôt ne sera pas poussé." }
if(-not $hasGh){  Warn "GitHub CLI (gh) non détecté. Pas de repo/Pages." }
if(-not $hasPandoc){ Warn "pandoc non détecté. Le PDF ne sera pas généré (ZIP OK)." }
#endregion

#region === SCAFFOLD ===
Info "Création des dossiers…"
$null = New-Item -ItemType Directory -Force -Path $SrcDir,$ContentDir,$AssetsDir,$DistDir

# Contenu d’exemple si vide
if(-not (Get-ChildItem $ContentDir -Filter *.md -File -ErrorAction SilentlyContinue)){
  Info "Aucun .md → génération d’exemples…"
  @"# $ProductName

$Tagline

**Auteur :** $Author  
**Version :** $Version

## À qui s'adresse ce guide ?
- Débutants en freelance
- Salariés en reconversion
- Étudiants en mission

## Ce que vous allez obtenir
- Une méthode simple en 30 jours
- Des scripts de prospection
- Des modèles d’emails
"@ | Out-File (Join-Path $ContentDir "01-intro.md") -Encoding utf8

  @"# Jour 1–7 : Fondations

- Positionnement
- Offre claire
- Mini-portfolio

> Exercice : écrivez une offre irrésistible en 3 phrases.
"@ | Out-File (Join-Path $ContentDir "02-semaine1.md") -Encoding utf8

  @"# Scripts d’email

**Objet :** Proposition rapide pour [Entreprise]

Bonjour [Prénom],  
Je vous propose [bénéfice]. Puis-je vous envoyer un plan en 3 points ?

Bien à vous,  
$Author
"@ | Out-File (Join-Path $ContentDir "03-scripts.md") -Encoding utf8
  Ok "Exemples créés."
}else{ Ok "Contenus existants détectés." }

# Logo placeholder
$logoSvg = @"
<svg xmlns='http://www.w3.org/2000/svg' width='256' height='256' viewBox='0 0 256 256'>
<rect width='256' height='256' fill='#0b1220'/><circle cx='128' cy='128' r='96' fill='#0f3e91'/>
<text x='128' y='145' text-anchor='middle' fill='white' font-size='64' font-family='Segoe UI, Arial'>BI</text>
</svg>
"@
$null = New-Item -ItemType Directory -Force -Path $AssetsDir
$logoPath = Join-Path $AssetsDir "logo.svg"; $logoSvg | Out-File $logoPath -Encoding utf8
#endregion

#region === BUILD (PDF/ZIP/pages) ===
Info "Concaténation des Markdown…"
$tempMd = Join-Path $DistDir "combined.md"
"" | Out-File $tempMd -Encoding utf8
Get-ChildItem $ContentDir -Filter *.md -File | Sort-Object Name | ForEach-Object {
  Add-Content -Path $tempMd -Value "`n`n" + (Get-Content $_.FullName -Raw)
}
Ok "Markdown combiné: $tempMd"

# PDF
$pdfFile = Join-Path $DistDir ("$($ProductName -replace '[^0-9A-Za-z\- ]','') - $Version.pdf")
if($hasPandoc){
  Info "Génération PDF via pandoc…"
  try{
    & pandoc $tempMd -o $pdfFile --metadata title="$ProductName" --metadata author="$Author"
    if(Test-Path $pdfFile){ Ok "PDF créé: $pdfFile" } else { Warn "PDF introuvable après pandoc." }
  }catch{ Warn "Échec pandoc: $($_.Exception.Message)" }
}else{ Warn "PDF non généré (pandoc manquant)." }

# README + ZIP
$readme = Join-Path $DistDir "README.txt"
@(
  "$ProductName",
  "Auteur : $Author",
  "Version : $Version",
  "Prix conseillé : $Price $Currency",
  "",
  "Merci pour votre achat !"
) | Out-File $readme -Encoding utf8

$zipFile = Join-Path $DistDir ("$($ProductName -replace '[^0-9A-Za-z\- ]','') - $Version.zip")
if(Test-Path $zipFile){ Remove-Item $zipFile -Force }
$zipList = @($tempMd,$readme,(Get-ChildItem $ContentDir -Filter *.md -File | % FullName))
if(Test-Path $pdfFile){ $zipList += $pdfFile }
Compress-Archive -Path $zipList -DestinationPath $zipFile
Ok "ZIP créé: $zipFile"

# index.html + buy.html
Info "Génération des pages…"
$indexHtml = @"
<!doctype html><html lang=\"fr\"><head>
<meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">
<title>$ProductName — $Price $Currency</title>
<meta name=\"description\" content=\"$Tagline\"><meta name=\"keywords\" content=\"$Keywords\">
<style>
body{font-family:Segoe UI,Roboto,Arial;margin:0;background:#0f1720;color:#e6eef8}
.wrap{max-width:920px;margin:0 auto;padding:2rem}
.card{background:linear-gradient(180deg,#0b1220,#0f1720);border-radius:16px;padding:2rem;box-shadow:0 10px 32px rgba(0,0,0,.5)}
h1{margin:.2rem 0 1rem} .price{color:#7ee2a1;font-size:1.6rem}
.btn{display:inline-block;background:#2563eb;color:#fff;padding:.9rem 1.2rem;border-radius:10px;text-decoration:none}
.grid{display:grid;gap:1rem;grid-template-columns:1fr}
footer{margin-top:1.2rem;color:#9fb0c8;font-size:.9rem}
img{width:56px;height:56px;vertical-align:middle;margin-right:.5rem}
@media(min-width:720px){.grid{grid-template-columns:1fr 1fr}}
</style></head><body><div class=\"wrap\">
<div class=\"card\">
  <h1><img src=\"assets/logo.svg\" alt=\"\">$ProductName</h1>
  <div>$Tagline</div>
  <p class=\"price\">$Price $Currency</p>
  <p><a class=\"btn\" href=\"buy.html\">Acheter maintenant</a></p>
  <div class=\"grid\">
    <div><h3>Ce que vous obtenez</h3><ul>
      <li>Version PDF (si générée) + sources Markdown</li>
      <li>Scripts d’email & checklists</li>
      <li>Mises à jour mineures incluses (v$Version)</li>
    </ul></div>
    <div><h3>Sommaire</h3><ul>
"@
(Get-ChildItem $ContentDir -Filter *.md -File | Sort-Object Name) | ForEach-Object {
  $first = (Get-Content $_.FullName -TotalCount 1)
  if($first -match '^#\s*(.+)'){ $t = $Matches[1] } else { $t = $_.BaseName }
  $indexHtml += "      <li>$t</li>`n"
}
$indexHtml += @"
    </ul></div>
  </div>
  <footer>Propriété intellectuelle de $Author — v$Version</footer>
</div></div></body></html>
"@
$indexPath = Join-Path $DistDir "index.html"; $indexHtml | Out-File $indexPath -Encoding utf8

$buyHtml = @"
<!doctype html><html lang='fr'><head>
<meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'>
<title>Acheter — $ProductName</title></head>
<body style='font-family:Segoe UI,Arial;margin:2rem;background:#f6f8fb;color:#111'>
<h1>Acheter : $ProductName</h1>
<p>Prix : <strong>$Price $Currency</strong></p>
<p><a href='$PaymentLink' style='display:inline-block;padding:12px 18px;background:#0b84ff;color:#fff;border-radius:8px;text-decoration:none'>Payer maintenant</a></p>
<p>Après paiement, vous recevrez le lien de téléchargement (ZIP/PDF).</p>
</body></html>
"@
$buyPath = Join-Path $DistDir "buy.html"; $buyHtml | Out-File $buyPath -Encoding utf8

# Copier assets vers dist
$DistAssets = Join-Path $DistDir "assets"
Copy-Item -Path $AssetsDir -Destination $DistAssets -Recurse -Force
Ok "Pages prêtes dans: $DistDir"
#endregion

#region === GIT INIT/COMMIT ===
Info "Initialisation Git…"
if($hasGit){
  if(-not (Test-Path (Join-Path $Root ".git"))){ git init | Out-Null }
  "*~`nnode_modules/`n*.log`n*.tmp`n" | Out-File (Join-Path $Root ".gitignore") -Encoding utf8
  # docs = copie pour GitHub Pages
  if(Test-Path $DocsDir){ Remove-Item $DocsDir -Recurse -Force }
  Copy-Item $DistDir $DocsDir -Recurse -Force
  if($CustomDomain){ " $CustomDomain " | Out-File (Join-Path $DocsDir "CNAME") -Encoding ascii }
  git add . | Out-Null
  $msg = "chore: build $ProductName v$Version"
  git commit -m $msg 2>$null | Out-Null
  Ok "Repo Git prêt."
}else{ Warn "git absent → étape ignorée." }
#endregion

#region === CREATE GITHUB REPO & PAGES ===
$pagesUrl = $null
if($hasGit -and $hasGh -and $UseGitHubPages){
  Info "Création/poussée sur GitHub…"
  try{ $auth = (& gh auth status 2>$null) }catch{ $auth = $null }
  if(-not $auth){ Warn "gh non authentifié. Lance 'gh auth login' puis relance." }
  else{
    $remoteUrl = "https://github.com/$GithubUser/$RepoName.git"
    $existingRemote = (git remote get-url origin 2>$null)
    if(-not $existingRemote){
      $privFlag = if($RepoPrivate){"--private"}else{"--public"}
      & gh repo create "$GithubUser/$RepoName" $privFlag --source "." --remote "origin" --push | Out-Null
    }else{ git push -u origin main 2>$null | Out-Null }

    # Activer Pages sur main:/docs
    try{ & gh api repos/$GithubUser/$RepoName/pages -X PUT -F "source[branch]=main" -F "source[path]=/docs" 2>$null | Out-Null }
    catch{ try{ & gh api repos/$GithubUser/$RepoName/pages -X POST -F "source[branch]=main" -F "source[path]=/docs" | Out-Null }catch{} }

    if([string]::IsNullOrWhiteSpace($CustomDomain)){
      $pagesUrl = "https://$GithubUser.github.io/$RepoName/"
    }else{
      $pagesUrl = "https://$CustomDomain/"
      Ok "Ajoute un CNAME chez ton registrar vers $GithubUser.github.io."
    }
    Ok "Déployé sur GitHub Pages: $pagesUrl"
  }
}else{
  if(-not $UseGitHubPages){ Warn "Déploiement Pages désactivé." }
  elseif(-not $hasGit){    Warn "git manquant → pas de push." }
  elseif(-not $hasGh){     Warn "gh manquant → pas de repo/Pages." }
}
#endregion

#region === OUTPUT RÉCAP ===
Write-Host "`n=== ✅ Terminé ===" -ForegroundColor Green
Write-Host "• Dossier build : $DistDir"
Write-Host "• Page locale   : $(Join-Path $DistDir 'index.html')"
Write-Host "• Achat local   : $(Join-Path $DistDir 'buy.html')"
if(Test-Path $DistDir){
  $zipShow = Get-ChildItem $DistDir -Filter '*.zip' -ErrorAction SilentlyContinue | Select-Object -First 1
  if($zipShow){ Write-Host "• ZIP produit   : $($zipShow.FullName)" } else { Write-Host "• ZIP produit   : (non trouvé)" }
  $pdfShow = Get-ChildItem $DistDir -Filter '*.pdf' -ErrorAction SilentlyContinue | Select-Object -First 1
  if($pdfShow){ Write-Host "• PDF produit   : $($pdfShow.FullName)" }
}
if($pagesUrl){ Write-Host "• En ligne      : $pagesUrl" }
Write-Host "`nProchaine étape : mets ton vrai lien de paiement dans `$PaymentLink`." -ForegroundColor Yellow
#endregion

# Ouvrir automatiquement le dossier dist
Start-Sleep 1
if(Test-Path $DistDir){ ii $DistDir }
