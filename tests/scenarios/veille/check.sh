# Veille : fiche remplie (plomberie et chauffage, départements 69 et 01), API du BOAMP appelée en direct.
# Vérifications souples : on contrôle le suivi et la réponse, puis chaque consultation dans l'API.
source "$ROOT/tests/lib.sh"
source "$ROOT/tests/scenarios/veille/outils.sh"

# La fiche n'est pas modifiée ; le suivi garde ses deux lignes de départ.
diff -q "$ROOT/tests/scenarios/veille/dossier/ma-fiche-entreprise.md" "$D/ma-fiche-entreprise.md" >/dev/null || _ko "la fiche a été modifiée"
suivi_garde_le_depart

# Au plus 10 consultations, au statut « repérée », sans doublon, présentées dans la réponse.
suivi_sans_doublon 10
reponse_presente_le_suivi

# Travaux, appel à la concurrence, zone (69 ou 01, écrit « 1 » dans l'API), date limite >= J+10.
verifie_dans_api '69|1'

# La réponse : acheteur, lien vers l'avis, rappel sur les petits marchés, pas de code technique.
sortie_contient 'boamp\.fr' "le lien vers l'avis"
sortie_contient 'acheteur|commune|mairie|département|région|office|centre hospitalier|CHU|communauté|métropole' "l'acheteur de chaque consultation"
sortie_contient 'date limite|avant le|jusqu.au|limite' "la date limite"
sortie_contient 'DCE' "où récupérer le DCE"
sortie_contient 'petits march[ée]s|pas tous publi|sans publicit|ne sont pas tous' "le rappel sur les petits marchés"
sortie_ne_contient_pas 'descripteur_code|type_marche|nature_categorise|datelimitereponse|ODSQL|curl' "du jargon technique"
vouvoie
fin
