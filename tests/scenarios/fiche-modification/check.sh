# Modification d'une rubrique de la fiche : seule cette rubrique change.
source "$ROOT/tests/lib.sh"
F="$D/ma-fiche-entreprise.md"
A="$ROOT/tests/scenarios/fiche-modification/dossier/ma-fiche-entreprise.md"

rubrique "$F" "Effectif" | grep -qE 'dirigeant compris : *6([^0-9]|$)' || _ko "effectif non passé à 6"
rubrique "$F" "Effectif" | grep -qE 'apprentis : *1([^0-9]|$)' || _ko "nombre d'apprentis modifié"

# Le reste de la fiche est identique, à part la date de mise à jour.
diff <(grep -v -e '^- Personnes' -e '^Mise à jour' "$A") <(grep -v -e '^- Personnes' -e '^Mise à jour' "$F") >/dev/null ||
  _ko "d'autres rubriques ont été modifiées"

sortie_contient '(^|[^0-9])6 personnes|six personnes|à 6' "la confirmation du changement"
vouvoie
fin
