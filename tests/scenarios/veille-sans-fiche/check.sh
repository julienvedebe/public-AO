# Veille sans fiche entreprise : l'agent renvoie vers la fiche, ne cherche rien et ne note rien dans le suivi.
source "$ROOT/tests/lib.sh"

fichier_absent "$D/ma-fiche-entreprise.md"
fichier_ne_contient_pas "$D/suivi.md" 'repérée' "une consultation repérée sans fiche"
fichier_ne_contient_pas "$D/suivi.md" 'idweb:' "un lien d'avis dans le suivi"

sortie_contient 'fiche|métier' "le renvoi vers la fiche entreprise"
sortie_contient 'm[ée]tier|où vous travaillez|départements?|zone' "ce qui manque pour chercher"
sortie_ne_contient_pas 'boamp\.fr/pages/avis' "un avis présenté sans fiche"
une_seule_question
vouvoie
fin
