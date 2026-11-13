# Deuxième veille : le suivi ne reçoit aucune consultation en double.
# Tour 1 : première veille. Tour 2 : l'artisan en redemande.
source "$ROOT/tests/lib.sh"
source "$ROOT/tests/scenarios/veille/outils.sh"

suivi_garde_le_depart

# Après les deux veilles : jamais deux lignes pour le même avis, chaque ligne « repérée ».
# (Au plus 10 par veille, donc 20 au total.)
suivi_sans_doublon 20
verifie_dans_api '69|1'

# Le premier tour présente des consultations ; le second parle de ce qui est nouveau ou déjà suivi.
# L'absence de doublon se contrôle dans le suivi, pas sur la formulation de la réponse.
au_tour 1
sortie_contient 'boamp\.fr' "le lien vers l'avis (tour 1)"
au_tour 2
sortie_contient 'déjà|rien de nouveau|nouvelle|nouveau|autre' "le second tour parle de ce qui est nouveau ou déjà suivi"
sortie_contient 'petits march[ée]s|pas tous publi|sans publicit|ne sont pas tous|rien de nouveau|nouvelle' "une réponse complète au second tour"

toute_la_conversation
vouvoie
fin
