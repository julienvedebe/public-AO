# Mémoire technique sur Mac, avec un cadre de réponse technique (CRT) fourni par l'acheteur dans le DCE et imposé par
# le RC (article 10). L'artisan donne une partie de ses réponses en un seul message, dont un prix qui ne doit apparaître
# nulle part. Attendu : notre mémoire (qui suit la trame du cadre) ET une copie du cadre de l'acheteur remplie, avec ses
# rubriques intactes et dans l'ordre, les réponses au bon endroit, les [À COMPLÉTER] surlignés, rien d'inventé.
# Puis le script cadre-acheteur-mac.sh est essayé directement (cas nominal, refus d'écraser, ancre fausse, limite de
# caractères, formats refusés, .doc converti).
source "$ROOT/tests/lib.sh"
source "$ROOT/tests/scenarios/memoire/outils.sh"
source "$ROOT/tests/scenarios/memoire-cadre-acheteur/outils-cadre.sh"
SC="$ROOT/tests/scenarios/memoire-cadre-acheteur"
C="$D/$CONSULT_REL"
SCRIPT="$ROOT/skill/marches-publics/scripts/cadre-acheteur-mac.sh"

# ---------- Conversation ----------

# Les fichiers de l'artisan ne sont pas touchés (fiche, suivi, analyse, DCE et cadre de l'acheteur compris).
diff -q "$SC/dossier/ma-fiche-entreprise.md" "$D/ma-fiche-entreprise.md" >/dev/null || _ko "la fiche a été modifiée"
diff -q "$SC/dossier/suivi.md" "$D/suivi.md" >/dev/null || _ko "le suivi a été modifié"
diff -q "$SC/dossier/$CONSULT_REL/analyse.md" "$C/analyse.md" >/dev/null || _ko "l'analyse a été modifiée"
diff -rq "$SC/dossier/$CONSULT_REL/dce" "$C/dce" >/dev/null || _ko "le DCE (ou le cadre de l'acheteur qu'il contient) a été modifié"

# Le cadre rempli, à côté de notre mémoire.
K="$C/memoire-technique-cadre-acheteur.docx"
[ -f "$K" ] || K=$(find "$C" -maxdepth 1 -iname '*cadre*.docx' | head -1)
[ -n "$K" ] && [ -f "$K" ] || { _ko "aucun cadre de l'acheteur rempli (.docx) dans le sous-dossier de la consultation"; fin; }
docx_valide "$K"
docx_surligne "$K"
cadre_intact "$K"
TK=$(texte_du_fichier "$K")
SK=$(sans_a_completer <<< "$TK")
reponses_aux_bons_endroits "$TK" "cadre rempli"
memoire_sans_invention "$SK" "$TK"
memoire_sans_prix "$TK"
grep -q '70 \?000' <<< "$TK" && _ko "le prix de l'artisan figure dans le cadre rempli"
grep -qiE 'benne|déchetterie|tri sélectif|balisage|8 h à 17 h' <<< "$SK" && _ko "déchets ou nuisances inventés dans le cadre : $(grep -oiE 'benne|déchetterie|tri sélectif|balisage|8 h' <<< "$SK" | head -1)"

# Notre mémoire existe aussi et suit la trame du cadre.
M="$C/memoire-technique.docx"
[ -f "$M" ] || M=$(find "$C" -maxdepth 1 -name 'memoire*.docx' ! -iname '*cadre*' | head -1)
if [ -n "$M" ] && [ -f "$M" ]; then
  docx_valide "$M"
  docx_surligne "$M"
  TM=$(texte_du_fichier "$M")
  for r in 'Méthodologie et organisation' 'Composition de l' 'Matériel et véhicules' 'isoler le chantier' 'tri des déchets' 'insertion professionnelle'; do
    grep -qiE "$r" <<< "$TM" || _ko "notre mémoire ne reprend pas la rubrique du cadre : $r"
  done
  a=$(ligne_de "$TM" 'Composition de l'); b=$(ligne_de "$TM" 'tri des déchets')
  [ -n "$a" ] && [ -n "$b" ] && [ "$a" -lt "$b" ] || _ko "notre mémoire ne suit pas l'ordre du cadre"
  memoire_sans_invention "$(sans_a_completer <<< "$TM")" "$TM"
  memoire_sans_prix "$TM"
  grep -q '70 \?000' <<< "$TM" && _ko "le prix de l'artisan figure dans notre mémoire"
else
  _ko "notre mémoire (memoire-technique.docx) est absent du sous-dossier de la consultation"
fi

# Réponse : le cadre est signalé, son usage obligatoire, le prix laissé à l'artisan.
toute_la_conversation
vouvoie
sortie_contient 'cadre' "le cadre de l'acheteur signalé"
sortie_contient 'obligatoire|impos' "l'usage obligatoire du cadre (RC, article 10)"
sortie_contient 'compléter' "ce qu'il reste à compléter"
sortie_contient 'prix' "le rappel que le prix reste à l'artisan"

# ---------- Essais directs du script ----------
TMP=$(mktemp -d)

