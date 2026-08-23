#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: pdf-spread INPUT.pdf OUTDIR [options]

Rendert PDF-Seiten als Bilder, schneidet oben/unten einen Rand ab
(z.B. um Seitenzahlen zu entfernen) und fuegt aufeinanderfolgende
Seiten paarweise zu Doppelseiten zusammen.

Optionen:
  --from N          erste zu rendernde Seite (Default: 1)
  --to N            letzte zu rendernde Seite (Default: letzte Seite der PDF)
  --dpi N           Aufloesung beim Rendern (Default: 200)
  --crop-top PCT    Prozent der Hoehe, die oben abgeschnitten wird (Default: 9)
  --crop-bottom PCT Prozent der Hoehe, die unten abgeschnitten wird (Default: 8)
  --pair-start N    erste Seite, die als linke Seite eines Paares gilt
                     (Default: Wert von --from). Seiten davor werden
                     einzeln ausgegeben.
  --pdf FILE        zusaetzlich alle Ergebnisbilder in dieser Reihenfolge
                     zu einer PDF zusammenfassen
  -h, --help        diese Hilfe anzeigen

Beispiel (Seiten 18+19 als eine Doppelseite, Rest der Datei ignorieren):
  pdf-spread heft.pdf out --from 18 --to 19

Beispiel (ganzes Heft, Seite 1 als Cover einzeln, Rest gepaart, plus PDF):
  pdf-spread heft.pdf out --pair-start 2 --pdf heft-spreads.pdf
EOF
}

FROM=1
TO=""
DPI=200
CROP_TOP=9
CROP_BOTTOM=8
PAIR_START=""
PDF_OUT=""
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --from) FROM="$2"; shift 2 ;;
    --to) TO="$2"; shift 2 ;;
    --dpi) DPI="$2"; shift 2 ;;
    --crop-top) CROP_TOP="$2"; shift 2 ;;
    --crop-bottom) CROP_BOTTOM="$2"; shift 2 ;;
    --pair-start) PAIR_START="$2"; shift 2 ;;
    --pdf) PDF_OUT="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    --) shift; POSITIONAL+=("$@"); break ;;
    -*) echo "Unbekannte Option: $1" >&2; usage >&2; exit 1 ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done

if [[ ${#POSITIONAL[@]} -lt 2 ]]; then
  usage >&2
  exit 1
fi

INPUT="${POSITIONAL[0]}"
OUTDIR="${POSITIONAL[1]}"

if [[ -z "$TO" ]]; then
  TO=$(pdfinfo "$INPUT" | awk '/^Pages:/{print $2}')
fi

if [[ -z "$PAIR_START" ]]; then
  PAIR_START="$FROM"
fi

rm -rf "$OUTDIR/pages" "$OUTDIR/result"
mkdir -p "$OUTDIR/pages/cropped" "$OUTDIR/result"

echo "Rendere Seiten $FROM-$TO bei ${DPI}dpi ..." >&2
pdftoppm -r "$DPI" -f "$FROM" -l "$TO" -png "$INPUT" "$OUTDIR/pages/page"

mapfile -t PAGES < <(find "$OUTDIR/pages" -maxdepth 1 -type f -name 'page-*.png' | sort -V)

if [[ ${#PAGES[@]} -eq 0 ]]; then
  echo "Keine Seiten gerendert." >&2
  exit 1
fi

crop_one() {
  local src="$1" dst="$2"
  local w h top bot newh
  read -r w h < <(magick identify -format "%w %h\n" "$src")
  top=$(awk -v h="$h" -v p="$CROP_TOP" 'BEGIN{printf "%d", h*p/100}')
  bot=$(awk -v h="$h" -v p="$CROP_BOTTOM" 'BEGIN{printf "%d", h*p/100}')
  newh=$((h - top - bot))
  magick "$src" -crop "${w}x${newh}+0+${top}" +repage "$dst"
}

extract_num() {
  basename "$1" .png | sed -E 's/^page-0*//'
}

CROPPED=()
for p in "${PAGES[@]}"; do
  dst="$OUTDIR/pages/cropped/$(basename "$p")"
  crop_one "$p" "$dst"
  CROPPED+=("$dst")
done

RESULT_FILES=()

n_single_start=$((PAIR_START - FROM))
if (( n_single_start < 0 )); then n_single_start=0; fi
if (( n_single_start > ${#CROPPED[@]} )); then n_single_start=${#CROPPED[@]}; fi

idx=0
for ((i = 0; i < n_single_start; i++)); do
  src="${CROPPED[idx]}"
  num=$(extract_num "$src")
  dst="$OUTDIR/result/$(printf '%04d' "$num")-single.png"
  cp "$src" "$dst"
  RESULT_FILES+=("$dst")
  idx=$((idx + 1))
done

while (( idx + 1 < ${#CROPPED[@]} )); do
  left="${CROPPED[idx]}"
  right="${CROPPED[idx + 1]}"
  ln=$(extract_num "$left")
  rn=$(extract_num "$right")
  dst="$OUTDIR/result/$(printf '%04d' "$ln")-spread-${ln}-${rn}.png"
  magick "$left" "$right" +append "$dst"
  RESULT_FILES+=("$dst")
  idx=$((idx + 2))
done

if (( idx < ${#CROPPED[@]} )); then
  src="${CROPPED[idx]}"
  num=$(extract_num "$src")
  dst="$OUTDIR/result/$(printf '%04d' "$num")-single.png"
  cp "$src" "$dst"
  RESULT_FILES+=("$dst")
fi

echo "Fertig: ${#RESULT_FILES[@]} Bild(er) in $OUTDIR/result" >&2

if [[ -n "$PDF_OUT" ]]; then
  img2pdf "${RESULT_FILES[@]}" -o "$PDF_OUT"
  echo "PDF geschrieben nach $PDF_OUT" >&2
fi
