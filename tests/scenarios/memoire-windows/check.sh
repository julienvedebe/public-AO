# Mémoire technique sous WINDOWS : même conversation que le scénario « memoire » (quatre tours, l'artisan ne donne
# qu'une partie des informations), puis essais directs des scripts PowerShell memoire-vers-docx-windows.ps1 et
# cadre-acheteur-windows.ps1 (remplissage du cadre de l'acheteur, sur le cadre fictif du scénario memoire-cadre-acheteur).
# À lancer sous Windows (Git Bash ou WSL, voir outils-windows.sh) : ce scénario n'a pas pu être exécuté sur la
# machine de développement (Mac, sans PowerShell).
source "$ROOT/tests/lib.sh"
source "$ROOT/tests/scenarios/memoire/outils.sh"
source "$ROOT/tests/scenarios/memoire-windows/outils-windows.sh"
source "$ROOT/tests/scenarios/memoire-cadre-acheteur/outils-cadre.sh"
SC="$ROOT/tests/scenarios/memoire-windows"
C="$D/$CONSULT_REL"

[ -n "$PS_EXE" ] || { _ko "PowerShell (powershell.exe) est introuvable : ce scénario se lance sous Windows"; fin; }

# Les fichiers de l'artisan ne sont pas touchés (fiche, suivi, analyse, DCE).
diff -q "$SC/dossier/ma-fiche-entreprise.md" "$D/ma-fiche-entreprise.md" >/dev/null || _ko "la fiche a été modifiée"
diff -q "$SC/dossier/suivi.md" "$D/suivi.md" >/dev/null || _ko "le suivi a été modifié"
diff -q "$SC/dossier/$CONSULT_REL/analyse.md" "$C/analyse.md" >/dev/null || _ko "l'analyse a été modifiée"
diff -rq "$SC/dossier/$CONSULT_REL/dce" "$C/dce" >/dev/null || _ko "le DCE a été modifié"

# Une seule question à la fois, aux trois premiers tours.
for t in 1 2 3; do au_tour $t; une_seule_question; sortie_contient '\?' "une question au tour $t"; done
au_tour 1
sortie_contient 'méthodologie|moyens humains|nuisances' "les critères du règlement dans la première réponse"

# Le mémoire est produit au dernier tour, dans le sous-dossier de la consultation.
toute_la_conversation
vouvoie
M="$C/memoire-technique.docx"
[ -f "$M" ] || M=$(find "$C" -maxdepth 1 -name 'memoire*.docx' | head -1)
[ -n "$M" ] && [ -f "$M" ] || { _ko "aucun .docx de mémoire dans le sous-dossier de la consultation"; fin; }
[ "$(find "$C" -maxdepth 1 -name '*.docx' | wc -l | tr -d ' ')" -eq 1 ] || _ko "plusieurs .docx dans le sous-dossier"

# Structure du .docx et surlignage (relus par PowerShell).
docx_valide "$M"
docx_surligne "$M"
T=$(texte_du_fichier "$M")
S=$(sans_a_completer <<< "$T")

# La trame reprend les critères du RC ; la fiche et les réponses sont reprises.
trame_du_rc "$T"
fiche_reutilisee "$T"
grep -qiE 'camionnette' <<< "$T" || _ko "la camionnette de la réponse n'est pas reprise"
grep -qiE 'sert(i|iss)' <<< "$T" || _ko "la machine à sertir de la réponse n'est pas reprise"
grep -qiE 'trois|\b3\b' <<< "$T" || _ko "l'équipe de trois personnes n'est pas reprise"
grep -qiE 'compagnons' <<< "$T" || _ko "les deux compagnons ne sont pas repris"
grep -qiE 'mise en pression' <<< "$T" || _ko "l'essai de mise en pression de la réponse n'est pas repris"
grep -qiE 'dépose' <<< "$T" || _ko "la dépose de la réponse n'est pas reprise"

# Les [À COMPLÉTER] sont là où l'information manque : nuisances, déchets, planning, insertion et environnement.
n=$(grep -o '\[À COMPLÉTER' <<< "$T" | wc -l | tr -d ' ')
[ "$n" -ge 4 ] || _ko "seulement $n [À COMPLÉTER] alors que plusieurs informations manquent"
apres_dernier() { awk -v re="$1" '$0 ~ re { n = NR } { l[NR] = $0 } END { for (i = n; i <= NR && i <= n + 8; i++) print l[i] }' <<< "$T"; }
grep -q 'À COMPLÉTER' <<< "$(apres_dernier '(10 points)')" || _ko "pas de [À COMPLÉTER] dans la section « nuisances et sécurité des enfants »"
grep -q 'À COMPLÉTER' <<< "$(apres_dernier '[Ii]nsertion')" || _ko "pas de [À COMPLÉTER] dans la section insertion et environnement"
grep -qiE 'déchets' <<< "$T" || _ko "la gestion des déchets n'est pas traitée"
grep -qiE 'planning|délai|semaines' <<< "$T" || _ko "le planning n'est pas traité"

