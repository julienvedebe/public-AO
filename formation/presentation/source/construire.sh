#!/bin/bash
# Reconstruit le support de formation (HTML + PDF) à partir de diapos.html et du modèle Picant3, puis le contrôle.
#
# Usage : formation/presentation/source/construire.sh [--maj-modele]
#   --maj-modele  recopie d'abord le modèle depuis Open Design (projet « Picant3 — Marque »)
#
# Contrôles : une page de PDF par diapositive, aucune mention « commerciale ».
# Les emplacements « à compléter » (lieu, captures…) sont comptés et listés, sans bloquer.
set -euo pipefail

ICI=$(cd "$(dirname "$0")" && pwd)
SORTIE="$ICI/.."
CHROME=${CHROME:-"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"}
OD="http://192.168.0.33:7456/api/projects/picant3-landing-f/files"

if [ "${1:-}" = "--maj-modele" ]; then
  curl -fsS "$OD/deck/modele-presentation-picant3.html" -o "$ICI/modele-presentation-picant3.html.tmp"
  mv "$ICI/modele-presentation-picant3.html.tmp" "$ICI/modele-presentation-picant3.html"
  echo "Modèle recopié depuis Open Design. Relisez deck/MODE-EMPLOI.md du même projet s'il a changé."
fi

python3 -I "$ICI/assembler.py" "$ICI/modele-presentation-picant3.html" "$ICI/diapos.html" "$ICI/marque.png" \
  "$SORTIE/support-formation.html"

[ -x "$CHROME" ] || { echo "Chrome introuvable ($CHROME) : définissez CHROME=… pour produire le PDF."; exit 2; }
PROFIL=$(mktemp -d)
trap 'rm -rf "$PROFIL"' EXIT
"$CHROME" --headless=new --disable-gpu --no-pdf-header-footer --user-data-dir="$PROFIL" \
  --print-to-pdf="$SORTIE/support-formation.pdf" "file://$SORTIE/support-formation.html" >/dev/null 2>&1

diapos=$(grep -c 'data-screen-label="' "$SORTIE/support-formation.html")
pages=$(python3 -I -c "import re,sys; print(len(re.findall(rb'/Type\s*/Page(?![s\w])', open(sys.argv[1],'rb').read())))" "$SORTIE/support-formation.pdf")
commercial=$({ grep -oi 'commercial' "$SORTIE/support-formation.html" || true; } | wc -l | tr -d ' ')
modele=$({ grep -oE '\[ [^]]* \]' "$SORTIE/support-formation.html" || true; } | wc -l | tr -d ' ')

echo "Diapositives : $diapos · pages du PDF : $pages"
[ "$commercial" = 0 ] || { echo "✗ La mention « commerciale » du modèle est restée."; exit 1; }
[ "$modele" = 0 ] || { echo "✗ Il reste des emplacements du modèle « [ … ] »."; exit 1; }
[ "$pages" = "$diapos" ] || { echo "✗ Le PDF n'a pas une page par diapositive : une diapositive déborde ou une règle d'impression du modèle a changé."; exit 1; }

echo "Emplacements à compléter avant la formation :"
python3 -I - "$ICI/diapos.html" <<'EOF'
import re, sys, html
t = open(sys.argv[1], encoding="utf-8").read()
for n, s in enumerate(re.findall(r'<section class="slide".*?</section>', t, flags=re.S), 1):
    for x in re.findall(r'class="a-completer">(.*?)</', s):
        print(f"  diapositive {n:02d} : {html.unescape(x)}")
EOF
echo "✓ Support prêt : formation/presentation/support-formation.pdf"
