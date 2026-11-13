# Se faire connaître avec une fiche incomplète : la lettre marque [À COMPLÉTER]
# ce qui manque et n'invente rien.
source "$ROOT/tests/lib.sh"
FICHE="$D/ma-fiche-entreprise.md"
LETTRE="$D/se-faire-connaitre/lettre-de-presentation.md"

diff -q "$ROOT/tests/scenarios/se-faire-connaitre-fiche-incomplete/dossier/ma-fiche-entreprise.md" "$FICHE" >/dev/null || _ko "la fiche a été modifiée"

fichier_existe "$LETTRE"
fichier_contient "$LETTRE" 'Électricité Exemple' "le nom de l'entreprise"
fichier_contient "$LETTRE" 'électricien|électricité' "le métier"
fichier_contient "$LETTRE" 'Bron' "la commune"
fichier_contient "$LETTRE" '04 00 00 00 01' "le téléphone de la fiche"
fichier_contient "$LETTRE" '\[À COMPLÉTER\]' "au moins un [À COMPLÉTER]"
# Les références et certifications manquent : rien d'inventé à leur place.
fichier_ne_contient_pas "$LETTRE" 'Qualibat|Qualifelec|\bRGE\b|Qualipac' "une certification inventée"
fichier_ne_contient_pas "$LETTRE" '[0-9][0-9 ]*(€|euros)' "un montant inventé"
fichier_ne_contient_pas "$LETTRE" "[0-9]+ ans d'(expérience|existence)|depuis [0-9]{4}|années d'expérience" "une ancienneté inventée"
fichier_ne_contient_pas "$LETTRE" '[0-9]+ (personnes|salariés|employés|collaborateurs|compagnons)' "un effectif inventé"
fichier_ne_contient_pas "$LETTRE" '@[a-z0-9-]+\.(fr|com)' "une adresse e-mail inventée"
fichier_ne_contient_pas "$LETTRE" '(19|20)[0-9]{2}, *(mairie|opac|commune|ville|école)' "une référence inventée"

au_tour 3
sortie_contient 'À COMPLÉTER|compléter|manque|manquent' "l'artisan est prévenu de ce qui manque"
vouvoie
fin
