# Premier lancement : pas de dossier de travail, pas de fiche.
source "$ROOT/tests/lib.sh"

dossier_existe "$D/mes-justificatifs"
dossier_existe "$D/consultations"
fichier_existe "$D/suivi.md"
fichier_absent "$D/ma-fiche-entreprise.md"

sortie_contient 'fiche' "l'état de la fiche entreprise"
sortie_contient 'pas encore|aucune fiche|pas de fiche|n.a pas encore|n.existe pas' "la fiche n'est pas remplie"
sortie_contient '(^|[^0-9])1[.)]' "un menu numéroté (1)"
sortie_contient '(^|[^0-9])7[.)]' "un menu numéroté (7)"
sortie_contient 'consultations' "l'étape de veille dans le menu"
sortie_contient 'm[ée]moire' "l'étape mémoire technique dans le menu"
vouvoie
fin
