# Mémoire technique sur Mac, version .rtf : l'artisan demande un .rtf et donne presque toutes ses réponses,
# dont un prix qui ne doit pas se retrouver dans le mémoire. Puis le script de conversion est essayé
# directement, avec un échec simulé de la conversion en .docx.
source "$ROOT/tests/lib.sh"
source "$ROOT/tests/scenarios/memoire/outils.sh"
SC="$ROOT/tests/scenarios/memoire-rtf"
C="$D/$CONSULT_REL"
SCRIPT="$ROOT/skill/marches-publics/scripts/memoire-vers-docx-mac.sh"

# Les fichiers de l'artisan ne sont pas touchés.
diff -q "$SC/dossier/ma-fiche-entreprise.md" "$D/ma-fiche-entreprise.md" >/dev/null || _ko "la fiche a été modifiée"
diff -q "$SC/dossier/suivi.md" "$D/suivi.md" >/dev/null || _ko "le suivi a été modifié"
diff -q "$SC/dossier/$CONSULT_REL/analyse.md" "$C/analyse.md" >/dev/null || _ko "l'analyse a été modifiée"

# Un .rtf, comme demandé, dans le sous-dossier de la consultation.
M=$(find "$C" -maxdepth 1 -name 'memoire*.rtf' | head -1)
[ -n "$M" ] || { _ko "aucun .rtf de mémoire dans le sous-dossier de la consultation"; fin; }
file "$M" | grep -qi 'rich text' || _ko "le fichier .rtf n'est pas un RTF"
rtf_surligne "$M"
T=$(texte_du_fichier "$M")
[ -n "$T" ] || { _ko "textutil ne relit aucun texte dans le .rtf"; fin; }
S=$(sans_a_completer <<< "$T")

# Trame, fiche, réponses reprises.
trame_du_rc "$T"
fiche_reutilisee "$T"
for mot in camionnette 'sert(i|iss)' 'compagnons' 'mise en pression' 'benne' 'déchetterie' 'clôture' '8 h'; do
  grep -qiE "$mot" <<< "$T" || _ko "la réponse de l'artisan n'est pas reprise : $mot"
done

# Insertion et environnement : rien dit, donc [À COMPLÉTER].
n=$(grep -o '\[À COMPLÉTER' <<< "$T" | wc -l | tr -d ' ')
[ "$n" -ge 1 ] || _ko "aucun [À COMPLÉTER] alors que l'insertion et l'environnement n'ont pas de réponse"
grep -q 'À COMPLÉTER' <<< "$(awk '/[Ii]nsertion/ { n = NR } { l[NR] = $0 } END { for (i = n; i <= NR && i <= n + 8; i++) print l[i] }' <<< "$T")" || _ko "pas de [À COMPLÉTER] dans la section insertion et environnement"

# Aucun fait inventé, et surtout pas le prix de 70 000 € donné en passant.
memoire_sans_invention "$S" "$T"
memoire_sans_prix "$T"
grep -q '70 \?000' <<< "$T" && _ko "le prix de l'artisan figure dans le mémoire"
toute_la_conversation
vouvoie
sortie_contient 'rtf' "le format RTF mentionné dans la réponse"
sortie_contient 'prix' "le rappel que le prix reste à l'artisan"

# Essai direct du script : conversion normale, puis échec simulé du .docx, puis refus d'écraser.
TMP=$(mktemp -d)
cat > "$TMP/essai.html" <<'HTML'
<!DOCTYPE html><html lang="fr"><head><meta charset="utf-8"><title>Essai</title>
<style>body { font-family: Arial; font-size: 11px; }</style></head><body>
<h1>Mémoire technique</h1>
<p>Nous serons trois sur le chantier. Éléments accentués : œuvre, à l'été, naïveté.</p>
<p><span class="a-completer" style="background-color:#FFFF00; color:#C00000; font-weight:bold">[À COMPLÉTER : le planning]</span></p>
<ul><li>Une puce <span class="a-completer" style="background-color:#FFFF00; color:#C00000; font-weight:bold">[À COMPLÉTER : le matériel]</span></li></ul>
</body></html>
HTML
sortie=$(bash "$SCRIPT" "$TMP/essai.html" "$TMP/ok.docx" 2>&1); code=$?
[ "$code" -eq 0 ] || _ko "le script a rendu le code $code au lieu de 0 : $sortie"
tail -1 <<< "$sortie" | grep -qE "^DOCX .*ok\.docx 2$" || _ko "dernière ligne inattendue du script : $(tail -1 <<< "$sortie")"
docx_valide "$TMP/ok.docx"
docx_surligne "$TMP/ok.docx"
grep -q 'œuvre' <<< "$(texte_du_fichier "$TMP/ok.docx")" || _ko "les accents sont perdus dans le .docx"
bash "$SCRIPT" "$TMP/essai.html" "$TMP/ok.docx" >/dev/null 2>&1; [ $? -eq 4 ] || _ko "le script écrase un fichier existant"

sortie=$(MEMOIRE_FORCER_ECHEC_DOCX=1 bash "$SCRIPT" "$TMP/essai.html" "$TMP/secours.docx" 2>&1); code=$?
[ "$code" -eq 10 ] || _ko "échec simulé : code $code au lieu de 10"
[ -f "$TMP/secours.rtf" ] || _ko "échec simulé : le .rtf de secours n'est pas produit"
[ ! -e "$TMP/secours.docx" ] || _ko "échec simulé : un .docx est quand même présent"
rtf_surligne "$TMP/secours.rtf"
grep -q 'À COMPLÉTER' <<< "$(texte_du_fichier "$TMP/secours.rtf")" || _ko "le .rtf de secours a perdu les [À COMPLÉTER]"
rm -rf "$TMP"
fin
