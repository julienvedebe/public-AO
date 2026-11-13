# Lot plus gros que la fourchette de la fiche (78 000 € estimés, maximum 40 000 €) :
# l'analyse explique le groupement et la sous-traitance, sans verdict 🟢.
source "$ROOT/tests/lib.sh"

C=$(ls -d "$D"/consultations/*/ 2>/dev/null | grep -i 'val-de-brelle' | head -1)
C=${C%/}
[ -n "$C" ] || { _ko "pas de sous-dossier de consultation pour Val-de-Brelle"; fin; }
A=$(find "$C" -maxdepth 1 -iname '*analyse*.md' | head -1)
[ -n "$A" ] || { _ko "fichier d'analyse absent de la consultation"; fin; }

V=$(rubrique "$A" "Verdict")
grep -q '🟢' <<< "$V" && _ko "verdict 🟢 pour un lot au-dessus de la fourchette de la fiche"
grep -qE '🟠|🔴' <<< "$V" || _ko "aucun verdict 🟠 ou 🔴"

fichier_contient "$A" 'groupement' "l'explication du groupement momentané d'entreprises"
fichier_contient "$A" 'sous-trait' "l'explication de la sous-traitance"
sortie_contient 'groupement' "le groupement dans la réponse"
sortie_contient 'sous-trait' "la sous-traitance dans la réponse"
fichier_contient "$A" 'CCAP' "la source de la clause de sous-traitance (CCAP)"
fichier_contient "$A" 'plateforme' "le rappel de vérification sur la plateforme"
grep -qi 'analysée' "$D/suivi.md" || _ko "le suivi n'indique pas le statut analysée"
vouvoie
fin
