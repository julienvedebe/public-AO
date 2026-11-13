# Fonctions des scénarios qui remplissent le cadre de l'acheteur (chargées après tests/lib.sh et memoire/outils.sh,
# et, sous Windows, après memoire-windows/outils-windows.sh, qui redéfinit texte_du_fichier et extraire_docx).
# Le cadre de référence est celui de la fixture : cadre-acheteur.docx (voir fabriquer-fixture.sh).

ORIG="$ROOT/tests/scenarios/memoire-cadre-acheteur/cadre-acheteur.docx"
ESSAI_REPONSES="$ROOT/tests/scenarios/memoire-cadre-acheteur/essai-reponses.txt"

# Numéro de la première ligne de <texte> qui correspond à <regex>, à partir de la ligne <depuis> (1 par défaut).
ligne_de() { awk -v re="$2" -v d="${3:-1}" 'NR >= d && $0 ~ re { print NR; exit }' <<< "$1"; }

# Lignes strictement entre la première ligne qui correspond à <de> et la suivante qui correspond à <a>.
entre() { awk -v de="$2" -v a="$3" 'dedans && $0 ~ a { exit } dedans { print } !dedans && $0 ~ de { dedans = 1 }' <<< "$1"; }

# <texte> contient <regex> entre la ligne <de> et la ligne <a> (réponse au bon endroit).
reponse_entre() { # <texte> <de> <a> <regex> <description>
  grep -qiE "$4" <<< "$(entre "$1" "$2" "$3")" || _ko "$5 : absent entre « $2 » et « $3 »"
}

# Le cadre rempli garde tout ce que l'acheteur a écrit, dans l'ordre, et toutes ses autres parties à l'identique.
cadre_intact() { # <cadre rempli.docx>
  local f="$1" tmp ecarts
  tmp=$(mktemp -d)
  texte_du_fichier "$ORIG" | grep -v '^[[:space:]]*$' > "$tmp/orig.txt"
  texte_du_fichier "$f" > "$tmp/rempli.txt"
  perl -CSD -e '
    open my $a, "<:encoding(UTF-8)", $ARGV[0] or exit 2; my @o = map { s/\s+$//r } <$a>;
    open my $b, "<:encoding(UTF-8)", $ARGV[1] or exit 2; my $i = 0;
    while (my $l = <$b>) { $l =~ s/\s+$//; $i++ if $i < @o && $l eq $o[$i]; }
    if ($i < @o) { print "$o[$i]\n"; exit 1 } exit 0' "$tmp/orig.txt" "$tmp/rempli.txt" > "$tmp/manque.txt" ||
    _ko "le texte de l'acheteur n'est plus intact ou plus dans l'ordre, à partir de : $(head -1 "$tmp/manque.txt")"
  mkdir "$tmp/o" "$tmp/r"
  extraire_docx "$ORIG" "$tmp/o" && extraire_docx "$f" "$tmp/r" || { _ko "le cadre rempli n'est pas une archive lisible"; rm -rf "$tmp"; return; }
  ecarts=$(diff -rq "$tmp/o" "$tmp/r" 2>&1 | grep -v 'word/document.xml differ')
  [ -z "$ecarts" ] || _ko "une partie du cadre autre que le texte a changé (styles, en-tête, pied de page…) : $(head -1 <<< "$ecarts")"
  rm -rf "$tmp"
}

# Les rubriques de l'acheteur sont dans l'ordre et chaque réponse est sous la bonne rubrique.
reponses_aux_bons_endroits() { # <texte du cadre rempli> <prefixe de description>
  local t="$1" p="$2" l
  local r1 r2 r3 r4 r5 r6 r7 r8 fait
  r1=$(ligne_de "$t" '^1\.1 Décrivez'); r2=$(ligne_de "$t" '^1\.2 Décrivez'); r3=$(ligne_de "$t" '^2\. Moyens')
  r4=$(ligne_de "$t" '^2\.1 Composition'); r5=$(ligne_de "$t" '^2\.2 Matériel'); r6=$(ligne_de "$t" '^3\. Gestion')
  r7=$(ligne_de "$t" '^4\.1 Gestion'); r8=$(ligne_de "$t" '^4\.2 Actions'); fait=$(ligne_de "$t" '^Fait à')
  for l in "$r1" "$r2" "$r3" "$r4" "$r5" "$r6" "$r7" "$r8" "$fait"; do
    [ -n "$l" ] || { _ko "$p : une rubrique de l'acheteur a disparu"; return; }
  done
  [ "$r1" -lt "$r2" ] && [ "$r2" -lt "$r3" ] && [ "$r3" -lt "$r4" ] && [ "$r4" -lt "$r5" ] && [ "$r5" -lt "$r6" ] &&
    [ "$r6" -lt "$r7" ] && [ "$r7" -lt "$r8" ] && [ "$r8" -lt "$fait" ] || _ko "$p : les rubriques de l'acheteur ne sont plus dans l'ordre"
  reponse_entre "$t" '^1\.1 Décrivez' '^1\.2 Décrivez' 'anciens appareils|cuivre' "$p : la méthode (dépose, cuivre)"
  reponse_entre "$t" '^1\.2 Décrivez' '^2\. Moyens' 'mise en pression' "$p : l'essai de mise en pression"
  reponse_entre "$t" '^2\.1 Composition' '^2\.2 Matériel' 'compagnons' "$p : l'équipe"
  reponse_entre "$t" '^2\.2 Matériel' '^3\. Gestion' 'camionnette' "$p : la camionnette"
  reponse_entre "$t" '^2\.2 Matériel' '^3\. Gestion' 'sert(i|iss)' "$p : la machine à sertir"
  reponse_entre "$t" '^3\.1 Décrivez' '^4\. ' 'À COMPLÉTER' "$p : un [À COMPLÉTER] pour les nuisances"
  reponse_entre "$t" '^4\.1 Gestion' '^4\.2 Actions' 'À COMPLÉTER' "$p : un [À COMPLÉTER] pour les déchets"
  reponse_entre "$t" '^4\.2 Actions' '^Fait à' 'À COMPLÉTER' "$p : un [À COMPLÉTER] pour l'insertion"
  # La zone de signature n'est pas remplie.
  [ -z "$(sed -n "$((fait + 1)),\$p" <<< "$t" | tr -d '[:space:]')" ] || _ko "$p : du texte a été ajouté après la zone de signature"
}

