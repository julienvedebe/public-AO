# Consultation seulement repérée : l'agent ne prépare pas le dossier et propose d'abord l'analyse.
source "$ROOT/tests/lib.sh"
SC="$ROOT/tests/scenarios/dossier-non-analysee"

# Rien n'est créé ni modifié.
diff -q "$SC/dossier/suivi.md" "$D/suivi.md" >/dev/null || _ko "le suivi a été modifié"
diff -q "$SC/dossier/ma-fiche-entreprise.md" "$D/ma-fiche-entreprise.md" >/dev/null || _ko "la fiche a été modifiée"
[ -z "$(find "$D" -iname 'pieces-et-retroplanning.md' 2>/dev/null)" ] || _ko "un dossier de réponse a été produit pour une consultation non analysée"
grep -qi 'en préparation' "$D/suivi.md" && _ko "le statut est passé à en préparation"

sortie_contient 'analys' "la proposition d'analyser le dossier de consultation d'abord"
vouvoie
une_seule_question
fin
