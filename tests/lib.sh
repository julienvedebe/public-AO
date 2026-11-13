# Assertions partagées par les check.sh des scénarios.
# Chaque check.sh fait : source "$ROOT/tests/lib.sh", ses assertions, puis `fin`.

# Sans locale UTF-8, le grep de macOS lit « [ée] » octet par octet et ne
# reconnaît pas « é ». On force donc une locale UTF-8 pour les assertions.
export LC_ALL=en_US.UTF-8

ECHECS=0

_ko() { echo "    ✗ $1"; ECHECS=$((ECHECS + 1)); }

fichier_existe()   { [ -f "$1" ] || _ko "fichier absent : $1"; }
fichier_absent()   { [ ! -e "$1" ] || _ko "fichier inattendu : $1"; }
dossier_existe()   { [ -d "$1" ] || _ko "dossier absent : $1"; }

# sortie_contient <regex étendue insensible à la casse> <description>
sortie_contient()     { grep -qiE "$1" "$SORTIE" || _ko "la réponse ne contient pas : $2"; }
sortie_ne_contient_pas() { ! grep -qiE "$1" "$SORTIE" || _ko "la réponse contient : $2"; }

# Vouvoiement : « vous » présent, aucun « tu » isolé.
vouvoie() {
  grep -qiwE 'vous|votre|vos' "$SORTIE" || _ko "pas de vouvoiement"
  ! grep -qiwE 'tu|toi' "$SORTIE" || _ko "tutoiement détecté"
}

fin() {
  if [ $ECHECS -gt 0 ]; then
    echo "    --- réponse de l'agent ---"
    sed 's/^/    | /' "$SORTIE" | head -60
    exit 1
  fi
  exit 0
}
