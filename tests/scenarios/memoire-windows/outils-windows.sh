# Outils du scénario « memoire-windows » (chargés par son check.sh, après tests/scenarios/memoire/outils.sh).
# Ils REDÉFINISSENT les fonctions de memoire/outils.sh qui s'appuient sur textutil, unzip et xmllint (absents
# de Windows) : la relecture du .docx ou du .rtf passe par PowerShell (lire-docx.ps1). Le reste de memoire/outils.sh
# (trame du RC, fiche reprise, absence d'invention, absence de prix, rtf_surligne) n'utilise que bash, grep, awk et perl,
# fournis avec Git Bash.
#
# Prérequis pour lancer ce scénario sous Windows, sans modifier tests/run.sh :
#   - Git Bash (Git for Windows) : bash, grep, awk, sed, perl, find, cmp, od, cygpath, powershell.exe dans le PATH ;
#     lancez « bash tests/run.sh memoire-windows » depuis Git Bash ;
#   - ou WSL : mêmes outils Linux, powershell.exe accessible par l'interopérabilité WSL, wslpath ; l'agent
#     (claude ou codex) doit alors tourner côté Windows pour que le skill y exécute PowerShell.
# Dans les deux cas, l'agent testé doit être l'agent Windows, installé et connecté.

SC_W="$ROOT/tests/scenarios/memoire-windows"
SCRIPT_PS1="$ROOT/skill/marches-publics/scripts/memoire-vers-docx-windows.ps1"
AIDE_PS1="$SC_W/lire-docx.ps1"

# La variable de test doit traverser WSL vers powershell.exe.
export WSLENV="${WSLENV:+$WSLENV:}MEMOIRE_FORCER_ECHEC_DOCX"

# Chemin lisible par PowerShell (Windows) à partir d'un chemin bash.
winpath() {
  if command -v cygpath >/dev/null 2>&1; then cygpath -w "$1"
  elif command -v wslpath >/dev/null 2>&1; then wslpath -w "$1"
  else printf '%s' "$1"; fi
}

PS_EXE=$(command -v powershell.exe || command -v powershell || command -v pwsh || true)

# aide <mode> <fichier> [dossier] : lance lire-docx.ps1 ; sortie sans retours chariot.
aide() {
  local mode="$1" f="$2" d="${3:-}"
  "$PS_EXE" -NoProfile -ExecutionPolicy Bypass -File "$(winpath "$AIDE_PS1")" "$mode" "$(winpath "$f")" ${d:+"$(winpath "$d")"} 2>&1 | tr -d '\r'
}

# lancer_script <html> <sortie.docx> : lance le script comme l'agent le fait (même commande) ; affiche sa sortie ;
# le code de sortie du script est dans $? (le pipe vers tr ne le masque pas : voir PIPESTATUS).
lancer_script() {
  "$PS_EXE" -NoProfile -ExecutionPolicy Bypass -File "$(winpath "$SCRIPT_PS1")" "$(winpath "$1")" "$(winpath "$2")" 2>&1 | tr -d '\r'
  return "${PIPESTATUS[0]}"
}

# --- Redéfinitions (remplacent celles de memoire/outils.sh) ---

texte_du_fichier() { aide texte "$1"; }

docx_valide() { # <fichier.docx>
  local p
  p=$(aide valide "$1")
  [ -z "$p" ] || _ko "$(head -1 <<< "$p")"
}

docx_surligne() { # <fichier.docx>
  local r total sans
  r=$(aide surligne "$1")
  total=$(sed -n 's/^TOTAL \([0-9]*\) SANS \([0-9]*\)$/\1/p' <<< "$r")
  sans=$(sed -n 's/^TOTAL \([0-9]*\) SANS \([0-9]*\)$/\2/p' <<< "$r")
  [ -n "$total" ] || { _ko "relecture du surlignage impossible : $r"; return; }
  [ "$total" -ge 1 ] || { _ko "aucun [À COMPLÉTER] dans le XML du .docx"; return; }
  [ "$sans" = 0 ] || _ko "$sans [À COMPLÉTER] sans surlignage jaune dans le .docx (sur $total)"
}

extraire_docx() { aide extraire "$1" "$2" >/dev/null; } # <fichier.docx> <dossier>

# lancer_cadre <lister|remplir> <fichier>... : lance cadre-acheteur-windows.ps1 comme l'agent le fait ; affiche sa sortie ;
# le code de sortie du script est dans $?.
SCRIPT_CADRE_PS1="$ROOT/skill/marches-publics/scripts/cadre-acheteur-windows.ps1"
lancer_cadre() {
  local mode="$1" f args=()
  shift
  for f in "$@"; do args+=("$(winpath "$f")"); done
  "$PS_EXE" -NoProfile -ExecutionPolicy Bypass -File "$(winpath "$SCRIPT_CADRE_PS1")" "$mode" "${args[@]}" 2>&1 | tr -d '\r'
  return "${PIPESTATUS[0]}"
}
