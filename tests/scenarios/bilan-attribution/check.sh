# Bilan avec attribution publiée dans les DECP : marché réel de la commune de Bron
# (« REFECTION TOITURE CLASSES ECOLE PRIMAIRE JEAN JAURES », 79 601,40 € HT, notifié le 23/05/2026,
# titulaire GIBERT à Chassieu, SIRET 38417986700039). DECP et Recherche d'entreprises appelés en direct.
source "$ROOT/tests/lib.sh"
SUIVI="$D/suivi.md"
SOUS="$D/consultations/2026-04_commune-de-bron_toiture-ecole-jean-jaures"

diff -q "$ROOT/tests/scenarios/bilan-attribution/dossier/ma-fiche-entreprise.md" "$D/ma-fiche-entreprise.md" >/dev/null || _ko "la fiche a été modifiée"

# Tour 1 : titulaire avec son nom (pas seulement le SIRET), montant, date, courrier.
au_tour 1
sortie_contient 'GIBERT' "le nom de l'entreprise retenue"
sortie_contient '79 ?601' "le montant du marché"
sortie_contient '23/05/2026|23 mai 2026|2026-05-23' "la date de notification"
sortie_contient 'perdue|perdu' "le statut perdue"
sortie_contient 'courrier' "le courrier de demande des motifs"
sortie_ne_contient_pas 'descripteur|idweb|ODSQL|curl' "du jargon technique"
vouvoie
une_seule_question
COURRIER=$(find "$SOUS" -maxdepth 1 -iname '*motifs*' | head -1)
[ -n "$COURRIER" ] || { _ko "courrier de demande des motifs absent du sous-dossier de la consultation"; COURRIER=/dev/null; }
fichier_contient "$COURRIER" 'Bron' "l'acheteur"
fichier_contient "$COURRIER" 'Plomberie Exemple' "le nom de l'entreprise"
fichier_contient "$COURRIER" 'motifs' "la demande des motifs"

# Tour 2 : leçons de l'artisan notées, statut bilan fait, titulaire noté avec son nom.
au_tour 2
sortie_contient 'bilan|leçons' "la clôture du bilan"
vouvoie
LIGNES=$(sed -n '/^|/p' "$SUIVI")
[ "$(grep -ci 'Jean-Jaur' <<< "$LIGNES")" -eq 1 ] || _ko "la consultation n'a pas une seule ligne dans le tableau"
grep -i 'Jean-Jaur' <<< "$LIGNES" | grep -qi 'bilan fait' || _ko "le suivi n'indique pas bilan fait"
fichier_contient "$SUIVI" 'GIBERT' "le titulaire retenu, par son nom"
fichier_contient "$SUIVI" '79 ?601' "le montant du marché"
LECONS=$(rubrique "$SUIVI" "Leçons")
grep -qiE 'prix' <<< "$LECONS" || _ko "leçon sur le prix absente"
grep -qiE 'visite' <<< "$LECONS" || _ko "leçon sur la visite absente"
fin