# Aucun fait absent de la fiche ou des réponses, aucun prix.
memoire_sans_invention "$S" "$T"
memoire_sans_prix "$T"
grep -qiE 'benne|déchetterie|tri sélectif|balisage|de 8 h|8 h à 17 h' <<< "$S" && _ko "déchets, sécurité ou planning inventés : $(grep -oiE 'benne|déchetterie|tri sélectif|balisage|8 h' <<< "$S" | head -1)"

# Les réponses sont gardées dans le sous-dossier (reprise possible dans une autre conversation).
fichier_existe "$C/memoire-reponses.md"
fichier_contient "$C/memoire-reponses.md" 'camionnette' "la réponse sur le matériel dans memoire-reponses.md"

# Réponse finale : ce qui reste à compléter, le chemin, le prix laissé à l'artisan.
au_tour 4
sortie_contient 'compléter' "ce qu'il reste à compléter"
sortie_contient 'surlign|jaune' "le surlignage expliqué"
sortie_contient 'consultations|Val-de-Brelle' "où se trouve le mémoire"
sortie_contient 'prix' "le rappel que le prix reste à l'artisan"

# ---------------------------------------------------------------------------------------------------------------
# Essai direct du script PowerShell, sans l'agent.
TMP=$(mktemp -d)
BOM() { [ "$(head -c 3 "$1" | od -An -tx1 | tr -d ' \n')" = efbbbf ]; }

# 1. Deux pages d'exemple : le .docx produit doit contenir exactement les parties attendues (attendu/<nom>/...),
#    octet pour octet. Elles ont été produites à la main (voir le commit) : une différence veut dire que le script
#    ne produit pas la structure validée sur Mac (xmllint, unzip, textutil).
for ex in exemple exemple-tableau; do
  sortie=$(lancer_script "$SC/attendu/$ex.html" "$TMP/$ex.docx"); code=$?
  [ "$code" -eq 0 ] || { _ko "$ex : le script a rendu le code $code au lieu de 0 : $sortie"; continue; }
  tail -1 <<< "$sortie" | grep -qE "^DOCX .*$ex\.docx [0-9]+$" || _ko "$ex : dernière ligne inattendue : $(tail -1 <<< "$sortie")"
  docx_valide "$TMP/$ex.docx"
  docx_surligne "$TMP/$ex.docx"
  aide extraire "$TMP/$ex.docx" "$TMP/x-$ex" >/dev/null
  nb_attendu=$(find "$SC/attendu/$ex" -type f | wc -l | tr -d ' ')
  nb_obtenu=$(find "$TMP/x-$ex" -type f | wc -l | tr -d ' ')
  [ "$nb_attendu" = "$nb_obtenu" ] || _ko "$ex : $nb_obtenu parties dans le .docx au lieu de $nb_attendu"
  while IFS= read -r -d '' f; do
    r="${f#"$SC/attendu/$ex/"}"
    [ -f "$TMP/x-$ex/$r" ] || { _ko "$ex : partie absente : $r"; continue; }
    cmp -s "$f" "$TMP/x-$ex/$r" || _ko "$ex : $r diffère du fichier attendu"
    ! BOM "$TMP/x-$ex/$r" || _ko "$ex : BOM dans $r"
  done < <(find "$SC/attendu/$ex" -type f -print0)
done
T2=$(texte_du_fichier "$TMP/exemple.docx")
grep -q 'œuvre' <<< "$T2" || _ko "les accents (œ) sont perdus dans le .docx"
grep -q "Plomberie & sanitaires" <<< "$T2" || _ko "l'entité &amp; n'est pas décodée dans le .docx"
grep -q 'Poste' <<< "$(texte_du_fichier "$TMP/exemple-tableau.docx")" || _ko "le tableau est perdu"

# 2. Refus d'écraser (code 4), HTML introuvable (code 2), dossier de sortie absent (code 3).
lancer_script "$SC/attendu/exemple.html" "$TMP/exemple.docx" >/dev/null; [ $? -eq 4 ] || _ko "le script écrase un fichier existant"
lancer_script "$TMP/absent.html" "$TMP/x.docx" >/dev/null; [ $? -eq 2 ] || _ko "HTML introuvable : le code n'est pas 2"
lancer_script "$SC/attendu/exemple.html" "$TMP/dossier-absent/x.docx" >/dev/null; [ $? -eq 3 ] || _ko "dossier de sortie absent : le code n'est pas 3"

