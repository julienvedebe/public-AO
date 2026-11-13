#!/bin/bash
# Remplit le cadre de mémoire fourni par l'acheteur (le « cadre de réponse technique » du DCE) sur Mac,
# avec les outils natifs du Mac (textutil, unzip, zip, perl, xmllint). Rien à installer.
#
# Deux usages :
#   bash cadre-acheteur-mac.sh lister  <cadre.docx|.doc|.odt|.rtf>
#       affiche chaque paragraphe du cadre, numéroté : « ¶<n> [tableau t, ligne l, cellule c] {style} | texte ».
#       Ces numéros servent d'ancres dans le fichier de réponses.
#   bash cadre-acheteur-mac.sh remplir <cadre> <reponses.txt> <sortie.docx>
#       écrit une COPIE du cadre, avec chaque réponse insérée à la suite du paragraphe indiqué.
#       Le texte et la mise en page de l'acheteur ne sont pas modifiés : seul word/document.xml reçoit
#       de nouveaux paragraphes ; les autres parties (styles, en-têtes, pieds de page, images) restent identiques.
#
# Fichier de réponses (UTF-8), un bloc par endroit à remplir :
#   ### <n> | <début du texte du paragraphe n, tel que « lister » l'affiche ; rien pour un paragraphe vide>
#   @max <nombre>          (facultatif) nombre de caractères maximum imposé par le cadre pour cette réponse
#   Une ligne = un paragraphe. Une ligne qui commence par « - » devient une ligne de liste (tiret, retrait).
#   [À COMPLÉTER : …] est surligné en jaune, en gras rouge.
# La réponse se place APRÈS le paragraphe n ; si le paragraphe n est vide (case « réponse » d'un tableau,
# ligne laissée blanche), elle se place à sa place, avant lui.
#
# Codes de sortie (mêmes que cadre-acheteur-windows.ps1) :
#   0  cadre rempli et contrôlé (dernière ligne : « CADRE <chemin> <blocs> <surlignés> »)
#   2  arguments manquants ou fichier introuvable
#   3  outil du Mac absent ou fichier illisible : rien n'est produit
#   4  le fichier de sortie existe déjà : rien n'est écrasé
#   5  format non pris en charge (.xlsx, .pdf…) : rien n'est produit
#   6  le fichier de réponses ne correspond pas au cadre (numéro absent, texte différent, limite dépassée) :
#      rien n'est produit ; corrigez le fichier de réponses et relancez
#   7  le remplissage n'a pas passé les contrôles : rien n'est produit
# Lignes d'avertissement possibles avant la dernière : « CONVERTI <format> » (le .doc/.odt/.rtf a été converti en
# .docx par textutil : la mise en forme peut avoir changé), « PROTEGE » (le document de l'acheteur est protégé
# contre la modification dans Word).

set -u
MODE=${1:-}
CADRE=${2:-}

usage() {
  echo "Usage : cadre-acheteur-mac.sh lister <cadre>"
  echo "        cadre-acheteur-mac.sh remplir <cadre> <reponses.txt> <sortie.docx>"
  exit 2
}

case "$MODE" in
  lister)  [ $# -eq 2 ] || usage ;;
  remplir) [ $# -eq 4 ] || usage; REPONSES=$3; SORTIE=$4 ;;
  *) usage ;;
esac
[ -f "$CADRE" ] || { echo "Cadre introuvable : $CADRE"; exit 2; }
if [ "$MODE" = remplir ]; then
  [ -f "$REPONSES" ] || { echo "Fichier de réponses introuvable : $REPONSES"; exit 2; }
  case "$SORTIE" in *.docx) ;; *) echo "La sortie doit être un .docx : $SORTIE"; exit 2 ;; esac
  [ ! -e "$SORTIE" ] || { echo "Le fichier de sortie existe déjà : rien n'est écrasé."; exit 4; }
  [ -d "$(dirname "$SORTIE")" ] || { echo "Le dossier de sortie n'existe pas : $(dirname "$SORTIE")"; exit 3; }
