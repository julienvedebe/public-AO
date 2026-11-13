# Analyse d'un DCE fictif (ZIP déposé) à partir d'une fiche complète de plombier.
source "$ROOT/tests/lib.sh"
SC="$ROOT/tests/scenarios/analyse"

# Les fichiers de l'artisan ne sont pas touchés.
diff -q "$SC/dossier/ma-fiche-entreprise.md" "$D/ma-fiche-entreprise.md" >/dev/null || _ko "la fiche a été modifiée"
fichier_existe "$D/dce-ecole-val-de-brelle.zip"

# Sous-dossier de consultation créé, DCE décompressé.
C=$(ls -d "$D"/consultations/*/ 2>/dev/null | grep -i 'val-de-brelle' | head -1)
C=${C%/}
[ -n "$C" ] || { _ko "pas de sous-dossier de consultation pour Val-de-Brelle"; fin; }
basename "$C" | grep -qE '^2027-01_[a-z0-9-]*val-de-brelle[a-z0-9-]*_' || _ko "nom de sous-dossier inattendu : $(basename "$C")"
[ "$(find "$C" -iname '*.pdf' | wc -l | tr -d ' ')" -ge 6 ] || _ko "le DCE n'est pas décompressé (moins de 6 PDF)"
find "$C" -iname '*Lot-05*Plomberie*.pdf' | grep -q . || _ko "CCTP du lot plomberie introuvable après décompression"

# Fichier d'analyse.
A=$(find "$C" -maxdepth 1 -iname '*analyse*.md' | head -1)
[ -n "$A" ] || { _ko "fichier d'analyse absent de la consultation"; fin; }

# Un seul verdict, l'un des trois, et pas 🟢 : une certification exigée manque à la fiche.
V=$(rubrique "$A" "Verdict")
n=0
for e in 🟢 🟠 🔴; do grep -q "$e" <<< "$V" && n=$((n + 1)); done
[ "$n" -eq 1 ] || _ko "la rubrique Verdict contient $n verdicts au lieu d'un seul"
grep -q '🟢' <<< "$V" && _ko "verdict 🟢 alors que la certification Qualigaz manque à la fiche"

# Chaque date de la fixture est accompagnée d'un nom de document (RC) sur la même ligne.
date_sourcee() { # <description> <regex de la date>
  grep -iE "$2" "$A" | grep -qiE 'RC|règlement' || _ko "date sans source (RC) : $1"
}
date_sourcee "visite du 8 décembre 2026" '(8 décembre 2026|0?8/12/2026)'
date_sourcee "questions du 4 janvier 2027" '(4 janvier 2027|0?4/01/2027)'
date_sourcee "remise du 15 janvier 2027" '(15 janvier 2027|15/01/2027)'
grep -qiE '(CCAP|CCTP|RC|règlement).{0,20}(art|p\.|page)' "$A" || _ko "aucune citation d'article ou de page"

# Visite obligatoire signalée, exigence manquante signalée, pièges, critères.
fichier_contient "$A" 'visite.{0,60}obligatoire|obligatoire.{0,60}visite' "la visite obligatoire"
sortie_contient 'visite' "la visite dans la réponse"
fichier_contient "$A" 'Qualigaz' "l'exigence Qualigaz"
grep -iE 'Qualigaz' "$A" | grep -qiE '❌|manque|absent|pas dans|ne figure|non' || _ko "l'exigence Qualigaz n'est pas signalée comme non remplie"
fichier_contient "$A" '300 ?(€|euros)' "la pénalité de retard du CCAP"
fichier_contient "$A" '5 ?%' "la retenue de garantie ou les pondérations"
fichier_contient "$A" 'variante' "les variantes interdites"
fichier_contient "$A" '50 ?%' "le poids du critère valeur technique"
fichier_contient "$A" '40 ?%' "le poids du critère prix"

# Rappel de vérification sur la plateforme, dans le fichier et dans la réponse.
fichier_contient "$A" 'plateforme' "le rappel plateforme"
fichier_contient "$A" 'vérifi' "le rappel de vérification"
sortie_contient 'vérifi.{0,120}(plateforme|site)|(plateforme|site).{0,120}vérifi' "le rappel de vérifier les dates sur la plateforme (ou le site) de l'acheteur"

# Résumé et réponse.
sortie_contient '🟠|🔴' "le verdict dans la réponse"
vouvoie

# Suivi : la ligne de la consultation passe à « analysée » avec un verdict.
L=$(grep -i 'val-de-brelle' "$D/suivi.md")
grep -qi 'analysée' <<< "$L" || _ko "le suivi n'indique pas le statut analysée"
grep -qE '🟢|🟠|🔴' <<< "$L" || _ko "le suivi n'indique pas le verdict"
[ "$(grep -ci 'val-de-brelle' "$D/suivi.md")" -eq 1 ] || _ko "la consultation apparaît plusieurs fois dans le suivi"

# Aucun prix proposé.
PRIX='(proposer|facturer|chiffrer|demander) (un|le|ce) (prix|montant|tarif)|prix (conseillé|recommandé|à proposer|à pratiquer)|je (vous )?(propose|conseille|recommande) .{0,40}[0-9] ?(€|euros)'
fichier_ne_contient_pas "$A" "$PRIX" "un prix proposé"
sortie_ne_contient_pas "$PRIX" "un prix proposé"
fin
