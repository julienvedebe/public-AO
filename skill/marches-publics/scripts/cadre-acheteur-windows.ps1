# Remplit le cadre de memoire fourni par l'acheteur (le "cadre de reponse technique" du DCE) sous Windows,
# sans Word ni rien a installer : le .docx est une archive ZIP de fichiers XML, lue et recomposee avec l'API .NET
# de compression (System.IO.Compression). Word n'est jamais ouvert : son pilotage par COM peut se bloquer.
#
# Usage (Windows PowerShell 5.1 ou PowerShell 7) :
#   powershell -NoProfile -ExecutionPolicy Bypass -File cadre-acheteur-windows.ps1 lister  <cadre.docx>
#       affiche chaque paragraphe du cadre, numerote : "<pied-de-mouche><n> [tableau t, ligne l, cellule c] {style} | texte".
#       Ces numeros servent d'ancres dans le fichier de reponses.
#   powershell -NoProfile -ExecutionPolicy Bypass -File cadre-acheteur-windows.ps1 remplir <cadre.docx> <reponses.txt> <sortie.docx>
#       ecrit une COPIE du cadre, avec chaque reponse inseree a la suite du paragraphe indique. Le texte et la mise
#       en page de l'acheteur ne sont pas modifies : seule la partie word/document.xml recoit de nouveaux paragraphes.
#
# Fichier de reponses (UTF-8) : voir cadre-acheteur-mac.sh, le format est le meme.
#   ### <n> | <debut du texte du paragraphe n ; rien pour un paragraphe vide>
#   @max <nombre>    (facultatif) caracteres maximum
#   une ligne = un paragraphe ; "- " en tete = ligne de liste ; [A COMPLETER : ...] surligne en jaune.
#
# Ce fichier ne contient volontairement que des caracteres ASCII : Windows PowerShell 5.1 lit un script sans BOM
# en cp1252. Les caracteres accentues sont construits avec [char]0x....
#
# Codes de sortie (les memes que cadre-acheteur-mac.sh) :
#   0  cadre rempli et controle (derniere ligne : "CADRE <chemin> <blocs> <surlignes>")
#   2  arguments manquants ou fichier introuvable
#   3  fichier illisible ou dossier de sortie absent : rien n'est produit
#   4  le fichier de sortie existe deja : rien n'est ecrase
#   5  format non pris en charge (.doc, .odt, .rtf, .xlsx, .pdf...) : rien n'est produit
#   6  le fichier de reponses ne correspond pas au cadre : rien n'est produit
#   7  le remplissage n'a pas passe les controles : rien n'est produit
# Ligne d'avertissement possible avant la derniere : "PROTEGE" (document protege contre la modification dans Word).
#
# Compatibilite 5.1 : pas de ??, ?., ternaire, && ou || entre commandes ; aucun fichier ecrit avec Set-Content
# ou Out-File ; le XML est ecrit en octets UTF-8 sans BOM.

param(
  [string]$Mode,
  [string]$Cadre,
  [string]$Reponses,
  [string]$Sortie
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false } catch { }

# Sortie ecrite directement en UTF-8 sur la sortie standard, sans dependre de la page de code de la console :
# les ancres affichees par "lister" (apostrophes typographiques, pied-de-mouche) doivent arriver intactes a l'agent.
$Sortie8 = New-Object System.IO.StreamWriter([Console]::OpenStandardOutput(), (New-Object System.Text.UTF8Encoding $false))
$Sortie8.AutoFlush = $true
function Say([string]$texte) { $Sortie8.WriteLine($texte) }

$Utf8SansBom = New-Object System.Text.UTF8Encoding $false
$Utf8Strict = New-Object System.Text.UTF8Encoding $false, $true
$Marqueur = '[' + [string][char]0x00C0 + ' COMPL' + [string][char]0x00C9 + 'TER'
$MotifMarqueur = '\[' + [string][char]0x00C0 + ' COMPL' + [string][char]0x00C9 + 'TER[^\]]*\]?'
$PiedDeMouche = [string][char]0x00B6
$Tiret = [string][char]0x2013