# 3. Échec simulé du .docx : code 10, .rtf surligné en jaune, pas de .docx.
sortie=$(MEMOIRE_FORCER_ECHEC_DOCX=1 lancer_script "$SC/attendu/exemple.html" "$TMP/secours.docx"); code=$?
[ "$code" -eq 10 ] || _ko "échec simulé : code $code au lieu de 10"
tail -1 <<< "$sortie" | grep -qE '^RTF .*secours\.rtf 2$' || _ko "échec simulé : dernière ligne inattendue : $(tail -1 <<< "$sortie")"
[ -f "$TMP/secours.rtf" ] || _ko "échec simulé : le .rtf de secours n'est pas produit"
[ ! -e "$TMP/secours.docx" ] || _ko "échec simulé : un .docx est quand même présent"
head -c 6 "$TMP/secours.rtf" | grep -q '^{\\rtf1' || _ko "le fichier de secours n'est pas un RTF"
rtf_surligne "$TMP/secours.rtf"
cmp -s "$SC/attendu/exemple.rtf" "$TMP/secours.rtf" || _ko "le .rtf de secours diffère du fichier attendu (attendu/exemple.rtf)"
T3=$(texte_du_fichier "$TMP/secours.rtf")
grep -q 'À COMPLÉTER' <<< "$T3" || _ko "le .rtf de secours a perdu les [À COMPLÉTER]"
grep -q 'œuvre' <<< "$T3" || _ko "le .rtf de secours a perdu les accents"
MEMOIRE_FORCER_ECHEC_DOCX=1 lancer_script "$SC/attendu/exemple.html" "$TMP/secours.docx" >/dev/null; [ $? -eq 4 ] || _ko "le .rtf existant serait écrasé"

# 4. Remplissage du cadre de l'acheteur (cadre-acheteur-windows.ps1), sur le cadre fictif du scénario
#    « memoire-cadre-acheteur » et avec son fichier de réponses d'essai : mêmes attentes que le script Mac.
l=$(lancer_cadre lister "$ORIG"); code=$?
[ "$code" -eq 0 ] || _ko "cadre, lister : code $code au lieu de 0 : $l"
grep -qF '¶17 [tableau 1, ligne 2, cellule 2] | (vide)' <<< "$l" || _ko "cadre, lister : la case réponse du tableau n'est pas repérée"
grep -qF '¶6 {Heading2} | 1.1 Décrivez' <<< "$l" || _ko "cadre, lister : la question 1.1 et son style ne sont pas affichés"
grep -qx 'PARAGRAPHES 29' <<< "$l" || _ko "cadre, lister : nombre de paragraphes inattendu"

sortie=$(lancer_cadre remplir "$ORIG" "$ESSAI_REPONSES" "$TMP/cadre-ok.docx"); code=$?
[ "$code" -eq 0 ] || _ko "cadre, remplir : code $code au lieu de 0 : $sortie"
tail -1 <<< "$sortie" | grep -qE '^CADRE .*cadre-ok\.docx 7 4$' || _ko "cadre, remplir : dernière ligne inattendue : $(tail -1 <<< "$sortie")"
if [ -f "$TMP/cadre-ok.docx" ]; then
  docx_valide "$TMP/cadre-ok.docx"
  docx_surligne "$TMP/cadre-ok.docx"
  cadre_intact "$TMP/cadre-ok.docx"
  reponses_aux_bons_endroits "$(texte_du_fichier "$TMP/cadre-ok.docx")" "cadre, essai direct"
fi
lancer_cadre remplir "$ORIG" "$ESSAI_REPONSES" "$TMP/cadre-ok.docx" >/dev/null; [ $? -eq 4 ] || _ko "cadre : le script écrase un fichier existant"

perl -0ne 'print join "\n", reverse split /(?=^### )/m' "$ESSAI_REPONSES" > "$TMP/inverse.txt"
lancer_cadre remplir "$ORIG" "$TMP/inverse.txt" "$TMP/cadre-inverse.docx" >/dev/null || _ko "cadre : blocs dans l'ordre inverse refusés"
if [ -f "$TMP/cadre-ok.docx" ] && [ -f "$TMP/cadre-inverse.docx" ]; then
  extraire_docx "$TMP/cadre-ok.docx" "$TMP/x-ok"; extraire_docx "$TMP/cadre-inverse.docx" "$TMP/x-inverse"
  cmp -s "$TMP/x-ok/word/document.xml" "$TMP/x-inverse/word/document.xml" || _ko "cadre : l'ordre des blocs du fichier de réponses change le résultat"
fi

printf '### 9 | 1.1 Décrivez\nx\n' > "$TMP/ancre.txt"
lancer_cadre remplir "$ORIG" "$TMP/ancre.txt" "$TMP/ancre.docx" >/dev/null; code=$?
[ "$code" -eq 6 ] || _ko "cadre, ancre fausse : code $code au lieu de 6"
[ ! -e "$TMP/ancre.docx" ] || _ko "cadre, ancre fausse : un fichier est quand même produit"
printf '### 8\n@max 20\nUne réponse bien plus longue que vingt caractères.\n' > "$TMP/limite.txt"
lancer_cadre remplir "$ORIG" "$TMP/limite.txt" "$TMP/limite.docx" >/dev/null; [ $? -eq 6 ] || _ko "cadre, limite dépassée : le code n'est pas 6"
for e in doc xlsx; do
  cp "$ORIG" "$TMP/cadre.$e"
  lancer_cadre remplir "$TMP/cadre.$e" "$ESSAI_REPONSES" "$TMP/$e.docx" >/dev/null; code=$?
  [ "$code" -eq 5 ] || _ko "cadre, format .$e : code $code au lieu de 5"
done

rm -rf "$TMP"
fin
