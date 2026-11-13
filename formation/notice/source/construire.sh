#!/bin/bash
# Reconstruit les notices (HTML + PDF) à partir de leur corps et du modèle Picant3, puis les contrôle :
#   corps.html           -> notice-utilisation   (notice complète, formateur)
#   corps-essentiel.html -> notice-essentielle   (3 pages, artisans)
#
# Usage : formation/notice/source/construire.sh [--maj-modele]
#   --maj-modele  recopie d'abord le modèle depuis Open Design (projet « Picant3 — Marque »)
#
# Contrôle : le PDF doit avoir exactement une page par feuille (<section class="sheet">).
# Une page de plus veut dire qu'une feuille déborde : raccourcir son contenu dans corps.html.
set -euo pipefail

ICI=$(cd "$(dirname "$0")" && pwd)
NOTICE="$ICI/.."
CHROME=${CHROME:-"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"}
OD_MODELE="http://192.168.0.33:7456/api/projects/picant3-landing-f/files/documentation/document-technique-modele.html"

if [ "${1:-}" = "--maj-modele" ]; then
  curl -fsS "$OD_MODELE" -o "$ICI/modele-picant3.html.tmp"
  mv "$ICI/modele-picant3.html.tmp" "$ICI/modele-picant3.html"
  echo "Modèle recopié depuis Open Design."
fi

[ -x "$CHROME" ] || { echo "Chrome introuvable ($CHROME) : définissez CHROME=… pour produire le PDF."; exit 2; }
PROFIL=$(mktemp -d)
trap 'rm -rf "$PROFIL"' EXIT
erreurs=0

construire() { # <corps> <nom de sortie>
  local corps="$ICI/$1" html="$NOTICE/$2.html" pdf="$NOTICE/$2.pdf"
  [ -f "$corps" ] || return 0
  python3 -I "$ICI/assembler.py" "$ICI/modele-picant3.html" "$corps" "$html"
  "$CHROME" --headless=new --disable-gpu --no-pdf-header-footer --user-data-dir="$PROFIL" \
    --print-to-pdf="$pdf" "file://$html" >/dev/null 2>&1
  local feuilles pages reste
  feuilles=$(grep -c '<section class="sheet' "$html")
  pages=$(python3 -I -c "import re,sys; print(len(re.findall(rb'/Type\s*/Page(?![s\w])', open(sys.argv[1],'rb').read())))" "$pdf")
  reste=$({ grep -oE 'class="(ph|fill)"|AAAA-D-000' "$html" || true; } | wc -l | tr -d ' ')
  echo "$2 : feuilles $feuilles · pages du PDF $pages · emplacements du modèle restants $reste"
  if [ "$reste" != 0 ]; then echo "  ✗ Il reste des emplacements du modèle à remplir."; erreurs=$((erreurs + 1)); fi
  if [ "$pages" != "$feuilles" ]; then echo "  ✗ Une feuille déborde à l'impression : raccourcissez-la (environ 840 px de contenu par feuille)."; erreurs=$((erreurs + 1)); fi
}

construire corps.html notice-utilisation
construire corps-essentiel.html notice-essentielle

[ "$erreurs" = 0 ] || exit 1
echo "✓ Notices prêtes dans formation/notice/"
