# Se faire connaître avec une fiche complète : seuil expliqué, liste d'acheteurs
# des départements de la fiche (69 et 01), lettre fondée sur la fiche seule.
source "$ROOT/tests/lib.sh"
FICHE="$D/ma-fiche-entreprise.md"
LETTRE="$D/se-faire-connaitre/lettre-de-presentation.md"
LISTE="$D/se-faire-connaitre/acheteurs.md"

# La fiche n'est pas modifiée.
diff -q "$ROOT/tests/scenarios/se-faire-connaitre/dossier/ma-fiche-entreprise.md" "$FICHE" >/dev/null || _ko "la fiche a été modifiée"

# Le seuil est expliqué (tour 1).
au_tour 1
sortie_contient '100 ?000' "le seuil de 100 000 €"
sortie_contient 'sans (publicité|annonce|publication)|directement' "la consultation directe sans publicité"
vouvoie

# La liste d'acheteurs vient des départements de la fiche (tour 2).
au_tour 2
sortie_contient 'Lyon|Villeurbanne|Vénissieux|Rhône|Bron' "des acheteurs du Rhône (69)"
sortie_contient '\bAin\b|Bourg|Bresse|Dombes|Miribel|Montluel|\bGex\b|Divonne' "des acheteurs de l'Ain (01)"
sortie_ne_contient_pas 'Paris|Marseille|Bordeaux|Toulouse|Lille' "des acheteurs hors des départements de la fiche"
fichier_existe "$LISTE"

# La lettre existe et reprend la fiche.
fichier_existe "$LETTRE"
fichier_contient "$LETTRE" 'Plomberie Exemple' "le nom de l'entreprise"
fichier_contient "$LETTRE" 'plombier|plomberie' "le métier"
fichier_contient "$LETTRE" 'Qualibat' "la certification Qualibat"
fichier_contient "$LETTRE" 'QualiPAC' "la certification QualiPAC"
fichier_contient "$LETTRE" 'Mairie de Bron' "la référence de Bron"
fichier_contient "$LETTRE" 'OPAC du Rhône' "la référence de l'OPAC"
fichier_contient "$LETTRE" 'Dombes' "la référence de la Dombes"
fichier_contient "$LETTRE" 'contact@plomberie-exemple\.fr|04 00 00 00 00' "les coordonnées"
fichier_contient "$LETTRE" 'services techniques' "l'adresse aux services techniques"

# Aucun fait absent de la fiche.
fichier_ne_contient_pas "$LETTRE" "[0-9]+ ans d'(expérience|existence)|depuis [0-9]{4}|années d'expérience" "une ancienneté inventée"
fichier_ne_contient_pas "$LETTRE" "(5|[6-9]|[1-9][0-9]+) (personnes|salariés|employés|collaborateurs|compagnons)" "un effectif inventé"
fichier_ne_contient_pas "$LETTRE" "420 ?000|395 ?000|360 ?000|chiffre d'affaires" "le chiffre d'affaires, qui n'a pas sa place dans la lettre"
fichier_ne_contient_pas "$LETTRE" "leader|incontournable|irréprochable|n°1|numéro 1" "des superlatifs"
# Chaque montant en euros de la lettre figure dans la fiche.
for m in $(grep -oE '[0-9][0-9 ]*[0-9] ?(€|euros)' "$LETTRE" 2>/dev/null | grep -oE '[0-9]+( [0-9]+)*' | tr -d ' ' | sort -u); do
  tr -d ' ' < "$FICHE" | grep -q "$m" || _ko "montant absent de la fiche dans la lettre : $m"
done
# Chaque année citée est une année de la fiche.
for a in $(grep -oE '(19|20)[0-9]{2}' "$LETTRE" | sort -u); do
  grep -q "$a" "$FICHE" || [ "$a" = "$(date +%Y)" ] || _ko "année absente de la fiche dans la lettre : $a"
done

# L'agent n'envoie rien.
toute_la_conversation
sortie_ne_contient_pas "(j'ai|je l'ai) (envoyé|expédié)" "un envoi par l'agent"
fin
