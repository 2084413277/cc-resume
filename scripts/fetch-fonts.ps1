# Download the .woff2 fonts the resume template embeds.
# Run once after cloning: .\scripts\fetch-fonts.ps1
param(
  [string]$OutDir = (Join-Path $PSScriptRoot "..\fonts")
)

if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }
$OutDir = (Resolve-Path $OutDir).Path

$files = @{
  "noto-sans-sc-400.woff2"      = "https://cdn.jsdelivr.net/npm/@fontsource/noto-sans-sc@latest/files/noto-sans-sc-chinese-simplified-400-normal.woff2"
  "noto-sans-sc-500.woff2"      = "https://cdn.jsdelivr.net/npm/@fontsource/noto-sans-sc@latest/files/noto-sans-sc-chinese-simplified-500-normal.woff2"
  "noto-sans-sc-600.woff2"      = "https://cdn.jsdelivr.net/npm/@fontsource/noto-sans-sc@latest/files/noto-sans-sc-chinese-simplified-600-normal.woff2"
  "noto-sans-sc-700.woff2"      = "https://cdn.jsdelivr.net/npm/@fontsource/noto-sans-sc@latest/files/noto-sans-sc-chinese-simplified-700-normal.woff2"
  "noto-serif-sc-400.woff2"     = "https://cdn.jsdelivr.net/npm/@fontsource/noto-serif-sc@latest/files/noto-serif-sc-chinese-simplified-400-normal.woff2"
  "noto-serif-sc-600.woff2"     = "https://cdn.jsdelivr.net/npm/@fontsource/noto-serif-sc@latest/files/noto-serif-sc-chinese-simplified-600-normal.woff2"
  "noto-serif-sc-700.woff2"     = "https://cdn.jsdelivr.net/npm/@fontsource/noto-serif-sc@latest/files/noto-serif-sc-chinese-simplified-700-normal.woff2"
  "ibm-plex-sans-400.woff2"     = "https://cdn.jsdelivr.net/npm/@fontsource/ibm-plex-sans@latest/files/ibm-plex-sans-latin-400-normal.woff2"
  "ibm-plex-sans-500.woff2"     = "https://cdn.jsdelivr.net/npm/@fontsource/ibm-plex-sans@latest/files/ibm-plex-sans-latin-500-normal.woff2"
  "ibm-plex-sans-600.woff2"     = "https://cdn.jsdelivr.net/npm/@fontsource/ibm-plex-sans@latest/files/ibm-plex-sans-latin-600-normal.woff2"
  "ibm-plex-sans-700.woff2"     = "https://cdn.jsdelivr.net/npm/@fontsource/ibm-plex-sans@latest/files/ibm-plex-sans-latin-700-normal.woff2"
  "newsreader-400.woff2"        = "https://cdn.jsdelivr.net/npm/@fontsource/newsreader@latest/files/newsreader-latin-400-normal.woff2"
  "newsreader-400-italic.woff2" = "https://cdn.jsdelivr.net/npm/@fontsource/newsreader@latest/files/newsreader-latin-400-italic.woff2"
  "newsreader-600.woff2"        = "https://cdn.jsdelivr.net/npm/@fontsource/newsreader@latest/files/newsreader-latin-600-normal.woff2"
}

foreach ($name in $files.Keys) {
  $out = Join-Path $OutDir $name
  if (Test-Path $out) {
    Write-Output "skip   $name"
    continue
  }
  try {
    Invoke-WebRequest -Uri $files[$name] -OutFile $out -UseBasicParsing -TimeoutSec 30
    $size = (Get-Item $out).Length
    Write-Output ("ok     {0}  ({1:N0} bytes)" -f $name, $size)
  } catch {
    Write-Output "FAIL   $name : $($_.Exception.Message)"
  }
}

Write-Output ""
Write-Output "Fonts placed in: $OutDir"
