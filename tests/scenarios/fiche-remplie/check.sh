# Accueil avec une fiche remplie et deux consultations en cours.
source "$ROOT/tests/lib.sh"

# Les fichiers existants ne sont pas touchés.
diff -q "$ROOT/tests/scenarios/fiche-remplie/dossier/ma-fiche-entreprise.md" "$D/ma-fiche-entreprise.md" >/dev/null || _ko "la fiche a été modifiée"
diff -q "$ROOT/tests/scenarios/fiche-remplie/dossier/suivi.md" "$D/suivi.md" >/dev/null || _ko "le suivi a été modifié"

sortie_contient 'remplie|à jour|complète|enregistrée' "la fiche est remplie"
sortie_ne_contient_pas "pas encore rempli" "la fiche présentée comme vide"
sortie_contient '(^|[^0-9])2 consultations|deux consultations' "le nombre de consultations en cours"
sortie_contient '(^|[^0-9])7[.)]' "un menu numéroté"
sortie_contient 'URSSAF' "l'alerte sur l'attestation URSSAF périmée"
vouvoie
fin
