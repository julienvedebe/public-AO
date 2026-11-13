# Convertit le memoire technique (HTML) en .docx sous Windows, sans Word ni rien a installer :
# le script assemble lui-meme un .docx minimal (une archive ZIP de fichiers XML) avec l'API .NET
# de compression (System.IO.Compression), et PAS avec Compress-Archive.
#
# Usage (Windows PowerShell 5.1 ou PowerShell 7) :
#   powershell -NoProfile -ExecutionPolicy Bypass -File memoire-vers-docx-windows.ps1 memoire.html C:\chemin\memoire-technique.docx
#
# Ce fichier ne contient volontairement que des caracteres ASCII : Windows PowerShell 5.1 lit un
# script sans BOM comme du texte ANSI (cp1252) et abimerait tout accent. Les caracteres accentues
# dont le script a besoin sont construits avec [char]0x.... Les messages sont donc sans accents.
#
# Codes de sortie (les memes que memoire-vers-docx-mac.sh) :
#   0   .docx produit, controle, [A COMPLETER] surlignes
#   10  .docx impossible : un .rtf de secours a ete produit a cote (meme nom)
#   2   fichier HTML introuvable ou arguments manquants
#   3   rien n'a pu etre produit (HTML illisible, dossier de sortie absent, ecriture impossible)
#   4   le fichier de sortie existe deja (rien n'est ecrase)
# La derniere ligne affichee dit ce qui a ete produit : "DOCX <chemin> <n>" ou "RTF <chemin> <n>"
# (n = nombre de passages [A COMPLETER] surlignes).
#
# Variable de test : MEMOIRE_FORCER_ECHEC_DOCX=1 simule un echec de la production du .docx.
#
# Compatibilite 5.1 : pas de ??, ?., ternaire, && ou || entre commandes, ConvertFrom-Json -Depth ;
# aucun XML ni RTF n'est ecrit avec Set-Content ou Out-File (BOM en 5.1) : les parties XML sont
# ecrites en octets UTF-8 sans BOM (UTF8Encoding $false) dans l'archive, le RTF en ASCII pur.

param(
  [string]$Html,
  [string]$Docx
)

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------- utilitaires

try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false } catch { }

function Say([string]$texte) { [Console]::Out.WriteLine($texte) }

$Utf8SansBom = New-Object System.Text.UTF8Encoding $false

# Marqueur "[A COMPLETER" avec ses deux lettres accentuees (A grave = 0x00C0, E aigu majuscule = 0x00C9).
$Marqueur = '[' + [string][char]0x00C0 + ' COMPL' + [string][char]0x00C9 + 'TER'
$MotifMarqueur = '\[' + [string][char]0x00C0 + ' COMPL' + [string][char]0x00C9 + 'TER[^\]]*\]?'

function Compter-Marqueurs([string]$texte) {
  return [regex]::Matches($texte, [regex]::Escape($Marqueur)).Count
}

function Resoudre-Chemin([string]$p) {
  return $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($p)
}

# ---------------------------------------------------------------- lecture du HTML -> modele
# Le modele est une liste de blocs :
#   paragraphe : @{ type='p'; style='Normal'|'Heading1'|'Heading2'|'Heading3'|'ListParagraph';
#                   liste=$null | @{ numId=; niveau=; ordonnee= }; runs=liste de runs }
#   tableau    : @{ type='table'; lignes=liste de lignes ; ligne = liste de cellules ; cellule = liste de blocs }
#   run        : @{ k='t'; text=; b=; i=; hl= }  ou  @{ k='br' }

$script:blocs = New-Object System.Collections.ArrayList
$script:sortie = $script:blocs
$script:cur = $null
$script:gras = 0
$script:ital = 0
$script:spans = New-Object System.Collections.ArrayList
$script:listes = New-Object System.Collections.ArrayList
$script:nbOl = 0
$script:tblProf = 0
$script:tbl = $null
$script:ligne = $null
$script:cellule = $null
$script:celluleEntete = $false

function Ouvrir-Para([string]$style, $liste) {
  $script:cur = @{ style = $style; liste = $liste; runs = (New-Object System.Collections.ArrayList) }
}

function Fermer-Para {
  if ($null -eq $script:cur) { return }
  $runs = $script:cur.runs
  # Retire l'espace final du dernier passage de texte, puis les passages vides.
  if ($runs.Count -gt 0) {
    $dernier = $runs[$runs.Count - 1]
    if ($dernier.k -eq 't') { $dernier.text = $dernier.text.TrimEnd(' ') }
  }
  $garde = New-Object System.Collections.ArrayList
  foreach ($r in $runs) {
    if ($r.k -eq 'br' -or $r.text.Length -gt 0) { [void]$garde.Add($r) }
  }
  if ($garde.Count -gt 0) {
    $script:cur.runs = $garde
    $script:cur.type = 'p'
    [void]$script:sortie.Add($script:cur)
  }
  $script:cur = $null
}

