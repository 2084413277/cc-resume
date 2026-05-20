# Render an HTML file to PDF via headless Edge.
# Usage: .\scripts\build-pdf.ps1 -Html my-resume.html -Pdf my-resume.pdf
param(
  [Parameter(Mandatory = $true)] [string]$Html,
  [Parameter(Mandatory = $true)] [string]$Pdf,
  [string]$EdgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
)

if (-not (Test-Path $EdgePath)) {
  $alt = "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
  if (Test-Path $alt) { $EdgePath = $alt }
  else {
    Write-Error "Microsoft Edge not found at $EdgePath. Pass -EdgePath."
    exit 1
  }
}
if (-not (Test-Path $Html)) {
  Write-Error "HTML file not found: $Html"
  exit 1
}

$Html = (Resolve-Path $Html).Path
# resolve $Pdf against the PowerShell working directory (not .NET CWD)
if (-not [System.IO.Path]::IsPathRooted($Pdf)) {
  $Pdf = Join-Path (Get-Location).Path $Pdf
}
$Pdf = [System.IO.Path]::GetFullPath($Pdf)
$pdfDir = [System.IO.Path]::GetDirectoryName($Pdf)
if (-not (Test-Path $pdfDir)) { New-Item -ItemType Directory -Path $pdfDir -Force | Out-Null }
$url  = "file:///" + $Html.Replace("\","/")

# Kill stale Edge processes that may hold a lock on $Pdf
Get-Process msedge -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# If $Pdf is locked by a viewer, write to a sibling and tell the user
$tmp = $null
$target = $Pdf
if (Test-Path $Pdf) {
  try { Remove-Item $Pdf -Force -ErrorAction Stop }
  catch {
    $tmp = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($Pdf),
            [System.IO.Path]::GetFileNameWithoutExtension($Pdf) + "_new.pdf")
    $target = $tmp
    Write-Output "PDF locked by viewer, writing to $tmp instead"
  }
}

$args = @(
  "--headless=new","--disable-gpu","--no-sandbox","--no-pdf-header-footer",
  "--print-to-pdf=$target",
  $url
)
$p = Start-Process -FilePath $EdgePath -ArgumentList $args -PassThru -NoNewWindow
$p.WaitForExit(30000) | Out-Null

if (-not (Test-Path $target)) {
  Write-Error "PDF generation failed."
  exit 1
}

# Page-count sanity check (regex; no extra dependency)
function Get-PdfPageCount($path) {
  $b = [System.IO.File]::ReadAllBytes($path)
  $t = [System.Text.Encoding]::ASCII.GetString($b)
  return [regex]::Matches($t, '/Type\s*/Page[^s]').Count
}
$pages = Get-PdfPageCount $target
$bytes = (Get-Item $target).Length

# If we wrote to a tmp, try once more to swap into place
if ($tmp -and (Test-Path $tmp)) {
  Start-Sleep -Milliseconds 500
  try {
    Remove-Item $Pdf -Force -ErrorAction Stop
    Move-Item $tmp $Pdf
    $target = $Pdf
  } catch {
    # leave $tmp in place; user must close viewer
  }
}

Write-Output ("{0} -> {1} pages, {2:N0} bytes" -f $target, $pages, $bytes)
if ($pages -ne 1) {
  Write-Warning "Expected 1 A4 page, got $pages. See SKILL.md for A4-fit levers."
}
