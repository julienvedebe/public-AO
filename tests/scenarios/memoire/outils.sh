# Fonctions communes aux scénarios « memoire* » (chargées par leur check.sh, après tests/lib.sh).
# Elles relisent le mémoire produit (.docx ou .rtf) comme l'artisan le recevrait, puis vérifient
# la structure du fichier, le surlignage, les critères du RC, l'absence d'invention et l'absence de prix.
# Aucune ne vérifie une formulation exacte.

DCE_TXT="$ROOT/tests/scenarios/analyse/dce-source"
CONSULT_REL="consultations/2027-01_commune-de-val-de-brelle_lot-05-plomberie"

# Texte brut du mémoire, tel que textutil le relit (docx ou rtf).
texte_du_fichier() { textutil -convert txt -stdout "$1" 2>/dev/null; }

# Texte sans les passages [À COMPLÉTER : …] : ce qui reste est ce que le mémoire affirme.
sans_a_completer() { perl -Mutf8 -CS -0pe 's/\[\s*À COMPLÉTER[^\]]*\]//gi'; }

# .docx valide : archive saine, parties indispensables, XML lisible, texte relu par textutil.
docx_valide() { # <fichier.docx>
  local f="$1" part
  unzip -tq "$f" >/dev/null 2>&1 || { _ko "le .docx n'est pas une archive valide"; return; }
  for part in '[Content_Types].xml' '_rels/.rels' 'word/document.xml'; do
    unzip -l "$f" 2>/dev/null | grep -qF "$part" || _ko "partie absente du .docx : $part"
  done
  local tmp; tmp=$(mktemp -d)
  unzip -q "$f" -d "$tmp" 2>/dev/null
  find "$tmp" \( -name '*.xml' -o -name '*.rels' \) -print0 | while IFS= read -r -d '' x; do
    xmllint --noout "$x" 2>/dev/null || echo "XML illisible : $x"
  done | grep -q . && _ko "un fichier XML du .docx est illisible"
  rm -rf "$tmp"
  [ -n "$(texte_du_fichier "$f")" ] || _ko "textutil ne relit aucun texte dans le .docx"
}

# Surlignage : chaque passage contenant [À COMPLÉTER porte <w:highlight w:val="yellow"/> dans le XML.
docx_surligne() { # <fichier.docx>
  local xml sans total
  xml=$(unzip -p "$1" word/document.xml 2>/dev/null)
  total=$(grep -o '\[À COMPLÉTER' <<< "$xml" | wc -l | tr -d ' ')
  [ "$total" -ge 1 ] || { _ko "aucun [À COMPLÉTER] dans le XML du .docx"; return; }
  sans=$(perl -Mutf8 -CS -0ne 'my $n = 0; while (/<w:r>(.*?)<\/w:r>/gs) { my $r = $1; $n++ if $r =~ /\[À COMPLÉTER/ && $r !~ /<w:highlight w:val="yellow"\/>/ } print $n' <<< "$xml")
  [ "$sans" = 0 ] || _ko "$sans [À COMPLÉTER] sans surlignage jaune dans le .docx (sur $total)"
}

# Surlignage du .rtf de secours : au moins un \highlightN, et la couleur N est bien du jaune.
rtf_surligne() { # <fichier.rtf>
  local n
  n=$(grep -o '\\highlight[1-9][0-9]*' "$1" | sort -u | tr '\n' ' ')
  [ -n "$n" ] || { _ko "aucun surlignage (\\highlight) dans le .rtf"; return; }
  perl -0ne '
    my @c = (/\\colortbl;(.*?)\}/s)[0] =~ /([^;]*);/g;
    my $bad = 0; my $vu = 0;
    while (/\\highlight([1-9]\d*)/g) {
      my $e = $c[$1 - 1] // ""; $vu++;
      $bad++ unless $e =~ /\\red(\d+)\\green(\d+)\\blue(\d+)/ && $1 >= 240 && $2 >= 240 && $3 < 100;
    }
    exit($vu && !$bad ? 0 : 1)' "$1" || _ko "le surlignage du .rtf n'est pas jaune"
}

# La trame reprend les critères du RC de Val-de-Brelle (article 10), avec leurs poids.
trame_du_rc() { # <texte>
  local t="$1"
  grep -qiE 'valeur technique' <<< "$t" || _ko "critère « valeur technique » absent de la trame"
  grep -qE '50 ?%' <<< "$t"             || _ko "poids 50 % absent"
  grep -qiE 'méthodologie' <<< "$t"     || _ko "sous-critère « méthodologie et organisation » absent"
  grep -qiE 'moyens humains' <<< "$t"   || _ko "sous-critère « moyens humains et matériels » absent"
  grep -qiE 'nuisances' <<< "$t"        || _ko "sous-critère « gestion des nuisances » absent"
  grep -qE '25 points' <<< "$t"         || _ko "points du sous-critère méthodologie absents"
  grep -qiE 'insertion' <<< "$t"        || _ko "critère « insertion et environnement » absent"
  grep -qE '10 ?%' <<< "$t"             || _ko "poids 10 % absent"
  # Le prix n'est pas rédigé dans le mémoire : cité au plus pour dire qu'il est ailleurs.
  grep -qiE "acte d'engagement|pas dans ce mémoire|hors mémoire|à part" <<< "$t" || _ko "le renvoi du prix vers l'acte d'engagement est absent"
}

# La fiche est réutilisée : certification et références, telles quelles.
fiche_reutilisee() { # <texte>
  grep -qiE 'Qualibat 5211' <<< "$1" || _ko "la certification Qualibat 5211 de la fiche n'est pas reprise"
  # Toutes les références de la fiche, ou au moins deux si l'agent choisit les plus proches du lot (le RC en demande 2).
  local n=0 r
  for r in Bron OPAC Dombes; do grep -qiE "$r" <<< "$1" && n=$((n + 1)); done
  [ "$n" -ge 2 ] || _ko "moins de deux références de la fiche reprises ($n sur 3)"
}

