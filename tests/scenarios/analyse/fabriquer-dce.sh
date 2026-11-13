#!/bin/bash
# Fabrique le DCE fictif du scénario « analyse » : des PDF produits avec les outils
# natifs du Mac (cupsfilter, à partir de texte), rangés dans un ZIP.
# Usage : tests/scenarios/analyse/fabriquer-dce.sh
# Écrit dossier/dce-ecole-val-de-brelle.zip, copié aussi dans analyse-lot-trop-gros/dossier/.
set -euo pipefail
ICI=$(cd "$(dirname "$0")" && pwd)
TMP=$(mktemp -d)
mkdir "$TMP/DCE_2026-ECOLE-07"
for f in "$ICI"/dce-source/*.txt; do
  nom=$(basename "$f" .txt)
  cupsfilter "$f" > "$TMP/DCE_2026-ECOLE-07/$nom.pdf" 2>/dev/null
done
rm -f "$ICI/dossier/dce-ecole-val-de-brelle.zip"
(cd "$TMP" && zip -qr "$ICI/dossier/dce-ecole-val-de-brelle.zip" DCE_2026-ECOLE-07 -x '*.DS_Store')
rm -rf "$TMP"
cp "$ICI/dossier/dce-ecole-val-de-brelle.zip" "$ICI/../analyse-lot-trop-gros/dossier/"
ls -l "$ICI/dossier/dce-ecole-val-de-brelle.zip"
