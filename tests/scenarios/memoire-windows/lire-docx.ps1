# Aide du scenario "memoire-windows" : relit un .docx ou un .rtf sous Windows, la ou le scenario
# "memoire" utilise textutil, unzip et xmllint (absents de Windows). Appelee par outils-windows.sh.
# Fichier volontairement en ASCII (Windows PowerShell 5.1 lit un script sans BOM en cp1252).
#
# Usage : powershell -NoProfile -ExecutionPolicy Bypass -File lire-docx.ps1 <mode> <fichier> [dossier]
#   texte    <fichier.docx|.rtf>   affiche le texte, un paragraphe par ligne (UTF-8)
#   valide   <fichier.docx>        affiche une ligne "KO ..." par probleme ; rien si tout va bien
#   surligne <fichier.docx>        affiche "TOTAL <n> SANS <m>" (passages [A COMPLETER] et ceux sans surlignage jaune)
#   extraire <fichier.docx> <dir>  ecrit chaque partie du .docx telle quelle (octets) dans <dir>

param(
  [string]$Mode,
  [string]$Fichier,
  [string]$Dossier
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false } catch { }
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$Fichier = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Fichier)
$Marqueur = '[' + [string][char]0x00C0 + ' COMPL' + [string][char]0x00C9 + 'TER'

function Octets-Entree($entree) {
  $ms = New-Object System.IO.MemoryStream
  $flux = $entree.Open()
  try { $flux.CopyTo($ms) } finally { $flux.Dispose() }
  return , $ms.ToArray()
}