fi
for outil in unzip zip perl xmllint textutil; do
  command -v "$outil" >/dev/null 2>&1 || { echo "$outil est introuvable sur cet ordinateur."; exit 3; }
done

TMP=$(mktemp -d) || exit 3
trap 'rm -rf "$TMP"' EXIT

# ---------- Format du cadre ----------
ext=$(printf '%s' "${CADRE##*.}" | tr '[:upper:]' '[:lower:]')
case "$ext" in
  docx) cp "$CADRE" "$TMP/cadre.docx" || exit 3 ;;
  doc|odt|rtf)
    textutil -convert docx "$CADRE" -output "$TMP/cadre.docx" >/dev/null 2>&1 && [ -s "$TMP/cadre.docx" ] ||
      { echo "Conversion du .$ext en .docx impossible."; exit 3; }
    echo "CONVERTI $ext" ;;
  *) echo "Format non pris en charge pour le remplissage : .$ext (seuls .docx, .doc, .odt et .rtf le sont)."; exit 5 ;;
esac
mkdir "$TMP/x" && unzip -q "$TMP/cadre.docx" -d "$TMP/x" 2>/dev/null && [ -s "$TMP/x/word/document.xml" ] ||
  { echo "Le cadre n'est pas un .docx lisible."; exit 3; }
xmllint --noout "$TMP/x/word/document.xml" 2>/dev/null || { echo "Le XML du cadre est illisible."; exit 3; }
if [ -f "$TMP/x/word/settings.xml" ] &&
   grep -qE '<w:documentProtection[^>]*w:enforcement="(1|true|on)"' "$TMP/x/word/settings.xml"; then
  echo "PROTEGE"
fi

# ---------- Programme perl : lecture des paragraphes, insertion, contrôles ----------
read -r -d '' PERL <<'FIN_PERL'
use strict; use warnings; use utf8;
binmode STDOUT, ':encoding(UTF-8)';
my $MARQ = "[\x{C0} COMPL\x{C9}TER";
my $MOTIF = qr/(\[\x{C0} COMPL\x{C9}TER[^\]]*\]?)/;

