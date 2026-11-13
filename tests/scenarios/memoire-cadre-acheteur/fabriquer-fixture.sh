#!/bin/bash
# Fabrique la fixture du scénario « memoire-cadre-acheteur », avec les seuls outils du Mac (zip, sed, cupsfilter) :
# - le dossier de travail du scénario « memoire » (fiche, suivi, analyse, DCE fictif de Val-de-Brelle en PDF) ;
# - un RC modifié : l'article 10 impose le cadre de réponse technique (CRT) de l'acheteur ;
# - le CRT lui-même, un .docx assemblé à partir des parties XML écrites à la main dans cadre-source/
#   (styles propres à l'acheteur, en-tête et pied de page, consignes de longueur, tableau « réponse du candidat »
#   avec des cases vides, lignes vides laissées sous les questions, zone de signature).
# Le .docx est aussi copié à la racine du scénario (cadre-acheteur.docx) pour les essais directs du script.
# Usage : tests/scenarios/memoire-cadre-acheteur/fabriquer-fixture.sh
set -euo pipefail
ICI=$(cd "$(dirname "$0")" && pwd)
REL="consultations/2027-01_commune-de-val-de-brelle_lot-05-plomberie"
DCE="$ICI/dossier/$REL/dce/DCE_2026-ECOLE-07"

rm -rf "$ICI/dossier"
cp -R "$ICI/../memoire/dossier" "$ICI/dossier"

# Analyse : le DCE compte une pièce de plus.
sed -i '' 's/^Pièces trouvées : 6 documents (RC, CCAP, AE, CCTP lots 03, 04 et 05)\./Pièces trouvées : 7 documents (RC, CCAP, AE, CCTP lots 03, 04 et 05, cadre de réponse technique)./' \
  "$ICI/dossier/$REL/analyse.md"
grep -q '7 documents' "$ICI/dossier/$REL/analyse.md"

# RC : le cadre est obligatoire (fin de l'article 10).
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
RC=01_RC_Reglement-de-la-consultation
awk '{ print } /^du candidat\)\.$/ {
  print "Le memoire technique est presente OBLIGATOIREMENT dans le cadre de reponse"
  print "technique (CRT) joint au DCE (piece 07), sans en modifier les rubriques ni"
  print "l'"'"'ordre. Une offre dont le memoire ne suit pas ce cadre pourra etre"
  print "declaree irreguliere. Le cadre complete ne depasse pas 10 pages."
}' "$ICI/../analyse/dce-source/$RC.txt" > "$TMP/$RC.txt"
grep -q OBLIGATOIREMENT "$TMP/$RC.txt"
cupsfilter "$TMP/$RC.txt" > "$DCE/$RC.pdf" 2>/dev/null

# CRT : les parties XML, [Content_Types].xml en premier.
for f in $(cd "$ICI/cadre-source" && find . -type f \( -name '*.xml' -o -name '*.rels' \)); do
  xmllint --noout "$ICI/cadre-source/$f"
done
rm -f "$ICI/cadre-acheteur.docx"
(cd "$ICI/cadre-source" && zip -q -X "$ICI/cadre-acheteur.docx" '[Content_Types].xml' _rels/.rels docProps/core.xml \
  word/document.xml word/styles.xml word/settings.xml word/header1.xml word/footer1.xml word/_rels/document.xml.rels)
cp "$ICI/cadre-acheteur.docx" "$DCE/07_CRT_Cadre-de-reponse-technique_Lot-05.docx"
textutil -convert txt -stdout "$ICI/cadre-acheteur.docx" | grep -q 'CADRE DE RÉPONSE TECHNIQUE'
echo "Fixture fabriquée."