function Ajouter-Run([string]$texte, [bool]$hl) {
  $runs = $script:cur.runs
  if ($runs.Count -eq 0) {
    $texte = $texte.TrimStart(' ')
  } else {
    $dernier = $runs[$runs.Count - 1]
    if ($dernier.k -eq 'br') { $texte = $texte.TrimStart(' ') }
    elseif ($dernier.text.EndsWith(' ')) { $texte = $texte.TrimStart(' ') }
  }
  if ($texte.Length -eq 0) { return }
  $gras = ($script:gras -gt 0) -or $hl
  $ital = ($script:ital -gt 0)
  [void]$runs.Add(@{ k = 't'; text = $texte; b = $gras; i = $ital; hl = $hl })
}

function Ajouter-Texte([string]$brut) {
  $t = [System.Net.WebUtility]::HtmlDecode($brut)
  # Les blancs du HTML se resserrent en une espace ; l'espace insecable (&nbsp;) est conservee.
  $t = [regex]::Replace($t, '[ \t\r\n\f]+', ' ')
  if ($t.Length -eq 0) { return }
  if ($null -eq $script:cur) {
    if ($t -eq ' ') { return }
    if ($script:listes.Count -gt 0) {
      $l = $script:listes[$script:listes.Count - 1]
      Ouvrir-Para 'ListParagraph' @{ numId = $l.numId; niveau = [Math]::Min($script:listes.Count - 1, 2); ordonnee = $l.ordonnee }
    } else {
      Ouvrir-Para 'Normal' $null
    }
  }
  $dansSpan = $false
  if ($script:spans.Count -gt 0) { $dansSpan = [bool]$script:spans[$script:spans.Count - 1] }
  if ($dansSpan) {
    Ajouter-Run $t $true
  } else {
    # Un [A COMPLETER] hors du balisage prevu est quand meme surligne.
    $morceaux = [regex]::Split($t, '(' + $MotifMarqueur + ')')
    for ($k = 0; $k -lt $morceaux.Length; $k++) {
      if ($morceaux[$k].Length -gt 0) { Ajouter-Run $morceaux[$k] (($k % 2) -eq 1) }
    }
  }
}

function Fermer-Cellule {
  if ($null -eq $script:cellule) { return }
  Fermer-Para
  [void]$script:ligne.Add($script:cellule)
  $script:cellule = $null
  $script:sortie = $script:blocs
  if ($script:celluleEntete) { $script:gras = [Math]::Max(0, $script:gras - 1); $script:celluleEntete = $false }
}

function Fermer-Ligne {
  Fermer-Cellule
  if ($null -ne $script:ligne) {
    [void]$script:tbl.Add($script:ligne)
    $script:ligne = $null
  }
}