sub lire { my ($f) = @_; open my $h, '<:encoding(UTF-8)', $f or die "lecture $f\n"; local $/; my $t = <$h>; close $h; return $t; }
sub ecrire { my ($f, $t) = @_; open my $h, '>:encoding(UTF-8)', $f or die "ecriture $f\n"; print $h $t; close $h; }
sub norm { my ($t) = @_; $t =~ s/[\s\x{a0}\x{202f}]+/ /g; $t =~ s/^ | $//g; return $t; }
# Clé de comparaison du texte d'ancrage : sans casse, apostrophes et tirets typographiques ramenés au clavier.
sub cle { my ($t) = @_; $t = lc norm($t); $t =~ tr/\x{2019}\x{2018}\x{2013}\x{2014}\x{ab}\x{bb}/''\-\-""/; $t =~ s/" | "/"/g; return $t; }
sub decode_ent {
  my ($t) = @_;
  $t =~ s/&#x([0-9a-fA-F]+);/chr(hex $1)/ge; $t =~ s/&#(\d+);/chr($1)/ge;
  $t =~ s/&lt;/</g; $t =~ s/&gt;/>/g; $t =~ s/&quot;/"/g; $t =~ s/&apos;/'/g; $t =~ s/&amp;/&/g;
  return $t;
}

# Paragraphes du corps, dans l'ordre d'ouverture : début, fin (octets du texte), texte, style, place dans un tableau.
sub paragraphes {
  my ($x) = @_;
  my (@p, @pile, @tbl); my ($dans_t, $ntbl) = (0, 0);
  while ($x =~ /(<[?!][^>]*>)|<(\/?)([A-Za-z0-9_:.-]+)((?:[^>"']|"[^"]*"|'[^']*')*?)(\/?)>|([^<]+)/g) {
    my ($deb, $fin) = ($-[0], $+[0]);
    next if defined $1;
    if (defined $6) { $p[$pile[-1]]{texte} .= decode_ent($6) if $dans_t && @pile; next; }
    my ($ferme, $nom, $attrs, $auto) = ($2, $3, $4, $5);
    if ($nom eq 'w:p') {
      if ($ferme) { my $i = pop @pile; $p[$i]{fin} = $fin if defined $i; }
      else {
        my $lieu = @tbl ? "tableau $tbl[-1]{n}, ligne $tbl[-1]{l}, cellule $tbl[-1]{c}" : '';
        push @p, { deb => $deb, fin => ($auto ? $fin : undef), texte => '', style => '', lieu => $lieu };
        push @pile, $#p unless $auto;
      }
    }
    elsif ($nom eq 'w:t') { $dans_t = ($ferme || $auto) ? 0 : 1; }
    elsif (($nom eq 'w:tab' && $attrs !~ /w:val/) || $nom eq 'w:br' || $nom eq 'w:cr') { $p[$pile[-1]]{texte} .= ' ' if @pile && !$ferme; }
    elsif ($nom eq 'w:pStyle' && @pile && $attrs =~ /w:val="([^"]*)"/) { $p[$pile[-1]]{style} ||= $1; }
    elsif ($nom eq 'w:tbl' && !$auto) { if ($ferme) { pop @tbl } else { push @tbl, { n => ++$ntbl, l => 0, c => 0 } } }
    elsif ($nom eq 'w:tr' && !$ferme && @tbl) { $tbl[-1]{l}++; $tbl[-1]{c} = 0; }
    elsif ($nom eq 'w:tc' && !$ferme && @tbl) { $tbl[-1]{c}++; }
  }
  for (@p) { die "paragraphe non fermé\n" unless defined $_->{fin}; $_->{texte} = norm($_->{texte}); }
  return @p;
}

sub echappe { my ($t) = @_; $t =~ s/[^\x09\x0A\x0D\x20-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}]//g; $t =~ s/&/&amp;/g; $t =~ s/</&lt;/g; $t =~ s/>/&gt;/g; return $t; }
sub run_xml {
  my ($t, $hl) = @_;
  my $rpr = $hl ? '<w:rPr><w:b/><w:bCs/><w:color w:val="C00000"/><w:highlight w:val="yellow"/></w:rPr>' : '';
  return '<w:r>' . $rpr . '<w:t xml:space="preserve">' . echappe($t) . '</w:t></w:r>';
}
sub para_xml {
  my ($ligne) = @_;
  my $ppr = '';
  my $runs = '';
  if ($ligne =~ s/^-\s+//) { $ppr = '<w:pPr><w:ind w:left="567" w:hanging="283"/></w:pPr>'; $runs = run_xml("\x{2013} ", 0); }
  my @m = split $MOTIF, $ligne;
  for my $k (0 .. $#m) { $runs .= run_xml($m[$k], $k % 2) if length $m[$k]; }
  return '<w:p>' . $ppr . $runs . '</w:p>';
}

my $mode = shift @ARGV;
if ($mode eq 'lister') {
  my @p = paragraphes(lire($ARGV[0]));
  for my $i (0 .. $#p) {
    my $q = $p[$i];
    my $lieu = $q->{lieu} ? " [$q->{lieu}]" : '';
    my $style = $q->{style} ? " {$q->{style}}" : '';
    my $t = length $q->{texte} ? $q->{texte} : '(vide)';
    print "\x{b6}" . ($i + 1) . "$lieu$style | $t\n";
  }
  print "PARAGRAPHES " . scalar(@p) . "\n";
  exit 0;
}

# remplir <document.xml> <reponses.txt> <sortie.xml>
my ($doc, $rep, $out) = @ARGV;
my $x = lire($doc);
my @p = eval { paragraphes($x) };
if ($@) { print "Lecture du cadre impossible : $@"; exit 7; }
my $texte_rep = lire($rep); $texte_rep =~ s/^\x{feff}//; $texte_rep =~ s/\r//g;

my (@blocs, $bloc);
my $nl = 0;
for my $l (split /\n/, $texte_rep) {
  $nl++;
  if ($l =~ /^###\s*(\d+)\s*(?:\|\s*(.*))?$/) {
    $bloc = { n => $1, ancre => norm($2 // ''), max => undef, lignes => [], nl => $nl };
    push @blocs, $bloc; next;
  }
  if (!$bloc) { next if $l =~ /^\s*$/; print "Ligne $nl : texte avant le premier « ### » du fichier de réponses.\n"; exit 6; }
  if ($l =~ /^\@max\s+(\d+)\s*$/ && !@{$bloc->{lignes}}) { $bloc->{max} = $1; next; }
  next if $l =~ /^\s*$/;
  push @{$bloc->{lignes}}, norm($l);
}
@blocs or do { print "Le fichier de réponses ne contient aucun bloc « ### ».\n"; exit 6; };
my (%vu, $erreurs);
for my $bl (@blocs) {
  my $n = $bl->{n};
  my $msg;
  if ($vu{$n}++) { $msg = "le paragraphe $n est rempli deux fois"; }
  elsif ($n < 1 || $n > @p) { $msg = "le paragraphe $n n'existe pas (le cadre en a " . scalar(@p) . ")"; }
  elsif (!@{$bl->{lignes}}) { $msg = "aucune réponse sous « ### $n »"; }
  else {
    my $t = $p[$n - 1]{texte};
    if (!length $bl->{ancre}) { $msg = "le paragraphe $n n'est pas vide : « " . substr($t, 0, 60) . " »" if length $t; }
    elsif (index(cle($t), cle($bl->{ancre})) != 0) { $msg = "le paragraphe $n commence par « " . substr($t, 0, 60) . " », pas par « $bl->{ancre} »"; }
    if (!$msg && defined $bl->{max}) {
      my $long = 0; $long += length($_) for @{$bl->{lignes}}; $long += @{$bl->{lignes}} - 1;
      $msg = "la réponse au paragraphe $n fait $long caractères pour $bl->{max} au maximum" if $long > $bl->{max};
    }
  }
  if ($msg) { print "Bloc de la ligne $bl->{nl} : $msg.\n"; $erreurs++; }
}
exit 6 if $erreurs;

# Insertion, de la fin vers le début pour garder les positions.
my $nouveau = $x;
my ($marq_rep, $nb_par) = (0, 0);
for my $bl (sort { $b->{n} <=> $a->{n} } @blocs) {
  my $q = $p[$bl->{n} - 1];
  my $xml = join '', map { para_xml($_) } @{$bl->{lignes}};
  $nb_par += @{$bl->{lignes}};
  $marq_rep += () = join("\n", @{$bl->{lignes}}) =~ /\Q$MARQ\E/g;
  my $pos = length($q->{texte}) ? $q->{fin} : $q->{deb};
  substr($nouveau, $pos, 0) = $xml;
}

# Contrôles, en relisant le XML produit : texte de l'acheteur intact et dans l'ordre, nombre de paragraphes,
# marqueurs tous surlignés.
my @n = eval { paragraphes($nouveau) };
if ($@) { print "Relecture impossible : $@"; exit 7; }
if (@n != @p + $nb_par) { print "Contrôle : " . scalar(@n) . " paragraphes au lieu de " . (@p + $nb_par) . ".\n"; exit 7; }
my $j = 0;
for my $q (@n) { $j++ if $j < @p && $q->{texte} eq $p[$j]{texte}; }
if ($j != @p) { print "Contrôle : le texte de l'acheteur n'est plus intact (paragraphe " . ($j + 1) . ").\n"; exit 7; }
my $marq_orig = () = $x =~ /\Q$MARQ\E/g;
my $marq_tot = () = $nouveau =~ /\Q$MARQ\E/g;
if ($marq_tot != $marq_orig + $marq_rep) { print "Contrôle : $marq_tot [À COMPLÉTER] au lieu de " . ($marq_orig + $marq_rep) . ".\n"; exit 7; }
my $surl = 0;
while ($nouveau =~ /<w:r>(.*?)<\/w:r>/gs) { my $r = $1; $surl++ if index($r, $MARQ) >= 0 && $r =~ /<w:highlight w:val="yellow"\/>/; }
if ($surl < $marq_rep) { print "Contrôle : $surl [À COMPLÉTER] surlignés sur $marq_rep.\n"; exit 7; }
ecrire($out, $nouveau);
print "BLOCS " . scalar(@blocs) . " SURLIGNES $marq_rep\n";
exit 0;
FIN_PERL

if [ "$MODE" = lister ]; then
  perl -e "$PERL" lister "$TMP/x/word/document.xml" || { echo "Lecture du cadre impossible."; exit 3; }
  exit 0
fi

resultat=$(perl -e "$PERL" remplir "$TMP/x/word/document.xml" "$REPONSES" "$TMP/document.xml"); code=$?
echo "$resultat"
[ "$code" = 0 ] || exit "$code"
read -r _ BLOCS _ SURL <<< "$(tail -1 <<< "$resultat")"

# ---------- Recomposition : copie du cadre, seule word/document.xml est remplacée ----------
xmllint --noout "$TMP/document.xml" 2>/dev/null || { echo "Contrôle : le XML produit est illisible."; exit 7; }
cp "$TMP/cadre.docx" "$TMP/final.docx" || exit 7
mkdir -p "$TMP/y/word" && cp "$TMP/document.xml" "$TMP/y/word/document.xml" || exit 7
(cd "$TMP/y" && zip -q -X "$TMP/final.docx" word/document.xml) || { echo "Recomposition du .docx impossible."; exit 7; }

# ---------- Relecture du fichier final ----------
unzip -tq "$TMP/final.docx" >/dev/null 2>&1 || { echo "Contrôle : l'archive produite est invalide."; exit 7; }
[ "$(unzip -Z1 "$TMP/final.docx" | head -1)" = "$(unzip -Z1 "$TMP/cadre.docx" | head -1)" ] || { echo "Contrôle : ordre des parties modifié."; exit 7; }
mkdir "$TMP/z" && unzip -q "$TMP/final.docx" -d "$TMP/z" 2>/dev/null || { echo "Contrôle : le .docx produit est illisible."; exit 7; }
ecarts=$(diff -rq "$TMP/x" "$TMP/z" 2>&1 | grep -v "word/document.xml differ")
[ -z "$ecarts" ] || { echo "Contrôle : une autre partie que word/document.xml a changé : $(head -1 <<< "$ecarts")"; exit 7; }
cmp -s "$TMP/document.xml" "$TMP/z/word/document.xml" || { echo "Contrôle : word/document.xml n'est pas celui produit."; exit 7; }
textutil -convert txt -stdout "$TMP/final.docx" > "$TMP/relu.txt" 2>/dev/null && [ -s "$TMP/relu.txt" ] ||
  { echo "Contrôle : textutil ne relit pas le cadre rempli."; exit 7; }
[ "$(grep -o '\[À COMPLÉTER' "$TMP/relu.txt" | wc -l | tr -d ' ')" -ge "$SURL" ] ||
  { echo "Contrôle : des [À COMPLÉTER] manquent à la relecture."; exit 7; }

[ ! -e "$SORTIE" ] || { echo "Le fichier de sortie existe déjà : rien n'est écrasé."; exit 4; }
cp -n "$TMP/final.docx" "$SORTIE" || exit 7
echo "CADRE $SORTIE $BLOCS $SURL"
exit 0
