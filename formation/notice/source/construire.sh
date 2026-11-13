#!/bin/bash
# Reconstruit la notice (HTML + PDF) à partir de corps.html et du modèle Picant3, puis la contrôle.
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

python3 -I "$ICI/assembler.py" "$ICI/modele-picant3.html" "$ICI/corps.html" "$NOTICE/notice-utilisation.html"

[ -x "$CHROME" ] || { echo "Chrome introuvable ($CHROME) : définissez CHROME=… pour produire le PDF."; exit 2; }
PROFIL=$(mktemp -d)
trap 'rm -rf "$PROFIL"' EXIT
"$CHROME" --headless=new --disable-gpu --no-pdf-header-footer --user-data-dir="$PROFIL" \
  --print-to-pdf="$NOTICE/notice-utilisation.pdf" "file://$NOTICE/notice-utilisation.html" >/dev/null 2>&1

feuilles=$(grep -c '<section class="sheet' "$NOTICE/notice-utilisation.html")
pages=$(python3 -I -c "import re,sys; print(len(re.findall(rb'/Type\s*/Page(?![s\w])', open(sys.argv[1],'rb').read())))" "$NOTICE/notice-utilisation.pdf")
reste=$({ grep -oE 'class="(ph|fill)"|AAAA-D-000' "$NOTICE/notice-utilisation.html" || true; } | wc -l | tr -d ' ')

echo "Feuilles : $feuilles · pages du PDF : $pages · emplacements du modèle restants : $reste"
[ "$reste" = 0 ] || { echo "✗ Il reste des emplacements du modèle à remplir."; exit 1; }
[ "$pages" = "$feuilles" ] || { echo "✗ Une feuille déborde à l'impression : raccourcissez-la (environ 840 px de contenu par feuille)."; exit 1; }
echo "✓ Notice prête : formation/notice/notice-utilisation.pdf"