l=$(bash "$SCRIPT" lister "$ORIG" 2>&1); code=$?
[ "$code" -eq 0 ] || _ko "lister : code $code au lieu de 0"
grep -qF '¶17 [tableau 1, ligne 2, cellule 2] | (vide)' <<< "$l" || _ko "lister : la case réponse du tableau n'est pas repérée"
grep -qF '¶6 {Heading2} | 1.1 Décrivez' <<< "$l" || _ko "lister : la question 1.1 et son style ne sont pas affichés"
grep -qx 'PARAGRAPHES 29' <<< "$l" || _ko "lister : nombre de paragraphes inattendu"

sortie=$(bash "$SCRIPT" remplir "$ORIG" "$SC/essai-reponses.txt" "$TMP/ok.docx" 2>&1); code=$?
[ "$code" -eq 0 ] || _ko "remplir : code $code au lieu de 0 : $sortie"
tail -1 <<< "$sortie" | grep -qE '^CADRE .*ok\.docx 7 4$' || _ko "remplir : dernière ligne inattendue : $(tail -1 <<< "$sortie")"
if [ -f "$TMP/ok.docx" ]; then
  docx_valide "$TMP/ok.docx"
  docx_surligne "$TMP/ok.docx"
  cadre_intact "$TMP/ok.docx"
  reponses_aux_bons_endroits "$(texte_du_fichier "$TMP/ok.docx")" "essai direct"
  [ "$(unzip -p "$TMP/ok.docx" word/document.xml | grep -o '<w:highlight w:val="yellow"/>' | wc -l | tr -d ' ')" -eq 4 ] ||
    _ko "essai direct : 4 surlignages attendus"
fi
cmp -s "$ORIG" "$SC/dossier/$CONSULT_REL/dce/DCE_2026-ECOLE-07/07_CRT_Cadre-de-reponse-technique_Lot-05.docx" || _ko "le cadre de la fixture diffère de cadre-acheteur.docx"

bash "$SCRIPT" remplir "$ORIG" "$SC/essai-reponses.txt" "$TMP/ok.docx" >/dev/null 2>&1; [ $? -eq 4 ] || _ko "remplir écrase un fichier existant"

# Les mêmes blocs dans l'ordre inverse donnent le même document (l'ordre du fichier de réponses ne compte pas).
perl -0ne 'print join "\n", reverse split /(?=^### )/m' "$SC/essai-reponses.txt" > "$TMP/inverse.txt"
bash "$SCRIPT" remplir "$ORIG" "$TMP/inverse.txt" "$TMP/inverse.docx" >/dev/null 2>&1 || _ko "remplir : blocs dans l'ordre inverse refusés"
[ -f "$TMP/inverse.docx" ] && ! cmp -s <(unzip -p "$TMP/ok.docx" word/document.xml) <(unzip -p "$TMP/inverse.docx" word/document.xml) &&
  _ko "remplir : l'ordre des blocs dans le fichier de réponses change le résultat"

printf '### 9 | 1.1 Décrivez\nx\n' > "$TMP/ancre.txt"
bash "$SCRIPT" remplir "$ORIG" "$TMP/ancre.txt" "$TMP/ancre.docx" >/dev/null 2>&1; code=$?
[ "$code" -eq 6 ] || _ko "ancre fausse : code $code au lieu de 6"
[ ! -e "$TMP/ancre.docx" ] || _ko "ancre fausse : un fichier est quand même produit"

printf '### 99\nx\n' > "$TMP/absent.txt"
bash "$SCRIPT" remplir "$ORIG" "$TMP/absent.txt" "$TMP/absent.docx" >/dev/null 2>&1; [ $? -eq 6 ] || _ko "paragraphe inexistant : le code n'est pas 6"

printf '### 8\n@max 20\nUne réponse bien plus longue que vingt caractères.\n' > "$TMP/limite.txt"
bash "$SCRIPT" remplir "$ORIG" "$TMP/limite.txt" "$TMP/limite.docx" >/dev/null 2>&1; code=$?
[ "$code" -eq 6 ] || _ko "limite de caractères dépassée : code $code au lieu de 6"
[ ! -e "$TMP/limite.docx" ] || _ko "limite dépassée : un fichier est quand même produit"

for e in xlsx pdf; do
  cp "$ORIG" "$TMP/cadre.$e"
  bash "$SCRIPT" remplir "$TMP/cadre.$e" "$SC/essai-reponses.txt" "$TMP/$e.docx" >/dev/null 2>&1; code=$?
  [ "$code" -eq 5 ] || _ko "format .$e : code $code au lieu de 5"
done
bash "$SCRIPT" remplir "$TMP/introuvable.docx" "$SC/essai-reponses.txt" "$TMP/x.docx" >/dev/null 2>&1; [ $? -eq 2 ] || _ko "cadre introuvable : le code n'est pas 2"

# Un cadre en .doc (fabriqué ici avec textutil) est converti, rempli, et la conversion est signalée.
textutil -convert doc "$ORIG" -output "$TMP/cadre.doc" 2>/dev/null
sortie=$(bash "$SCRIPT" remplir "$TMP/cadre.doc" "$SC/essai-reponses.txt" "$TMP/doc.docx" 2>&1); code=$?
[ "$code" -eq 0 ] || _ko "cadre .doc : code $code au lieu de 0 : $sortie"
grep -qx 'CONVERTI doc' <<< "$sortie" || _ko "cadre .doc : la conversion n'est pas signalée"
[ -f "$TMP/doc.docx" ] && docx_surligne "$TMP/doc.docx"

rm -rf "$TMP"
fin
