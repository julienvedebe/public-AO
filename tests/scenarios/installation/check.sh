# Installation depuis un dépôt local, sur Mac avec Claude Code.
source "$ROOT/tests/lib.sh"

fichier_existe "$S/marches-publics/SKILL.md"
diff -rq "$ROOT/skill/marches-publics" "$S/marches-publics" >/dev/null || _ko "le skill installé diffère de la source"

dossier_existe "$D/mes-justificatifs"
dossier_existe "$D/consultations"
fichier_existe "$D/suivi.md"

sortie_contient 'bonjour march[ée]s publics' "la phrase de test à taper"
sortie_contient 'nouvelle conversation' "l'invitation à ouvrir une nouvelle conversation"
vouvoie
fin
