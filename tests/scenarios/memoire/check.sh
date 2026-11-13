# Mémoire technique sur Mac : conversation en quatre tours, l'artisan ne donne qu'une partie des informations.
source "$ROOT/tests/lib.sh"
source "$ROOT/tests/scenarios/memoire/outils.sh"
SC="$ROOT/tests/scenarios/memoire"
C="$D/$CONSULT_REL"

# Les fichiers de l'artisan ne sont pas touchés (fiche, suivi, analyse, DCE).
diff -q "$SC/dossier/ma-fiche-entreprise.md" "$D/ma-fiche-entreprise.md" >/dev/null || _ko "la fiche a été modifiée"
diff -q "$SC/dossier/suivi.md" "$D/suivi.md" >/dev/null || _ko "le suivi a été modifié"
diff -q "$SC/dossier/$CONSULT_REL/analyse.md" "$C/analyse.md" >/dev/null || _ko "l'analyse a été modifiée"
diff -rq "$SC/dossier/$CONSULT_REL/dce" "$C/dce" >/dev/null || _ko "le DCE a été modifié"

# Une seule question à la fois, aux trois premiers tours ; le mémoire n'existe pas encore avant le dernier.
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

# Structure du .docx et surlignage.
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
# Piège propre à ce scénario : l'artisan n'a rien dit des déchets, de la sécurité ni du planning.
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
fin