function Resoudre-Chemin([string]$p) {
  return $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($p)
}

function Compter([string]$texte, [string]$quoi) {
  return [regex]::Matches($texte, [regex]::Escape($quoi)).Count
}

function Norm([string]$t) {
  $t = [regex]::Replace($t, '[\s\u00A0\u202F]+', ' ')
  return $t.Trim(' ')
}

# Cle de comparaison du texte d'ancrage : sans casse, apostrophes et tirets typographiques ramenes au clavier.
function Cle([string]$t) {
  $t = (Norm $t).ToLowerInvariant()
  $t = $t.Replace([string][char]0x2019, "'").Replace([string][char]0x2018, "'")
  $t = $t.Replace([string][char]0x2013, '-').Replace([string][char]0x2014, '-')
  $t = $t.Replace([string][char]0x00AB, '"').Replace([string][char]0x00BB, '"')
  $t = $t.Replace('" ', '"').Replace(' "', '"')
  return $t
}

function Decoder-Entites([string]$t) {
  $t = [regex]::Replace($t, '&#x([0-9a-fA-F]+);', { param($m) [char]::ConvertFromUtf32([Convert]::ToInt32($m.Groups[1].Value, 16)) })
  $t = [regex]::Replace($t, '&#([0-9]+);', { param($m) [char]::ConvertFromUtf32([int]$m.Groups[1].Value) })
  $t = $t.Replace('&lt;', '<').Replace('&gt;', '>').Replace('&quot;', '"').Replace('&apos;', "'").Replace('&amp;', '&')
  return $t
}

# ---------------------------------------------------------------- lecture des paragraphes du corps
# Renvoie une liste de @{ deb; fin; texte; style; lieu }, dans l'ordre d'ouverture des paragraphes.
$ReBalise = New-Object System.Text.RegularExpressions.Regex('(<[?!][^>]*>)|<(/?)([A-Za-z0-9_:.-]+)((?:[^>"'']|"[^"]*"|''[^'']*'')*?)(/?)>|([^<]+)', [System.Text.RegularExpressions.RegexOptions]::Singleline)

function Lire-Paragraphes([string]$x) {
  $p = New-Object System.Collections.ArrayList
  $pile = New-Object System.Collections.ArrayList
  $tbl = New-Object System.Collections.ArrayList
  $dansT = $false
  $nTbl = 0
  foreach ($m in $ReBalise.Matches($x)) {
    if ($m.Groups[1].Success) { continue }
    if ($m.Groups[6].Success) {
      if ($dansT -and $pile.Count -gt 0) { [void]$p[$pile[$pile.Count - 1]].texte.Append((Decoder-Entites $m.Groups[6].Value)) }
      continue
    }
    $ferme = ($m.Groups[2].Value -eq '/')
    $nom = $m.Groups[3].Value
    $attrs = $m.Groups[4].Value
    $auto = ($m.Groups[5].Value -eq '/')
    if ($nom -eq 'w:p') {
      if ($ferme) {
        if ($pile.Count -gt 0) {
          $i = $pile[$pile.Count - 1]
          $pile.RemoveAt($pile.Count - 1)
          $p[$i].fin = $m.Index + $m.Length
        }
      } else {
        $lieu = ''
        if ($tbl.Count -gt 0) {
          $t = $tbl[$tbl.Count - 1]
          $lieu = 'tableau ' + $t.n + ', ligne ' + $t.l + ', cellule ' + $t.c
        }
        $fin = -1
        if ($auto) { $fin = $m.Index + $m.Length }
        $i = $p.Add(@{ deb = $m.Index; fin = $fin; texte = (New-Object System.Text.StringBuilder); style = ''; lieu = $lieu })
        if (-not $auto) { [void]$pile.Add($i) }
      }
    }
    elseif ($nom -eq 'w:t') { $dansT = -not ($ferme -or $auto) }
    elseif (($nom -eq 'w:tab' -and $attrs -notmatch 'w:val') -or $nom -eq 'w:br' -or $nom -eq 'w:cr') {
      if ($pile.Count -gt 0 -and -not $ferme) { [void]$p[$pile[$pile.Count - 1]].texte.Append(' ') }
    }
    elseif ($nom -eq 'w:pStyle' -and $pile.Count -gt 0) {
      $s = [regex]::Match($attrs, 'w:val="([^"]*)"')
      $q = $p[$pile[$pile.Count - 1]]
      if ($s.Success -and $q.style.Length -eq 0) { $q.style = $s.Groups[1].Value }
    }
    elseif ($nom -eq 'w:tbl' -and -not $auto) {
      if ($ferme) { if ($tbl.Count -gt 0) { $tbl.RemoveAt($tbl.Count - 1) } }
      else { $nTbl = $nTbl + 1; [void]$tbl.Add(@{ n = $nTbl; l = 0; c = 0 }) }
    }
    elseif ($nom -eq 'w:tr' -and -not $ferme -and $tbl.Count -gt 0) { $t = $tbl[$tbl.Count - 1]; $t.l = $t.l + 1; $t.c = 0 }
    elseif ($nom -eq 'w:tc' -and -not $ferme -and $tbl.Count -gt 0) { $t = $tbl[$tbl.Count - 1]; $t.c = $t.c + 1 }
  }
  foreach ($q in $p) {
    if ($q.fin -lt 0) { throw 'paragraphe non ferme' }
    $q.texte = Norm ($q.texte.ToString())
  }
  return , $p
}

