#!/usr/bin/env bash
# Render an HTML file to PDF via headless Chrome / Chromium / Edge (macOS or Linux).
# Usage: ./scripts/build-pdf.sh <input.html> <output.pdf>
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "usage: $0 <input.html> <output.pdf>" >&2
  exit 1
fi

HTML="$1"
PDF="$2"

if [[ ! -f "$HTML" ]]; then
  echo "HTML file not found: $HTML" >&2
  exit 1
fi

# Resolve to absolute paths
HTML_ABS="$(cd "$(dirname "$HTML")" && pwd)/$(basename "$HTML")"
PDF_DIR="$(dirname "$PDF")"
mkdir -p "$PDF_DIR"
PDF_ABS="$(cd "$PDF_DIR" && pwd)/$(basename "$PDF")"

# Find a Chromium-family browser
find_browser() {
  for cmd in \
    google-chrome \
    google-chrome-stable \
    chromium \
    chromium-browser \
    microsoft-edge \
    microsoft-edge-stable; do
    if command -v "$cmd" >/dev/null 2>&1; then
      echo "$cmd"
      return 0
    fi
  done

  # macOS app bundles
  for path in \
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" \
    "/Applications/Chromium.app/Contents/MacOS/Chromium"; do
    if [[ -x "$path" ]]; then
      echo "$path"
      return 0
    fi
  done

  return 1
}

BROWSER="$(find_browser)" || {
  echo "No Chromium-family browser found." >&2
  echo "Install one of: google-chrome, chromium, microsoft-edge" >&2
  exit 1
}

# Render
rm -f "$PDF_ABS"
"$BROWSER" \
  --headless=new \
  --disable-gpu \
  --no-sandbox \
  --no-pdf-header-footer \
  "--print-to-pdf=$PDF_ABS" \
  "file://$HTML_ABS" 2>/dev/null

if [[ ! -f "$PDF_ABS" ]]; then
  echo "PDF generation failed." >&2
  exit 1
fi

# Page-count sanity check (regex; no extra dep)
PAGES=$(LC_ALL=C grep -aoE '/Type[[:space:]]+/Page[^s]' "$PDF_ABS" | wc -l | tr -d ' ')
BYTES=$(wc -c < "$PDF_ABS" | tr -d ' ')

echo "$PDF_ABS -> $PAGES pages, $BYTES bytes"
if [[ "$PAGES" != "1" ]]; then
  echo "WARNING: expected 1 A4 page, got $PAGES. See SKILL.md for A4-fit levers." >&2
fi
