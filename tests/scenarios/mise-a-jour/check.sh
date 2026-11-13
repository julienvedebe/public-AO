# Mise à jour : l'ancien skill est remplacé, le dossier de travail reste identique octet pour octet.
source "$ROOT/tests/lib.sh"

fichier_existe "$S/marches-publics/SKILL.md"
fichier_absent "$S/marches-publics/ancienne-version.txt"
diff -rq "$ROOT/skill/marches-publics" "$S/marches-publics" >/dev/null || _ko "le skill installé diffère de la source"

diff -r "$ROOT/tests/scenarios/mise-a-jour/dossier" "$D" >/dev/null || _ko "le dossier de travail a changé"

sortie_contient 'nouvelle conversation' "l'invitation à ouvrir une nouvelle conversation"
vouvoie
fin