# ---------------------------------------------------------------- XML des reponses

function Xml-Echappe([string]$t) {
  $t = [regex]::Replace($t, '[^\x09\x0A\x0D\x20-\uD7FF\uE000-\uFFFD\uD800-\uDFFF]', '')
  return $t.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;')
}

function Run-Xml([string]$t, [bool]$hl) {
  $rpr = ''
  if ($hl) { $rpr = '<w:rPr><w:b/><w:bCs/><w:color w:val="C00000"/><w:highlight w:val="yellow"/></w:rPr>' }
  return '<w:r>' + $rpr + '<w:t xml:space="preserve">' + (Xml-Echappe $t) + '</w:t></w:r>'
}

function Para-Xml([string]$ligne) {
  $ppr = ''
  $runs = ''
  $m = [regex]::Match($ligne, '^-\s+')
  if ($m.Success) {
    $ligne = $ligne.Substring($m.Length)
    $ppr = '<w:pPr><w:ind w:left="567" w:hanging="283"/></w:pPr>'
    $runs = Run-Xml ($Tiret + ' ') $false
  }
  $morceaux = [regex]::Split($ligne, '(' + $MotifMarqueur + ')')
  for ($k = 0; $k -lt $morceaux.Length; $k++) {
    if ($morceaux[$k].Length -gt 0) { $runs = $runs + (Run-Xml $morceaux[$k] (($k % 2) -eq 1)) }
  }
  return '<w:p>' + $ppr + $runs + '</w:p>'
}

# ---------------------------------------------------------------- archive

function Octets-Entree($entree) {
  $ms = New-Object System.IO.MemoryStream
  $flux = $entree.Open()
  try { $flux.CopyTo($ms) } finally { $flux.Dispose() }
  return , $ms.ToArray()
}

# Lit toutes les parties d'un .docx : table nom -> octets, et liste des noms dans l'ordre.
function Lire-Parties([string]$chemin) {
  $zip = [System.IO.Compression.ZipFile]::OpenRead($chemin)
  try {
    $parties = @{}
    $noms = New-Object System.Collections.ArrayList
    foreach ($e in $zip.Entries) {
      [void]$noms.Add($e.FullName)
      $parties[$e.FullName] = Octets-Entree $e
    }
    return @{ parties = $parties; noms = $noms }
  } finally { $zip.Dispose() }
}

function Octets-Egaux($a, $b) {
  return [System.Collections.StructuralComparisons]::StructuralEqualityComparer.Equals($a, $b)
}