function Texte-Docx([string]$chemin) {
  $zip = [System.IO.Compression.ZipFile]::OpenRead($chemin)
  try {
    $entree = $zip.GetEntry('word/document.xml')
    $octets = Octets-Entree $entree
    $xml = New-Object System.Xml.XmlDocument
    $xml.LoadXml((New-Object System.Text.UTF8Encoding $false).GetString($octets))
  } finally { $zip.Dispose() }
  $ns = New-Object System.Xml.XmlNamespaceManager $xml.NameTable
  $ns.AddNamespace('w', 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')
  $lignes = New-Object System.Collections.ArrayList
  foreach ($p in $xml.SelectNodes('//w:p', $ns)) {
    $sb = New-Object System.Text.StringBuilder
    foreach ($n in $p.SelectNodes('.//w:t | .//w:br', $ns)) {
      if ($n.LocalName -eq 'br') { [void]$sb.Append(' ') } else { [void]$sb.Append($n.InnerText) }
    }
    [void]$lignes.Add($sb.ToString())
  }
  return [string]::Join("`n", $lignes.ToArray())
}

function Texte-Rtf([string]$chemin) {
  $r = [System.IO.File]::ReadAllText($chemin, [System.Text.Encoding]::ASCII)
  $r = [regex]::Replace($r, '\{\\fonttbl.*?\}\}', '')
  $r = [regex]::Replace($r, '\{\\colortbl[^}]*\}', '')
  $sb = New-Object System.Text.StringBuilder
  $i = 0
  while ($i -lt $r.Length) {
    $c = $r[$i]
    if ($c -eq '\') {
      $i++
      if ($i -ge $r.Length) { break }
      $d = $r[$i]
      if ($d -eq '\' -or $d -eq '{' -or $d -eq '}') { [void]$sb.Append($d); $i++ }
      elseif ($d -eq "'") {
        [void]$sb.Append([char][Convert]::ToInt32($r.Substring($i + 1, 2), 16))
        $i += 3
      }
      else {
        $m = [regex]::Match($r.Substring($i), '^([a-zA-Z]+)(-?[0-9]+)? ?')
        if (-not $m.Success) { $i++; continue }
        $mot = $m.Groups[1].Value
        $i += $m.Length
        if ($mot -eq 'par' -or $mot -eq 'line' -or $mot -eq 'cell' -or $mot -eq 'row') { [void]$sb.Append("`n") }
        elseif ($mot -eq 'tab') { [void]$sb.Append(' ') }
        elseif ($mot -eq 'u') {
          $n = [int]$m.Groups[2].Value
          if ($n -lt 0) { $n += 65536 }
          [void]$sb.Append([char]$n)
          $i++   # le caractere de remplacement (?) qui suit
        }
      }
    }
    elseif ($c -eq '{' -or $c -eq '}') { $i++ }
    elseif ($c -eq "`r" -or $c -eq "`n") { $i++ }
    else { [void]$sb.Append($c); $i++ }
  }
  return $sb.ToString()
}

if ($Mode -eq 'texte') {
  if ($Fichier -match '(?i)\.rtf$') { [Console]::Out.Write((Texte-Rtf $Fichier)) } else { [Console]::Out.Write((Texte-Docx $Fichier)) }
}
elseif ($Mode -eq 'valide') {
  try {
    $zip = [System.IO.Compression.ZipFile]::OpenRead($Fichier)
  } catch {
    [Console]::Out.WriteLine('KO le .docx n est pas une archive valide : ' + $_.Exception.Message)
    exit 0
  }
  try {
    $noms = New-Object System.Collections.ArrayList
    foreach ($e in $zip.Entries) { [void]$noms.Add($e.FullName) }
    foreach ($requis in @('[Content_Types].xml', '_rels/.rels', 'word/document.xml', 'word/styles.xml')) {
      if ($noms -notcontains $requis) { [Console]::Out.WriteLine('KO partie absente du .docx : ' + $requis) }
    }
    foreach ($e in $zip.Entries) {
      if ($e.FullName.Contains('\')) { [Console]::Out.WriteLine('KO chemin avec antislash : ' + $e.FullName) }
      if ($e.FullName -match '\.(xml|rels)$') {
        $octets = Octets-Entree $e
        if ($octets.Length -ge 3 -and $octets[0] -eq 0xEF -and $octets[1] -eq 0xBB -and $octets[2] -eq 0xBF) { [Console]::Out.WriteLine('KO BOM dans ' + $e.FullName) }
        try {
          $xd = New-Object System.Xml.XmlDocument
          $xd.LoadXml((New-Object System.Text.UTF8Encoding $false).GetString($octets))
        } catch { [Console]::Out.WriteLine('KO XML illisible : ' + $e.FullName) }
      }
    }
  } finally { $zip.Dispose() }
  try {
    $t = Texte-Docx $Fichier
    if ($t.Trim().Length -eq 0) { [Console]::Out.WriteLine('KO aucun texte dans le .docx') }
  } catch { [Console]::Out.WriteLine('KO texte illisible : ' + $_.Exception.Message) }
}
elseif ($Mode -eq 'surligne') {
  $zip = [System.IO.Compression.ZipFile]::OpenRead($Fichier)
  try {
    $octets = Octets-Entree ($zip.GetEntry('word/document.xml'))
    $doc = (New-Object System.Text.UTF8Encoding $false).GetString($octets)
  } finally { $zip.Dispose() }
  $total = [regex]::Matches($doc, [regex]::Escape($Marqueur)).Count
  $sans = 0
  foreach ($r in [regex]::Matches($doc, '(?s)<w:r>(.*?)</w:r>')) {
    $v = $r.Groups[1].Value
    if ($v.Contains($Marqueur) -and -not $v.Contains('<w:highlight w:val="yellow"/>')) { $sans++ }
  }
  [Console]::Out.WriteLine("TOTAL $total SANS $sans")
}
elseif ($Mode -eq 'extraire') {
  $zip = [System.IO.Compression.ZipFile]::OpenRead($Fichier)
  try {
    foreach ($e in $zip.Entries) {
      if ($e.FullName.EndsWith('/')) { continue }
      $cible = Join-Path $Dossier ($e.FullName.Replace('/', '\'))
      [void][System.IO.Directory]::CreateDirectory((Split-Path -Parent $cible))
      [System.IO.File]::WriteAllBytes($cible, (Octets-Entree $e))
    }
  } finally { $zip.Dispose() }
}
else {
  [Console]::Out.WriteLine('KO mode inconnu : ' + $Mode)
  exit 2
}