function Traiter-Balise([bool]$ferme, [string]$nom, [string]$attrs) {
  if ($nom -match '^h([1-3])$') {
    Fermer-Para
    if (-not $ferme) { Ouvrir-Para ('Heading' + $Matches[1]) $null }
  }
  elseif ($nom -eq 'p' -or $nom -eq 'div') {
    if ($ferme) {
      if ($null -ne $script:cur -and $null -eq $script:cur.liste) { Fermer-Para }
    } else {
      # Un <p> dans un <li> encore vide reprend la puce du <li>.
      $reprise = ($null -ne $script:cur -and $null -ne $script:cur.liste -and $script:cur.runs.Count -eq 0)
      if (-not $reprise) { Fermer-Para; Ouvrir-Para 'Normal' $null }
    }
  }
  elseif ($nom -eq 'ul' -or $nom -eq 'ol') {
    Fermer-Para
    if ($ferme) {
      if ($script:listes.Count -gt 0) { $script:listes.RemoveAt($script:listes.Count - 1) }
    } else {
      if ($nom -eq 'ol') {
        $script:nbOl = $script:nbOl + 1
        [void]$script:listes.Add(@{ numId = ($script:nbOl + 1); ordonnee = $true })
      } else {
        [void]$script:listes.Add(@{ numId = 1; ordonnee = $false })
      }
    }
  }
  elseif ($nom -eq 'li') {
    Fermer-Para
    if (-not $ferme) {
      if ($script:listes.Count -gt 0) {
        $l = $script:listes[$script:listes.Count - 1]
        $liste = @{ numId = $l.numId; niveau = [Math]::Min($script:listes.Count - 1, 2); ordonnee = $l.ordonnee }
      } else {
        $liste = @{ numId = 1; niveau = 0; ordonnee = $false }
      }
      Ouvrir-Para 'ListParagraph' $liste
    }
  }
  elseif ($nom -eq 'strong' -or $nom -eq 'b') {
    if ($ferme) { $script:gras = [Math]::Max(0, $script:gras - 1) } else { $script:gras = $script:gras + 1 }
  }
  elseif ($nom -eq 'em' -or $nom -eq 'i') {
    if ($ferme) { $script:ital = [Math]::Max(0, $script:ital - 1) } else { $script:ital = $script:ital + 1 }
  }
  elseif ($nom -eq 'span') {
    if ($ferme) {
      if ($script:spans.Count -gt 0) { $script:spans.RemoveAt($script:spans.Count - 1) }
    } else {
      [void]$script:spans.Add([bool]($attrs -match 'class\s*=\s*["''][^"'']*\ba-completer\b'))
    }
  }
  elseif ($nom -eq 'br') {
    if (-not $ferme -and $null -ne $script:cur) { [void]$script:cur.runs.Add(@{ k = 'br' }) }
  }
  elseif ($nom -eq 'table') {
    if ($ferme) {
      $script:tblProf = [Math]::Max(0, $script:tblProf - 1)
      if ($script:tblProf -eq 0 -and $null -ne $script:tbl) {
        Fermer-Ligne
        [void]$script:blocs.Add(@{ type = 'table'; lignes = $script:tbl })
        $script:tbl = $null
      }
    } else {
      if ($script:tblProf -eq 0) {
        Fermer-Para
        $script:tbl = New-Object System.Collections.ArrayList
      }
      $script:tblProf = $script:tblProf + 1
    }
  }
  elseif ($nom -eq 'tr' -and $script:tblProf -eq 1) {
    Fermer-Ligne
    if (-not $ferme) { $script:ligne = New-Object System.Collections.ArrayList }
  }
  elseif (($nom -eq 'td' -or $nom -eq 'th') -and $script:tblProf -eq 1) {
    Fermer-Cellule
    if (-not $ferme) {
      if ($null -eq $script:ligne) { $script:ligne = New-Object System.Collections.ArrayList }
      Fermer-Para
      $script:cellule = New-Object System.Collections.ArrayList
      $script:sortie = $script:cellule
      if ($nom -eq 'th') { $script:gras = $script:gras + 1; $script:celluleEntete = $true }
    }
  }
  # Toute autre balise (html, body, thead, tbody, a, u, font...) est ignoree : son texte est conserve.
}

