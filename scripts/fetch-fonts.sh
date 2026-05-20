#!/usr/bin/env bash
# Download the .woff2 fonts the resume template embeds (macOS / Linux).
# Run once after cloning: ./scripts/fetch-fonts.sh
set -euo pipefail

OUT_DIR="${1:-$(cd "$(dirname "$0")/.." && pwd)/fonts}"
mkdir -p "$OUT_DIR"

declare -A files=(
  [noto-sans-sc-400.woff2]="https://cdn.jsdelivr.net/npm/@fontsource/noto-sans-sc@latest/files/noto-sans-sc-chinese-simplified-400-normal.woff2"
  [noto-sans-sc-500.woff2]="https://cdn.jsdelivr.net/npm/@fontsource/noto-sans-sc@latest/files/noto-sans-sc-chinese-simplified-500-normal.woff2"
  [noto-sans-sc-600.woff2]="https://cdn.jsdelivr.net/npm/@fontsource/noto-sans-sc@latest/files/noto-sans-sc-chinese-simplified-600-normal.woff2"
  [noto-sans-sc-700.woff2]="https://cdn.jsdelivr.net/npm/@fontsource/noto-sans-sc@latest/files/noto-sans-sc-chinese-simplified-700-normal.woff2"
  [noto-serif-sc-400.woff2]="https://cdn.jsdelivr.net/npm/@fontsource/noto-serif-sc@latest/files/noto-serif-sc-chinese-simplified-400-normal.woff2"
  [noto-serif-sc-600.woff2]="https://cdn.jsdelivr.net/npm/@fontsource/noto-serif-sc@latest/files/noto-serif-sc-chinese-simplified-600-normal.woff2"
  [noto-serif-sc-700.woff2]="https://cdn.jsdelivr.net/npm/@fontsource/noto-serif-sc@latest/files/noto-serif-sc-chinese-simplified-700-normal.woff2"
  [ibm-plex-sans-400.woff2]="https://cdn.jsdelivr.net/npm/@fontsource/ibm-plex-sans@latest/files/ibm-plex-sans-latin-400-normal.woff2"
  [ibm-plex-sans-500.woff2]="https://cdn.jsdelivr.net/npm/@fontsource/ibm-plex-sans@latest/files/ibm-plex-sans-latin-500-normal.woff2"
  [ibm-plex-sans-600.woff2]="https://cdn.jsdelivr.net/npm/@fontsource/ibm-plex-sans@latest/files/ibm-plex-sans-latin-600-normal.woff2"
  [ibm-plex-sans-700.woff2]="https://cdn.jsdelivr.net/npm/@fontsource/ibm-plex-sans@latest/files/ibm-plex-sans-latin-700-normal.woff2"
  [newsreader-400.woff2]="https://cdn.jsdelivr.net/npm/@fontsource/newsreader@latest/files/newsreader-latin-400-normal.woff2"
  [newsreader-400-italic.woff2]="https://cdn.jsdelivr.net/npm/@fontsource/newsreader@latest/files/newsreader-latin-400-italic.woff2"
  [newsreader-600.woff2]="https://cdn.jsdelivr.net/npm/@fontsource/newsreader@latest/files/newsreader-latin-600-normal.woff2"
)

# pick a downloader
if command -v curl >/dev/null 2>&1; then
  fetch() { curl -fsSL --max-time 30 -o "$2" "$1"; }
elif command -v wget >/dev/null 2>&1; then
  fetch() { wget -q --timeout=30 -O "$2" "$1"; }
else
  echo "Need curl or wget" >&2
  exit 1
fi

for name in "${!files[@]}"; do
  out="$OUT_DIR/$name"
  if [[ -f "$out" ]]; then
    printf "skip   %s\n" "$name"
    continue
  fi
  if fetch "${files[$name]}" "$out"; then
    printf "ok     %s  (%s bytes)\n" "$name" "$(wc -c < "$out" | tr -d ' ')"
  else
    printf "FAIL   %s\n" "$name"
  fi
done

echo
echo "Fonts placed in: $OUT_DIR"
