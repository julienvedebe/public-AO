# Métier absent de la table : l'agent cherche les descripteurs dans l'API du BOAMP.
source "$ROOT/tests/lib.sh"
F="$D/ma-fiche-entreprise.md"

au_tour 1
sortie_contient 'piscine' "le descripteur trouvé, dit à l'artisan"

rubrique "$F" "Métiers" | grep -qi 'piscin' || _ko "métier pisciniste absent de la fiche"
rubrique "$F" "Métiers" | grep -qE '(^|[^0-9])265 Piscine' || _ko "descripteur 265 Piscine absent"
rubrique "$F" "Métiers" | grep -q '270 Plomberie' || _ko "les descripteurs existants ont disparu"

toute_la_conversation
vouvoie
fin
