# Lot plus gros que la fourchette de la fiche (78 000 € estimés, maximum 40 000 €) :
# l'analyse explique le groupement et la sous-traitance, sans verdict 🟢, et laisse le choix ;
# au second tour l'artisan décline : statut « déclinée ».
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
au_tour 1
sortie_contient 'groupement' "le groupement dans la réponse"
sortie_contient 'sous-trait' "la sous-traitance dans la réponse"
sortie_ne_contient_pas 'passez votre tour|laissez tomber|n.y allez pas|renoncez' "une décision prise à la place de l'artisan"
sortie_contient 'décliner' "le choix de décliner"
toute_la_conversation
fichier_contient "$A" 'CCAP' "la source de la clause de sous-traitance (CCAP)"
fichier_contient "$A" 'plateforme' "le rappel de vérification sur la plateforme"
# Tour 2 : l'artisan décline ; la ligne passe à « déclinée », verdict gardé.
L=$(grep -i 'val-de-brelle' "$D/suivi.md")
grep -qi 'déclinée' <<< "$L" || _ko "le suivi n'indique pas le statut déclinée"
grep -qE '🟠|🔴' <<< "$L" || _ko "le verdict a disparu du suivi"
vouvoie
fin
