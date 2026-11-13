# Suivi et bilan : « j'ai déposé », « où j'en suis ? », « j'ai perdu » (consultation fictive,
# introuvable dans les DECP), puis les leçons. Quatre tours.
source "$ROOT/tests/lib.sh"
SUIVI="$D/suivi.md"
SOUS="$D/consultations/2027-01_commune-de-val-de-brelle_lot-05-plomberie"
SC="$ROOT/tests/scenarios/bilan/dossier"

# La fiche et l'analyse ne sont pas touchées.
diff -q "$SC/ma-fiche-entreprise.md" "$D/ma-fiche-entreprise.md" >/dev/null || _ko "la fiche a été modifiée"
diff -q "$SC/consultations/2027-01_commune-de-val-de-brelle_lot-05-plomberie/analyse.md" "$SOUS/analyse.md" >/dev/null || _ko "l'analyse a été modifiée"

# Tour 1 : « j'ai déposé » est compris.
au_tour 1
sortie_contient 'déposée|déposé' "la confirmation du statut déposée"
vouvoie
une_seule_question

# Tour 2 : vue d'ensemble, les deux consultations avec leur statut.
au_tour 2
sortie_contient 'Val-de-Brelle' "la consultation de Val-de-Brelle"
sortie_contient 'Bron' "la consultation de Bron"
sortie_contient 'déposée' "le statut déposée"
sortie_contient 'repérée' "le statut repérée"
sortie_ne_contient_pas 'descripteur|idweb|\|---' "du jargon ou un tableau brut"
vouvoie
une_seule_question

# Tour 3 : perdue, courrier de demande des motifs, absence de données signalée sans invention.
au_tour 3
sortie_contient 'perdue|perdu' "le statut perdue"
sortie_contient 'motifs' "la demande des motifs de rejet"
sortie_contient 'courrier' "le courrier"
sortie_contient "pas (pu |encore )?(trouv|publi|identifi)|introuvable|aucun (march|donn|résultat)|n.ai (rien|pas) trouv|absen|aucune (donn|trace)" "l'absence de données d'attribution"
sortie_ne_contient_pas '[0-9]{14}|[0-9]{3} ?[0-9]{3} ?[0-9]{3} ?[0-9]{5}' "un SIRET dans la réponse"
vouvoie
une_seule_question
COURRIER=$(find "$SOUS" -maxdepth 1 -iname '*motifs*' | head -1)
[ -n "$COURRIER" ] || { _ko "courrier de demande des motifs absent du sous-dossier de la consultation"; COURRIER=/dev/null; }
fichier_contient "$COURRIER" 'Val-de-Brelle' "l'acheteur"
fichier_contient "$COURRIER" 'motifs' "la demande des motifs"
fichier_contient "$COURRIER" 'Plomberie Exemple' "le nom de l'entreprise"
fichier_contient "$COURRIER" 'Marcel-Pagnol|sanitaires' "l'objet de la consultation"
fichier_contient "$COURRIER" 'À COMPLÉTER' "les informations inconnues marquées [À COMPLÉTER]"
fichier_ne_contient_pas "$COURRIER" '[0-9]{2} ?[0-9]{3} ?(€|euros)' "un montant inventé"

# Tour 4 : leçons notées, statut bilan fait.
au_tour 4
sortie_contient 'bilan|leçons' "la clôture du bilan"
vouvoie

# Suivi final : la ligne de Val-de-Brelle est « bilan fait » ; celle de Bron est intacte.
LIGNES=$(sed -n '/^|/p' "$SUIVI")
[ "$(grep -c 'Val-de-Brelle' <<< "$LIGNES")" -eq 1 ] || _ko "la consultation de Val-de-Brelle n'a pas une seule ligne dans le tableau"
grep 'Val-de-Brelle' <<< "$LIGNES" | grep -qi 'bilan fait' || _ko "le suivi n'indique pas bilan fait pour Val-de-Brelle"
grep -q 'Mairie de Bron.*repérée' "$SUIVI" || _ko "la ligne de Bron a changé"
LECONS=$(rubrique "$SUIVI" "Leçons")
[ -n "$LECONS" ] || _ko "pas de section Leçons dans le suivi"
grep -qiE 'prix' <<< "$LECONS" || _ko "leçon sur le prix absente"
grep -qiE 'attestation' <<< "$LECONS" || _ko "leçon sur l'attestation d'assurance absente"
grep -qiE 'veille|vérifi' <<< "$LECONS" || _ko "leçon sur la vérification des pièces absente"
# Aucun titulaire ni montant inventé dans le suivi.
fichier_ne_contient_pas "$SUIVI" '[0-9]{14}|[0-9] ?(€|euros)' "un SIRET ou un montant dans le suivi"
! grep -i 'titulaire' "$SUIVI" | grep -viE 'non |pas |aucun|introuvable|inconnu|absent' | grep -q . || _ko "un titulaire figure dans le suivi alors qu'il est introuvable"
fin