# ---------------------------------------------------------------- programme principal

$code = 3
$tmp = $null
try {
  $usage = 'Usage : cadre-acheteur-windows.ps1 lister <cadre.docx> | remplir <cadre.docx> <reponses.txt> <sortie.docx>'
  if ($Mode -eq 'lister') {
    if ([string]::IsNullOrEmpty($Cadre)) { Say $usage; exit 2 }
  } elseif ($Mode -eq 'remplir') {
    if ([string]::IsNullOrEmpty($Cadre) -or [string]::IsNullOrEmpty($Reponses) -or [string]::IsNullOrEmpty($Sortie)) { Say $usage; exit 2 }
  } else { Say $usage; exit 2 }

  $Cadre = Resoudre-Chemin $Cadre
  if (-not (Test-Path -LiteralPath $Cadre -PathType Leaf)) { Say "Cadre introuvable : $Cadre"; exit 2 }
  if ($Mode -eq 'remplir') {
    $Reponses = Resoudre-Chemin $Reponses
    $Sortie = Resoudre-Chemin $Sortie
    if (-not (Test-Path -LiteralPath $Reponses -PathType Leaf)) { Say "Fichier de reponses introuvable : $Reponses"; exit 2 }
    if ($Sortie -notmatch '(?i)\.docx$') { Say "La sortie doit etre un .docx : $Sortie"; exit 2 }
    if (Test-Path -LiteralPath $Sortie) { Say "Le fichier de sortie existe deja : rien n'est ecrase."; exit 4 }
    $dossierSortie = Split-Path -Parent $Sortie
    if (-not (Test-Path -LiteralPath $dossierSortie -PathType Container)) { Say "Le dossier de sortie n'existe pas : $dossierSortie"; exit 3 }
  }
  $ext = [System.IO.Path]::GetExtension($Cadre).ToLowerInvariant()
  if ($ext -ne '.docx') {
    Say ("Format non pris en charge pour le remplissage : " + $ext + " (seul .docx l'est sous Windows, sans Word).")
    exit 5
  }

  Add-Type -AssemblyName System.IO.Compression
  Add-Type -AssemblyName System.IO.Compression.FileSystem

  # Lecture du cadre.
  try {
    $orig = Lire-Parties $Cadre
    if (-not $orig.parties.ContainsKey('word/document.xml')) { throw 'word/document.xml absent' }
    $x = $Utf8Strict.GetString($orig.parties['word/document.xml']).TrimStart([char]0xFEFF)
    $xd = New-Object System.Xml.XmlDocument
    $xd.LoadXml($x)
    $p = Lire-Paragraphes $x
  } catch {
    Say ("Le cadre n'est pas un .docx lisible : " + $_.Exception.Message)
    exit 3
  }
  if ($orig.parties.ContainsKey('word/settings.xml')) {
    $reglages = $Utf8SansBom.GetString($orig.parties['word/settings.xml'])
    if ($reglages -match '<w:documentProtection[^>]*w:enforcement="(1|true|on)"') { Say 'PROTEGE' }
  }

  if ($Mode -eq 'lister') {
    for ($i = 0; $i -lt $p.Count; $i++) {
      $q = $p[$i]
      $ligne = $PiedDeMouche + ($i + 1)
      if ($q.lieu.Length -gt 0) { $ligne = $ligne + ' [' + $q.lieu + ']' }
      if ($q.style.Length -gt 0) { $ligne = $ligne + ' {' + $q.style + '}' }
      $t = $q.texte
      if ($t.Length -eq 0) { $t = '(vide)' }
      Say ($ligne + ' | ' + $t)
    }
    Say ('PARAGRAPHES ' + $p.Count)
    exit 0
  }

  # Lecture du fichier de reponses.
  $texteRep = [System.IO.File]::ReadAllText($Reponses, $Utf8SansBom)
  $texteRep = $texteRep.TrimStart([char]0xFEFF).Replace("`r", '')
  $blocs = New-Object System.Collections.ArrayList
  $b = $null
  $nl = 0
  foreach ($l in $texteRep.Split("`n")) {
    $nl = $nl + 1
    $m = [regex]::Match($l, '^###\s*(\d+)\s*(?:\|\s*(.*))?$')
    if ($m.Success) {
      $b = @{ n = [long]$m.Groups[1].Value; ancre = (Norm $m.Groups[2].Value); max = -1; lignes = (New-Object System.Collections.ArrayList); nl = $nl }
      [void]$blocs.Add($b)
      continue
    }
    if ($null -eq $b) {
      if ($l.Trim().Length -eq 0) { continue }
      Say "Ligne $nl : texte avant le premier ### du fichier de reponses."
      exit 6
    }
    $m = [regex]::Match($l, '^@max\s+(\d+)\s*$')
    if ($m.Success -and $b.lignes.Count -eq 0) { $b.max = [long]$m.Groups[1].Value; continue }
    if ($l.Trim().Length -eq 0) { continue }
    [void]$b.lignes.Add((Norm $l))
  }
  if ($blocs.Count -eq 0) { Say 'Le fichier de reponses ne contient aucun bloc ###.'; exit 6 }

  $erreurs = 0
  $vus = @{}
  foreach ($b in $blocs) {
    $n = $b.n
    $msg = $null
    if ($vus.ContainsKey($n)) { $msg = "le paragraphe $n est rempli deux fois" }
    elseif ($n -lt 1 -or $n -gt $p.Count) { $msg = "le paragraphe $n n'existe pas (le cadre en a " + $p.Count + ")" }
    elseif ($b.lignes.Count -eq 0) { $msg = "aucune reponse sous ### $n" }
    else {
      $t = $p[$n - 1].texte
      $debut = $t
      if ($debut.Length -gt 60) { $debut = $debut.Substring(0, 60) }
      if ($b.ancre.Length -eq 0) {
        if ($t.Length -gt 0) { $msg = "le paragraphe $n n'est pas vide : '" + $debut + "'" }
      } elseif (-not (Cle $t).StartsWith((Cle $b.ancre), [System.StringComparison]::Ordinal)) {
        $msg = "le paragraphe $n commence par '" + $debut + "', pas par '" + $b.ancre + "'"
      }
      if ($null -eq $msg -and $b.max -ge 0) {
        $long = $b.lignes.Count - 1
        foreach ($l in $b.lignes) { $long = $long + $l.Length }
        if ($long -gt $b.max) { $msg = "la reponse au paragraphe $n fait $long caracteres pour " + $b.max + " au maximum" }
      }
    }
    $vus[$n] = $true
    if ($null -ne $msg) { Say ("Bloc de la ligne " + $b.nl + " : " + $msg + "."); $erreurs = $erreurs + 1 }
  }
  if ($erreurs -gt 0) { exit 6 }

  # Insertion, de la fin vers le debut pour garder les positions.
  $code = 7
  $nouveau = $x
  $marqRep = 0
  $nbPar = 0
  foreach ($b in ($blocs | Sort-Object -Property @{ Expression = { $_.n } } -Descending)) {
    $q = $p[$b.n - 1]
    $sb = New-Object System.Text.StringBuilder
    foreach ($l in $b.lignes) { [void]$sb.Append((Para-Xml $l)); $marqRep = $marqRep + (Compter $l $Marqueur) }
    $nbPar = $nbPar + $b.lignes.Count
    $pos = $q.deb
    if ($q.texte.Length -gt 0) { $pos = $q.fin }
    $nouveau = $nouveau.Insert($pos, $sb.ToString())
  }

  # Controles sur le XML produit : lisible, texte de l'acheteur intact et dans l'ordre, marqueurs surlignes.
  $xd = New-Object System.Xml.XmlDocument
  $xd.LoadXml($nouveau)
  $pn = Lire-Paragraphes $nouveau
  if ($pn.Count -ne ($p.Count + $nbPar)) { Say ("Controle : " + $pn.Count + " paragraphes au lieu de " + ($p.Count + $nbPar) + "."); exit 7 }
  $j = 0
  foreach ($q in $pn) { if ($j -lt $p.Count -and $q.texte -ceq $p[$j].texte) { $j = $j + 1 } }
  if ($j -ne $p.Count) { Say ("Controle : le texte de l'acheteur n'est plus intact (paragraphe " + ($j + 1) + ")."); exit 7 }
  $marqOrig = Compter $x $Marqueur
  $marqTot = Compter $nouveau $Marqueur
  if ($marqTot -ne ($marqOrig + $marqRep)) { Say ("Controle : $marqTot [A COMPLETER] au lieu de " + ($marqOrig + $marqRep) + "."); exit 7 }
  $surl = 0
  foreach ($r in [regex]::Matches($nouveau, '(?s)<w:r>(.*?)</w:r>')) {
    $v = $r.Groups[1].Value
    if ($v.Contains($Marqueur) -and $v.Contains('<w:highlight w:val="yellow"/>')) { $surl = $surl + 1 }
  }
  if ($surl -lt $marqRep) { Say "Controle : $surl [A COMPLETER] surlignes sur $marqRep."; exit 7 }

  # Copie du cadre dans un fichier temporaire, ou seule word/document.xml est remplacee.
  $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('cadre-' + [guid]::NewGuid().ToString('N') + '.docx')
  [System.IO.File]::Copy($Cadre, $tmp, $false)
  # La copie garde l'attribut lecture seule du cadre (piece jointe ouverte depuis la messagerie, par exemple) :
  # on le retire de la copie de travail, sinon l'archive ne s'ouvre pas en ecriture et la sortie serait en lecture seule.
  [System.IO.File]::SetAttributes($tmp, [System.IO.FileAttributes]::Normal)
  $zip = [System.IO.Compression.ZipFile]::Open($tmp, [System.IO.Compression.ZipArchiveMode]::Update)
  try {
    $zip.GetEntry('word/document.xml').Delete()
    $entree = $zip.CreateEntry('word/document.xml', [System.IO.Compression.CompressionLevel]::Optimal)
    $flux = $entree.Open()
    try {
      $octets = $Utf8SansBom.GetBytes($nouveau)
      $flux.Write($octets, 0, $octets.Length)
    } finally { $flux.Dispose() }
  } finally { $zip.Dispose() }

  # Relecture : memes parties, toutes identiques sauf word/document.xml, qui est celui produit.
  $fin = Lire-Parties $tmp
  if ($fin.noms[0] -ne $orig.noms[0]) { Say "Controle : la premiere partie de l'archive a change."; exit 7 }
  if ($fin.noms.Count -ne $orig.noms.Count) { Say "Controle : nombre de parties change."; exit 7 }
  foreach ($nom in $orig.noms) {
    if (-not $fin.parties.ContainsKey($nom)) { Say "Controle : partie absente : $nom"; exit 7 }
    if ($nom -eq 'word/document.xml') { continue }
    if (-not (Octets-Egaux $orig.parties[$nom] $fin.parties[$nom])) { Say "Controle : la partie $nom a change."; exit 7 }
  }
  if ($Utf8Strict.GetString($fin.parties['word/document.xml']) -cne $nouveau) { Say "Controle : word/document.xml n'est pas celui produit."; exit 7 }

  # Copie finale : sans ecrasement (leve une erreur si le fichier existe).
  if (Test-Path -LiteralPath $Sortie) { Say "Le fichier de sortie existe deja : rien n'est ecrase."; exit 4 }
  [System.IO.File]::Copy($tmp, $Sortie, $false)
  Say ('BLOCS ' + $blocs.Count + ' SURLIGNES ' + $marqRep)
  Say ('CADRE ' + $Sortie + ' ' + $blocs.Count + ' ' + $marqRep)
  exit 0
} catch {
  Say ("Erreur inattendue : " + $_.Exception.Message)
  exit $code
} finally {
  if ($null -ne $tmp -and (Test-Path -LiteralPath $tmp)) { Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue }
}