function Lire-Html([string]$source) {
  $s = $source
  $s = [regex]::Replace($s, '(?s)<!--.*?-->', '')
  $s = [regex]::Replace($s, '(?is)<head\b.*?</head>', '')
  $s = [regex]::Replace($s, '(?is)<(script|style)\b.*?</\1>', '')
  $s = [regex]::Replace($s, '(?is)<!DOCTYPE[^>]*>', '')
  $m = [regex]::Match($s, '(?is)<body\b[^>]*>(.*)</body\s*>')
  if ($m.Success) { $s = $m.Groups[1].Value }
  $script:htmlVisible = $s

  $re = New-Object System.Text.RegularExpressions.Regex('<(/?)([a-zA-Z][a-zA-Z0-9]*)((?:[^>"'']|"[^"]*"|''[^'']*'')*)>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
  $pos = 0
  foreach ($b in $re.Matches($s)) {
    if ($b.Index -gt $pos) { Ajouter-Texte $s.Substring($pos, $b.Index - $pos) }
    Traiter-Balise ($b.Groups[1].Value -eq '/') $b.Groups[2].Value.ToLowerInvariant() $b.Groups[3].Value
    $pos = $b.Index + $b.Length
  }
  if ($pos -lt $s.Length) { Ajouter-Texte $s.Substring($pos) }
  if ($script:tblProf -gt 0 -and $null -ne $script:tbl) {
    Fermer-Ligne
    [void]$script:blocs.Add(@{ type = 'table'; lignes = $script:tbl })
    $script:tbl = $null
  }
  Fermer-Para
}

# ---------------------------------------------------------------- production du .docx

function Xml-Echappe([string]$t) {
  $t = [regex]::Replace($t, '[^\x09\x0A\x0D\x20-\uD7FF\uE000-\uFFFD\uD800-\uDFFF]', '')
  $t = $t.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;')
  return $t
}

function Run-Xml($run) {
  if ($run.k -eq 'br') { return '<w:r><w:br/></w:r>' }
  $rpr = ''
  if ($run.b) { $rpr = $rpr + '<w:b/><w:bCs/>' }
  if ($run.i) { $rpr = $rpr + '<w:i/><w:iCs/>' }
  if ($run.hl) { $rpr = $rpr + '<w:color w:val="C00000"/><w:highlight w:val="yellow"/>' }
  if ($rpr.Length -gt 0) { $rpr = '<w:rPr>' + $rpr + '</w:rPr>' }
  return '<w:r>' + $rpr + '<w:t xml:space="preserve">' + (Xml-Echappe $run.text) + '</w:t></w:r>'
}

function Para-Xml($p) {
  $ppr = ''
  if ($p.style -ne 'Normal') { $ppr = '<w:pStyle w:val="' + $p.style + '"/>' }
  if ($null -ne $p.liste) {
    $ppr = $ppr + '<w:numPr><w:ilvl w:val="' + $p.liste.niveau + '"/><w:numId w:val="' + $p.liste.numId + '"/></w:numPr>'
  }
  if ($ppr.Length -gt 0) { $ppr = '<w:pPr>' + $ppr + '</w:pPr>' }
  $sb = New-Object System.Text.StringBuilder
  foreach ($r in $p.runs) { [void]$sb.Append((Run-Xml $r)) }
  return '<w:p>' + $ppr + $sb.ToString() + '</w:p>'
}

function Table-Xml($t) {
  $nb = 1
  foreach ($l in $t.lignes) { if ($l.Count -gt $nb) { $nb = $l.Count } }
  $largeur = [int][Math]::Floor(9638 / $nb)
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.Append('<w:tbl><w:tblPr><w:tblStyle w:val="TableGrid"/><w:tblW w:w="5000" w:type="pct"/><w:tblLook w:val="04A0" w:firstRow="1" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="1"/></w:tblPr><w:tblGrid>')
  for ($k = 0; $k -lt $nb; $k++) { [void]$sb.Append('<w:gridCol w:w="' + $largeur + '"/>') }
  [void]$sb.Append('</w:tblGrid>')
  foreach ($l in $t.lignes) {
    [void]$sb.Append('<w:tr>')
    foreach ($c in $l) {
      [void]$sb.Append('<w:tc><w:tcPr><w:tcW w:w="' + $largeur + '" w:type="dxa"/></w:tcPr>')
      $contenu = ''
      foreach ($b in $c) { $contenu = $contenu + (Para-Xml $b) }
      if ($contenu.Length -eq 0) { $contenu = '<w:p/>' }
      [void]$sb.Append($contenu)
      [void]$sb.Append('</w:tc>')
    }
    # Une ligne plus courte que la grille est completee par des cellules vides.
    for ($k = $l.Count; $k -lt $nb; $k++) {
      [void]$sb.Append('<w:tc><w:tcPr><w:tcW w:w="' + $largeur + '" w:type="dxa"/></w:tcPr><w:p/></w:tc>')
    }
    [void]$sb.Append('</w:tr>')
  }
  [void]$sb.Append('</w:tbl><w:p/>')
  return $sb.ToString()
}

$Decl = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
$NsW = 'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"'

function Xml-Document {
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.Append($Decl + '<w:document ' + $NsW + ' xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:body>')
  foreach ($b in $script:blocs) {
    if ($b.type -eq 'table') { [void]$sb.Append((Table-Xml $b)) } else { [void]$sb.Append((Para-Xml $b)) }
  }
  [void]$sb.Append('<w:sectPr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="1134" w:right="1134" w:bottom="1134" w:left="1134" w:header="709" w:footer="709" w:gutter="0"/></w:sectPr></w:body></w:document>')
  return $sb.ToString()
}

function Xml-Numbering {
  $puce = [string][char]0x2022
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.Append($Decl + '<w:numbering ' + $NsW + '>')
  # Modele 0 : puces. Modele 1 : numerotation 1. 2. 3.
  [void]$sb.Append('<w:abstractNum w:abstractNumId="0"><w:multiLevelType w:val="hybridMultilevel"/>')
  for ($n = 0; $n -lt 3; $n++) {
    [void]$sb.Append('<w:lvl w:ilvl="' + $n + '"><w:start w:val="1"/><w:numFmt w:val="bullet"/><w:lvlText w:val="' + $puce + '"/><w:lvlJc w:val="left"/><w:pPr><w:ind w:left="' + (720 * ($n + 1)) + '" w:hanging="360"/></w:pPr></w:lvl>')
  }
  [void]$sb.Append('</w:abstractNum>')
  [void]$sb.Append('<w:abstractNum w:abstractNumId="1"><w:multiLevelType w:val="hybridMultilevel"/>')
  for ($n = 0; $n -lt 3; $n++) {
    [void]$sb.Append('<w:lvl w:ilvl="' + $n + '"><w:start w:val="1"/><w:numFmt w:val="decimal"/><w:lvlText w:val="%' + ($n + 1) + '."/><w:lvlJc w:val="left"/><w:pPr><w:ind w:left="' + (720 * ($n + 1)) + '" w:hanging="360"/></w:pPr></w:lvl>')
  }
  [void]$sb.Append('</w:abstractNum>')
  [void]$sb.Append('<w:num w:numId="1"><w:abstractNumId w:val="0"/></w:num>')
  # Une numerotation par liste <ol> (numId 2, 3...), chacune repart de 1. Le numId 2 existe toujours.
  $nbNum = [Math]::Max(1, $script:nbOl)
  for ($k = 1; $k -le $nbNum; $k++) {
    [void]$sb.Append('<w:num w:numId="' + ($k + 1) + '"><w:abstractNumId w:val="1"/><w:lvlOverride w:ilvl="0"><w:startOverride w:val="1"/></w:lvlOverride></w:num>')
  }
  [void]$sb.Append('</w:numbering>')
  return $sb.ToString()
}

function Xml-Types {
  return (@(
    $Decl,
    '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">',
    '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>',
    '<Default Extension="xml" ContentType="application/xml"/>',
    '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>',
    '<Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>',
    '<Override PartName="/word/numbering.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml"/>',
    '</Types>') -join '')
}

function Xml-Rels {
  return (@(
    $Decl,
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">',
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>',
    '</Relationships>') -join '')
}

function Xml-DocRels {
  return (@(
    $Decl,
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">',
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>',
    '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/numbering" Target="numbering.xml"/>',
    '</Relationships>') -join '')
}

function Style-Titre([int]$n, [int]$taille, [int]$avant) {
  return ('<w:style w:type="paragraph" w:styleId="Heading' + $n + '"><w:name w:val="heading ' + $n + '"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:uiPriority w:val="9"/><w:qFormat/>' +
    '<w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="' + $avant + '" w:after="120"/><w:outlineLvl w:val="' + ($n - 1) + '"/></w:pPr>' +
    '<w:rPr><w:b/><w:bCs/><w:sz w:val="' + $taille + '"/><w:szCs w:val="' + $taille + '"/></w:rPr></w:style>')
}

function Xml-Styles {
  $bord = ''
  foreach ($c in @('top', 'left', 'bottom', 'right', 'insideH', 'insideV')) {
    $bord = $bord + '<w:' + $c + ' w:val="single" w:sz="4" w:space="0" w:color="auto"/>'
  }
  return (@(
    $Decl,
    ('<w:styles ' + $NsW + '>'),
    '<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial" w:eastAsia="Arial" w:cs="Arial"/><w:sz w:val="22"/><w:szCs w:val="22"/><w:lang w:val="fr-FR" w:eastAsia="fr-FR" w:bidi="ar-SA"/></w:rPr></w:rPrDefault>',
    '<w:pPrDefault><w:pPr><w:spacing w:after="120" w:line="264" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>',
    '<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/></w:style>',
    '<w:style w:type="character" w:default="1" w:styleId="DefaultParagraphFont"><w:name w:val="Default Paragraph Font"/><w:uiPriority w:val="1"/><w:semiHidden/><w:unhideWhenUsed/></w:style>',
    '<w:style w:type="table" w:default="1" w:styleId="TableNormal"><w:name w:val="Normal Table"/><w:uiPriority w:val="99"/><w:semiHidden/><w:unhideWhenUsed/><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="108" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="108" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>',
    (Style-Titre 1 40 360),
    (Style-Titre 2 30 280),
    (Style-Titre 3 24 200),
    '<w:style w:type="paragraph" w:styleId="ListParagraph"><w:name w:val="List Paragraph"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="34"/><w:qFormat/><w:pPr><w:spacing w:after="60"/><w:contextualSpacing/></w:pPr></w:style>',
    ('<w:style w:type="table" w:styleId="TableGrid"><w:name w:val="Table Grid"/><w:basedOn w:val="TableNormal"/><w:uiPriority w:val="39"/><w:tblPr><w:tblBorders>' + $bord + '</w:tblBorders></w:tblPr></w:style>'),
    '</w:styles>') -join '')
}

# Ecrit l'archive. Les noms d'entree portent des "/" ; le fichier de types est en premier.
function Ecrire-Zip([string]$chemin, $entrees) {
  $zip = [System.IO.Compression.ZipFile]::Open($chemin, [System.IO.Compression.ZipArchiveMode]::Create)
  try {
    foreach ($e in $entrees) {
      $entree = $zip.CreateEntry($e.nom, [System.IO.Compression.CompressionLevel]::Optimal)
      $flux = $entree.Open()
      try {
        $octets = $Utf8SansBom.GetBytes($e.contenu)
        $flux.Write($octets, 0, $octets.Length)
      } finally { $flux.Dispose() }
    }
  } finally { $zip.Dispose() }
}

function Lire-Octets($entree) {
  $ms = New-Object System.IO.MemoryStream
  $flux = $entree.Open()
  try { $flux.CopyTo($ms) } finally { $flux.Dispose() }
  return , $ms.ToArray()
}

# Releit l'archive et controle ce qu'elle contient. Renvoie le nombre de [A COMPLETER] surlignes,
# ou leve une erreur.
function Controler-Docx([string]$chemin, [int]$attendu) {
  $strict = New-Object System.Text.UTF8Encoding $false, $true
  $zip = [System.IO.Compression.ZipFile]::OpenRead($chemin)
  try {
    $noms = New-Object System.Collections.ArrayList
    foreach ($e in $zip.Entries) { [void]$noms.Add($e.FullName) }
    if ($noms.Count -eq 0 -or $noms[0] -ne '[Content_Types].xml') { throw "l'archive ne commence pas par [Content_Types].xml" }
    foreach ($requis in @('[Content_Types].xml', '_rels/.rels', 'word/document.xml', 'word/styles.xml', 'word/_rels/document.xml.rels')) {
      if ($noms -notcontains $requis) { throw "partie absente de l'archive : $requis" }
    }
    $docXml = $null
    foreach ($e in $zip.Entries) {
      if ($e.FullName.Contains('\')) { throw "chemin avec antislash dans l'archive : $($e.FullName)" }
      if ($e.FullName -match '\.(xml|rels)$') {
        $octets = Lire-Octets $e
        if ($octets.Length -ge 3 -and $octets[0] -eq 0xEF -and $octets[1] -eq 0xBB -and $octets[2] -eq 0xBF) { throw "BOM dans $($e.FullName)" }
        $texte = $strict.GetString($octets)
        $xd = New-Object System.Xml.XmlDocument
        $xd.LoadXml($texte)
        if ($e.FullName -eq 'word/document.xml') { $docXml = $texte }
      }
    }
    $total = Compter-Marqueurs $docXml
    $sans = 0
    foreach ($r in [regex]::Matches($docXml, '(?s)<w:r>(.*?)</w:r>')) {
      $v = $r.Groups[1].Value
      if ($v.Contains($Marqueur) -and -not $v.Contains('<w:highlight w:val="yellow"/>')) { $sans = $sans + 1 }
    }
    if ($sans -ne 0) { throw "$sans passage(s) [A COMPLETER] sans surlignage" }
    if ($total -ne $attendu) { throw "$total [A COMPLETER] dans le .docx au lieu de $attendu" }
    return $total
  } finally { $zip.Dispose() }
}

function Faire-Docx {
  $script:docxOk = $false
  $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('memoire-' + [guid]::NewGuid().ToString('N'))
  try {
    if ($env:MEMOIRE_FORCER_ECHEC_DOCX -eq '1') { throw 'echec simule' }
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [void][System.IO.Directory]::CreateDirectory($tmp)
    $entrees = @(
      @{ nom = '[Content_Types].xml'; contenu = (Xml-Types) },
      @{ nom = '_rels/.rels'; contenu = (Xml-Rels) },
      @{ nom = 'word/document.xml'; contenu = (Xml-Document) },
      @{ nom = 'word/styles.xml'; contenu = (Xml-Styles) },
      @{ nom = 'word/numbering.xml'; contenu = (Xml-Numbering) },
      @{ nom = 'word/_rels/document.xml.rels'; contenu = (Xml-DocRels) }
    )
    $zipTmp = Join-Path $tmp 'final.docx'
    Ecrire-Zip $zipTmp $entrees
    $n = Controler-Docx $zipTmp $script:attendu
    # Copie finale : [System.IO.File]::Copy sans ecrasement leve une erreur si le fichier existe.
    [System.IO.File]::Copy($zipTmp, $Docx, $false)
    $script:docxN = $n
    $script:docxOk = $true
  } catch {
    Say ("Echec du .docx : " + $_.Exception.Message)
  } finally {
    if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue }
  }
}

# ---------------------------------------------------------------- repli : .rtf ecrit a la main

function Rtf-Texte([string]$t) {
  $sb = New-Object System.Text.StringBuilder
  foreach ($ch in $t.ToCharArray()) {
    $c = [int]$ch
    if ($c -eq 92 -or $c -eq 123 -or $c -eq 125) { [void]$sb.Append('\' + [string]$ch) }
    elseif ($c -ge 32 -and $c -lt 127) { [void]$sb.Append([string]$ch) }
    elseif ($c -ge 160 -and $c -le 255) { [void]$sb.Append("\'" + $c.ToString('x2')) }
    elseif ($c -lt 32) { }
    else {
      if ($c -gt 32767) { $c = $c - 65536 }
      [void]$sb.Append('\u' + $c.ToString() + '?')
    }
  }
  return $sb.ToString()
}

function Rtf-Runs($runs) {
  $sb = New-Object System.Text.StringBuilder
  foreach ($r in $runs) {
    if ($r.k -eq 'br') { [void]$sb.Append('\line '); continue }
    $ctrl = ''
    if ($r.b) { $ctrl = $ctrl + '\b' }
    if ($r.i) { $ctrl = $ctrl + '\i' }
    if ($r.hl) { $ctrl = $ctrl + '\cf2\highlight1\cb1' }
    if ($ctrl.Length -gt 0) { [void]$sb.Append('{' + $ctrl + ' ' + (Rtf-Texte $r.text) + '}') }
    else { [void]$sb.Append((Rtf-Texte $r.text)) }
  }
  return $sb.ToString()
}

function Rtf-Para($p, $compteurs) {
  $base = '\pard\plain\f0\fs22'
  if ($p.style -eq 'Heading1') { return $base.Replace('\fs22', '\fs40') + '\b\keepn\sb240\sa120 ' + (Rtf-Runs $p.runs) + '\par' }
  if ($p.style -eq 'Heading2') { return $base.Replace('\fs22', '\fs30') + '\b\keepn\sb200\sa120 ' + (Rtf-Runs $p.runs) + '\par' }
  if ($p.style -eq 'Heading3') { return $base.Replace('\fs22', '\fs24') + '\b\keepn\sb160\sa120 ' + (Rtf-Runs $p.runs) + '\par' }
  if ($null -ne $p.liste) {
    $retrait = 567 * ($p.liste.niveau + 1)
    $puce = '\u8226?'
    if ($p.liste.ordonnee) {
      $cle = [string]$p.liste.numId + ':' + [string]$p.liste.niveau
      if ($compteurs.ContainsKey($cle)) { $compteurs[$cle] = $compteurs[$cle] + 1 } else { $compteurs[$cle] = 1 }
      $puce = [string]$compteurs[$cle] + '.'
    }
    return $base + '\sa60\li' + $retrait + '\fi-283 ' + $puce + '\tab ' + (Rtf-Runs $p.runs) + '\par'
  }
  return $base + '\sa120 ' + (Rtf-Runs $p.runs) + '\par'
}

function Rtf-Document {
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.Append('{\rtf1\ansi\ansicpg1252\deff0\deflang1036{\fonttbl{\f0\fswiss\fcharset0 Arial;}}{\colortbl;\red255\green255\blue0;\red192\green0\blue0;}\viewkind4\uc1 ')
  $compteurs = @{}
  foreach ($b in $script:blocs) {
    if ($b.type -eq 'table') {
      $nb = 1
      foreach ($l in $b.lignes) { if ($l.Count -gt $nb) { $nb = $l.Count } }
      $bords = '\clbrdrt\brdrs\brdrw10\clbrdrl\brdrs\brdrw10\clbrdrb\brdrs\brdrw10\clbrdrr\brdrs\brdrw10'
      foreach ($l in $b.lignes) {
        [void]$sb.Append('\trowd\trgaph108\trleft0')
        for ($k = 1; $k -le $nb; $k++) { [void]$sb.Append($bords + '\cellx' + [int][Math]::Floor(9638 * $k / $nb)) }
        for ($k = 0; $k -lt $nb; $k++) {
          $contenu = New-Object System.Collections.ArrayList
          if ($k -lt $l.Count) {
            foreach ($cb in $l[$k]) { [void]$contenu.Add((Rtf-Runs $cb.runs)) }
          }
          [void]$sb.Append('\pard\plain\intbl\f0\fs22 ' + ([string]::Join('\par ', $contenu.ToArray())) + '\cell')
        }
        [void]$sb.Append('\row ')
      }
      [void]$sb.Append('\pard\plain\par ')
    } else {
      [void]$sb.Append((Rtf-Para $b $compteurs))
      [void]$sb.Append(' ')
    }
  }
  [void]$sb.Append('}')
  return $sb.ToString()
}

function Faire-Rtf {
  $script:rtfOk = $false
  $cree = $false
  try {
    $rtf = Rtf-Document
    # Controles : uniquement de l'ASCII, accolades equilibrees, surlignages jaunes en nombre attendu.
    if ($rtf -match '[^\x00-\x7F]') { throw 'caractere non ASCII dans le RTF' }
    $sansEchap = [regex]::Replace($rtf, '\\[\\{}]', '')
    $ouvrantes = $sansEchap.Length - $sansEchap.Replace('{', '').Length
    $fermantes = $sansEchap.Length - $sansEchap.Replace('}', '').Length
    if ($ouvrantes -ne $fermantes) { throw 'accolades desequilibrees dans le RTF' }
    $n = [regex]::Matches($rtf, '\\highlight1(?![0-9])').Count
    if ($n -ne $script:attendu) { throw "$n surlignage(s) dans le RTF au lieu de $($script:attendu)" }
    # CreateNew : leve une erreur si le fichier existe deja (jamais d'ecrasement).
    $octets = [System.Text.Encoding]::ASCII.GetBytes($rtf)
    $flux = New-Object System.IO.FileStream($script:RtfChemin, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write)
    $cree = $true
    try { $flux.Write($octets, 0, $octets.Length) } finally { $flux.Dispose() }
    $script:rtfN = $n
    $script:rtfOk = $true
  } catch {
    Say ("Echec du .rtf : " + $_.Exception.Message)
    # Un .rtf cree mais incomplet est retire ; un fichier deja present n'est jamais touche.
    if ($cree -and (Test-Path -LiteralPath $script:RtfChemin)) { Remove-Item -LiteralPath $script:RtfChemin -Force -ErrorAction SilentlyContinue }
  }
}

# ---------------------------------------------------------------- programme principal

try {
  if ([string]::IsNullOrEmpty($Html) -or [string]::IsNullOrEmpty($Docx)) {
    Say 'Usage : memoire-vers-docx-windows.ps1 memoire.html sortie.docx'
    exit 2
  }
  $Html = Resoudre-Chemin $Html
  $Docx = Resoudre-Chemin $Docx
  if (-not (Test-Path -LiteralPath $Html -PathType Leaf)) {
    Say "Fichier HTML introuvable : $Html"
    exit 2
  }
  if ($Docx -match '(?i)\.docx$') { $script:RtfChemin = $Docx.Substring(0, $Docx.Length - 5) + '.rtf' } else { $script:RtfChemin = $Docx + '.rtf' }
  if ((Test-Path -LiteralPath $Docx) -or (Test-Path -LiteralPath $script:RtfChemin)) {
    Say "Le fichier de sortie existe deja : rien n'est ecrase."
    exit 4
  }
  $dossierSortie = Split-Path -Parent $Docx
  if (-not (Test-Path -LiteralPath $dossierSortie -PathType Container)) {
    Say "Le dossier de sortie n'existe pas : $dossierSortie"
    exit 3
  }

  # Lecture du HTML (UTF-8, avec ou sans BOM) et construction du modele.
  $source = [System.IO.File]::ReadAllText($Html, $Utf8SansBom)
  Lire-Html $source
  if ($script:blocs.Count -eq 0) {
    Say 'Le HTML ne contient aucun texte.'
    exit 3
  }
  # Nombre de passages [A COMPLETER] dans le HTML visible (sans commentaires), a comparer avec le resultat.
  $script:attendu = Compter-Marqueurs ([System.Net.WebUtility]::HtmlDecode($script:htmlVisible))

  Faire-Docx
  if ($script:docxOk) {
    Say ("DOCX " + $Docx + " " + $script:docxN)
    exit 0
  }
  Say "La production du .docx a echoue : production d'un .rtf de secours."

  Faire-Rtf
  if ($script:rtfOk) {
    Say ("RTF " + $script:RtfChemin + " " + $script:rtfN)
    exit 10
  }
  Say 'Production du .rtf impossible.'
  exit 3
} catch {
  Say ("Erreur inattendue : " + $_.Exception.Message)
  exit 3
}
