# minimal money maker v1 (ASCII only)
$ErrorActionPreference = "Stop"

# always build next to this script
$Root     = $PSScriptRoot
$SrcDir   = Join-Path $Root "product"
$ContDir  = Join-Path $SrcDir "content"
$Assets   = Join-Path $SrcDir "assets"
$DistDir  = Join-Path $Root "dist"

# config
$ProductName = "Guide Pratique - Devenir Freelance"
$Author      = "BIBI ONDOUA"
$Version     = "1.0.0"
$Price       = "9.99"
$Currency    = "EUR"
$PaymentLink = "https://example.com/your-payment-link"

# create folders
New-Item -ItemType Directory -Force -Path $SrcDir,$ContDir,$Assets,$DistDir | Out-Null

# sample markdown files (ASCII only)
Set-Content -Encoding UTF8 -Path (Join-Path $ContDir "01-intro.md") -Value @(
"# $ProductName",
"",
"Author: $Author",
"Version: $Version",
"",
"Who is this for?",
"- New freelancers",
"- Career switchers",
"- Students",
"",
"What you get",
"- A simple 30-day plan",
"- Email scripts",
"- Checklists"
)

Set-Content -Encoding UTF8 -Path (Join-Path $ContDir "02-week1.md") -Value @(
"# Days 1-7 - Foundations",
"- Positioning",
"- Clear offer",
"- Mini portfolio",
"",
"Exercise: write your 3-line offer."
)

Set-Content -Encoding UTF8 -Path (Join-Path $ContDir "03-emails.md") -Value @(
"# Email scripts",
"Subject: Quick idea for [Company]",
"",
"Hello [Name],",
"I can help you with [benefit]. May I send a 3-point plan?",
"",
"Best,",
"$Author"
)

# combine md
$combined = Join-Path $DistDir "combined.md"
Get-ChildItem $ContDir -Filter *.md | Sort-Object Name | ForEach-Object {
  Add-Content -Path $combined -Value (Get-Content $_.FullName -Raw)
  Add-Content -Path $combined -Value "`r`n`r`n"
}

# build simple index.html (ASCII only)
$indexHtml = @(
"<!doctype html>",
"<html lang='en'><head><meta charset='utf-8'>",
"<meta name='viewport' content='width=device-width,initial-scale=1'>",
"<title>$ProductName - $Price $Currency</title>",
"<style>body{font-family:Arial;margin:0;background:#0f1720;color:#e6eef8}",
".wrap{max-width:920px;margin:0 auto;padding:24px}",
".card{background:#111a2a;border-radius:12px;padding:20px;box-shadow:0 10px 24px rgba(0,0,0,.5)}",
".btn{display:inline-block;background:#2563eb;color:#fff;padding:10px 14px;border-radius:8px;text-decoration:none}</style>",
"</head><body><div class='wrap'><div class='card'>",
"<h1>$ProductName</h1>",
"<p>Author: $Author - v$Version</p>",
"<p>Price: $Price $Currency</p>",
"<p><a class='btn' href='buy.html'>Buy now</a></p>",
"<h3>Contents</h3><ul>"
)
Get-ChildItem $ContDir -Filter *.md | Sort-Object Name | ForEach-Object {
  $first = (Get-Content $_.FullName -TotalCount 1)
  if($first -match '^#\s*(.+)'){ $t = $Matches[1] } else { $t = $_.BaseName }
  $indexHtml += "  <li>$t</li>"
}
$indexHtml += @(
"</ul><p>Intellectual property: $Author</p>",
"</div></div></body></html>"
)
Set-Content -Encoding UTF8 -Path (Join-Path $DistDir "index.html") -Value $indexHtml

# buy.html
Set-Content -Encoding UTF8 -Path (Join-Path $DistDir "buy.html") -Value @(
"<!doctype html>",
"<html lang='en'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'>",
"<title>Buy - $ProductName</title></head>",
"<body style='font-family:Arial;margin:24px;'>",
"<h1>Buy: $ProductName</h1>",
"<p>Price: <b>$Price $Currency</b></p>",
"<p><a href='$PaymentLink' style='display:inline-block;padding:10px 14px;background:#0b84ff;color:#fff;border-radius:8px;text-decoration:none'>Pay now</a></p>",
"</body></html>"
)

# zip product (markdown + combined)
$zipPath = Join-Path $DistDir ("$($ProductName -replace '[^0-9A-Za-z -]','') - $Version.zip")
if(Test-Path $zipPath){ Remove-Item $zipPath -Force }
$toZip = @($combined) + (Get-ChildItem $ContDir -Filter *.md | ForEach-Object FullName)
Compress-Archive -Path $toZip -DestinationPath $zipPath

Write-Host "`nDone. Dist folder:" $DistDir -ForegroundColor Green
Start-Sleep 1
ii $DistDir
