#!/bin/bash
# Convertit le mémoire technique (HTML) en .docx sur Mac, avec les outils natifs du Mac
# (textutil, unzip, zip, perl, xmllint). Rien à installer.
#
# Usage : bash memoire-vers-docx-mac.sh memoire.html /chemin/memoire-technique.docx
#
# Pourquoi un script et pas un simple « textutil -convert docx » : textutil perd tous les fonds
# de couleur en écrivant le .docx. Le script convertit, puis ajoute le surlignage jaune de Word
# (<w:highlight>) sur chaque passage « [À COMPLÉTER … ] », puis contrôle le résultat.
#
# Codes de sortie :
#   0   .docx produit, contrôlé, [À COMPLÉTER] surlignés
#   10  conversion en .docx impossible : un .rtf de secours a été produit à côté (même nom)
#   2   fichier HTML introuvable    3  textutil absent ou conversion impossible (aucun fichier)
#   4   le fichier de sortie existe déjà (rien n'est écrasé)
# La dernière ligne affichée dit ce qui a été produit : « DOCX <chemin> <n> » ou « RTF <chemin> <n> »
# (n = nombre de passages [À COMPLÉTER] surlignés).
#
# Variable de test : MEMOIRE_FORCER_ECHEC_DOCX=1 simule un échec de la conversion en .docx.

set -u
HTML=${1:-}
DOCX=${2:-}
[ -f "$HTML" ] && [ -n "$DOCX" ] || { echo "Usage : memoire-vers-docx-mac.sh memoire.html sortie.docx"; exit 2; }
RTF="${DOCX%.docx}.rtf"
[ ! -e "$DOCX" ] && [ ! -e "$RTF" ] || { echo "Le fichier de sortie existe déjà : rien n'est écrasé."; exit 4; }
command -v textutil >/dev/null 2>&1 || { echo "textutil est introuvable sur cet ordinateur."; exit 3; }

TMP=$(mktemp -d) || exit 3
trap 'rm -rf "$TMP"' EXIT

# Nombre de passages [À COMPLÉTER] dans le HTML (pour comparer avec ce qui est surligné).
ATTENDU=$(grep -o '\[À COMPLÉTER' "$HTML" | wc -l | tr -d ' ')

# ---------- Chemin principal : .docx ----------
faire_docx() {
  [ "${MEMOIRE_FORCER_ECHEC_DOCX:-0}" != 1 ] || { echo "échec simulé"; return 1; }
  textutil -convert docx "$HTML" -output "$TMP/brut.docx" || return 1
  mkdir "$TMP/x" && unzip -q "$TMP/brut.docx" -d "$TMP/x" || return 1
  [ -s "$TMP/x/word/document.xml" ] || return 1

  # Ajoute le surlignage jaune dans le formatage de chaque passage qui contient [À COMPLÉTER.
  perl -0pi -e 's{<w:rPr>(?=(?:(?!</w:r>).)*?\[À COMPLÉTER)}{<w:rPr><w:highlight w:val="yellow"/>}gs' \
    "$TMP/x/word/document.xml" || return 1

  # Contrôles : XML lisible, aucun [À COMPLÉTER] sans surlignage, autant de passages que dans le HTML.
  xmllint --noout "$TMP/x/word/document.xml" || return 1
  SANS=$(perl -0ne 'my $n = 0; while (/<w:r>(.*?)<\/w:r>/gs) { my $r = $1; $n++ if $r =~ /\[À COMPLÉTER/ && $r !~ /w:highlight/ } print $n' "$TMP/x/word/document.xml")
  [ "$SANS" = 0 ] || { echo "$SANS passage(s) [À COMPLÉTER] sans surlignage"; return 1; }
  DANS=$(grep -o '\[À COMPLÉTER' "$TMP/x/word/document.xml" | wc -l | tr -d ' ')
  [ "$DANS" = "$ATTENDU" ] || { echo "$DANS [À COMPLÉTER] dans le .docx au lieu de $ATTENDU"; return 1; }

  # Recompose le .docx (le fichier de types en premier), puis le relit.
  (cd "$TMP/x" && zip -q -X -r "$TMP/final.docx" '[Content_Types].xml' _rels docProps word) || return 1
  unzip -tq "$TMP/final.docx" >/dev/null || return 1
  textutil -convert txt -stdout "$TMP/final.docx" > "$TMP/relu.txt" || return 1
  [ -s "$TMP/relu.txt" ] || return 1
  [ "$(grep -o '\[À COMPLÉTER' "$TMP/relu.txt" | wc -l | tr -d ' ')" = "$ATTENDU" ] || return 1
  cp "$TMP/final.docx" "$DOCX" || return 1
  echo "DOCX $DOCX $DANS"
}

if faire_docx; then exit 0; fi
rm -f "$DOCX"
echo "La conversion en .docx a échoué : production d'un .rtf de secours."

# ---------- Secours : .rtf ----------
# textutil écrit le fond jaune en « \cbN » (lu par TextEdit) ; Word et LibreOffice lisent « \highlightN ». On garde les deux.
textutil -convert rtf "$HTML" -output "$TMP/brut.rtf" || { echo "Conversion en .rtf impossible."; exit 3; }
perl -0pi -e '
  my ($jaune) = (0);
  if (/\\colortbl;(.*?)\}/s) {
    my $i = 0;
    for my $c (split /;/, $1) {
      $i++;
      if ($c =~ /\\red2[45]\d\\green2[45]\d\\blue(\d+)/ && $1 < 100) { $jaune = $i; last }
    }
  }
  s/\\cb(\d+)/"\\cb$1\\highlight" . ($1 == $jaune ? $1 : 0)/ge;
' "$TMP/brut.rtf" || { echo "Surlignage du .rtf impossible."; exit 3; }
textutil -convert txt -stdout "$TMP/brut.rtf" > "$TMP/relu.txt" && [ -s "$TMP/relu.txt" ] || { echo "Le .rtf produit est illisible."; exit 3; }
cp "$TMP/brut.rtf" "$RTF" || exit 3
echo "RTF $RTF $(grep -o 'highlight[1-9]' "$RTF" | wc -l | tr -d ' ')"
exit 10
