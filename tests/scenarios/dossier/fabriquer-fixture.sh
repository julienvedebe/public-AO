#!/bin/bash
# Fabrique la fixture du scénario « dossier » : une consultation déjà analysée.
# - le DCE fictif de Val-de-Brelle (sources du scénario « analyse »), décompressé dans dce/ ;
# - cinq justificatifs fictifs (PDF) dont les dates reprennent celles de la fiche.
# Les PDF sont produits avec cupsfilter (Mac), comme pour le scénario « analyse ».
# Usage : tests/scenarios/dossier/fabriquer-fixture.sh
set -euo pipefail
ICI=$(cd "$(dirname "$0")" && pwd)
C="$ICI/dossier/consultations/2027-01_commune-de-val-de-brelle_lot-05-plomberie"
mkdir -p "$C/dce/DCE_2026-ECOLE-07" "$ICI/dossier/mes-justificatifs"
for f in "$ICI"/../analyse/dce-source/*.txt; do
  cupsfilter "$f" > "$C/dce/DCE_2026-ECOLE-07/$(basename "$f" .txt).pdf" 2>/dev/null
done
cp "$ICI/../analyse/dossier/dce-ecole-val-de-brelle.zip" "$C/"
TMP=$(mktemp -d)
justif() { # <fichier> <titre> <délivré le> <valable jusqu'au>
  printf 'PLOMBERIE EXEMPLE - SIRET 123 456 789 00012 (DOCUMENT FICTIF - JEU DE TEST)\n%s\nDelivre le : %s\nValable jusqu au : %s\n' "$2" "$3" "$4" > "$TMP/x.txt"
  cupsfilter "$TMP/x.txt" > "$ICI/dossier/mes-justificatifs/$1" 2>/dev/null
}
justif kbis.pdf "Extrait Kbis" 15/10/2026 15/01/2027
justif urssaf.pdf "Attestation de vigilance URSSAF" 31/03/2026 30/09/2026
justif fiscale.pdf "Attestation de regularite fiscale" 05/05/2026 31/12/2026
justif rc-pro.pdf "Attestation d assurance responsabilite civile professionnelle" 02/01/2026 31/12/2027
justif decennale.pdf "Attestation d assurance decennale" 02/01/2026 31/12/2027
rm -rf "$TMP"