# Pièges d'invention. Le texte est celui du mémoire sans ses passages [À COMPLÉTER].
# <texte sans passages à compléter> <texte complet> [réponses autorisées : mots séparés par |]
memoire_sans_invention() {
  local s="$1" t="$2" tous
  # Effectif : la fiche dit 4 personnes (dont 1 apprenti), l'artisan en annonce 3 sur ce chantier.
  tous=$(grep -oiE '\b([0-9]+|cinq|six|sept|huit|neuf|dix|douze|quinze|vingt) (personnes|salariés|compagnons|ouvriers|employés|collaborateurs|techniciens|plombiers|apprentis)\b' <<< "$s" | grep -viE '^(1|2|3|4|un|une|deux|trois|quatre) ' || true)
  [ -z "$tous" ] || _ko "effectif différent de la fiche ou des réponses : $(head -1 <<< "$tous")"
  # Matériel, véhicules, outils, normes et labels jamais cités.
  grep -qiE 'nacelle|échafaudage|grue|pelleteuse|mini-pelle|caméra|compresseur|tronçonneuse|chalumeau|brasure|brasage|poste à souder|remorque|fourgon|\bcamion\b|pompe d.épreuve|détecteur|ISO ?(9001|14001|45001)|\bMASE\b|Qualifelec|Qualit.?EnR|Qualisol|\bNF ?[A-Z]' <<< "$s" && _ko "matériel, norme ou label jamais cité : $(grep -oiE 'nacelle|échafaudage|grue|pelleteuse|mini-pelle|caméra|compresseur|tronçonneuse|chalumeau|brasure|brasage|poste à souder|remorque|fourgon|\bcamion\b|pompe d.épreuve|détecteur|ISO ?(9001|14001|45001)|\bMASE\b|Qualifelec|Qualit.?EnR|Qualisol' <<< "$s" | head -1)"
  # Chantiers, clients et ancienneté jamais cités : seuls Bron, l'OPAC du Rhône et la Dombes (fiche), et Val-de-Brelle.
  tous=$(grep -oE "(Mairie|Commune|Ville|Communauté de communes|Département|Métropole|OPAC|Office|Région|Lycée|Collège|Hôpital|Clinique|École|Ecole|Crèche|Gymnase|Bailleur)( de la | de | du | des | d')?[A-Z][A-Za-zÀ-ÿ'-]+" <<< "$s" | grep -vE 'Bron|Val-de-Brelle|Rhône|Dombes|Jean-Moulin|Marcel-Pagnol|Villeurbanne|Vénissieux|Villars' || true)
  [ -z "$tous" ] || _ko "acheteur ou chantier absent de la fiche : $(head -1 <<< "$tous")"
  grep -qiE "[0-9]+ ans d.expérience|depuis (plus de )?[0-9]+ ans|plus de [0-9]+ (chantiers|ans)|fondée en|créée en|depuis [0-9]{4}" <<< "$s" && _ko "ancienneté ou volume de chantiers inventé"
  # Phrases creuses qui affirment sans source.
  grep -qiE "personnel (qualifié|expérimenté)|équipe (qualifiée|expérimentée)|savoir-faire|normes en vigueur|règles de l.art|démarche qualité" <<< "$s" && _ko "phrase creuse sans source : $(grep -oiE "personnel (qualifié|expérimenté)|équipe (qualifiée|expérimentée)|savoir-faire|normes en vigueur|règles de l.art|démarche qualité" <<< "$s" | head -1)"
  # Qualigaz manque à la fiche : jamais affirmé (cité seulement comme exigence ou à compléter).
  grep -i 'qualigaz' <<< "$t" | grep -viE 'À COMPLÉTER|exig|demand|impos' | grep -q . && _ko "Qualigaz affirmé alors que la fiche ne l'a pas"
  # Pas de fuite du gabarit.
  grep -qiE 'intitulé exact|à remplacer|gabarit|<!--|<h[1-3]>|<span' <<< "$t" && _ko "le gabarit ou du HTML apparaît dans le mémoire"
  return 0
}

# Montants : tous ceux du mémoire viennent de la fiche ou du DCE, jamais d'un prix de l'artisan.
montants_du_texte() { perl -Mutf8 -CS -ne 'while (/(\d{1,3}(?:[ \x{a0}\x{202f}.]?\d{3})+|\d+)[ \x{a0}\x{202f}]?(?:€|euros?)/gi) { (my $n = $1) =~ s/\D//g; print "$n\n" }'; }

memoire_sans_prix() { # <texte complet>
  local autorises m
  autorises=$(cat "$D/ma-fiche-entreprise.md" "$DCE_TXT"/*.txt "$D/$CONSULT_REL/analyse.md" | montants_du_texte | sort -u)
  for m in $(montants_du_texte <<< "$1" | sort -u); do
    grep -qx "$m" <<< "$autorises" || _ko "montant absent de la fiche et du DCE (un prix ?) : $m €"
  done
  grep -qiE '(proposer|facturer|chiffrer|demander) (un|le|ce) (prix|montant|tarif)|prix (conseillé|recommandé|à proposer|à pratiquer)|notre offre (de|à|s.élève)|remise de [0-9]' <<< "$1" && _ko "un prix est proposé dans le mémoire"
  return 0
}

# Extrait les parties d'un .docx dans un dossier (redéfini sous Windows par outils-windows.sh).
extraire_docx() { unzip -q "$1" -d "$2" 2>/dev/null; } # <fichier.docx> <dossier>
