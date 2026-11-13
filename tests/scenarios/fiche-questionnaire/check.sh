# Questionnaire de la fiche entreprise, en trois tours, sur un dossier de travail vide.
source "$ROOT/tests/lib.sh"
F="$D/ma-fiche-entreprise.md"

# Premier tour : le questionnaire démarre par une seule question.
au_tour 1
une_seule_question
vouvoie

# La fiche existe et contient toutes les rubriques.
fichier_existe "$F"
for r in "Entreprise" "Métiers" "Zone d'intervention" "Lots qui m'intéressent" "Certifications" \
         "Effectif" "Chiffre d'affaires" "Assurances" "Références" "Justificatifs"; do
  grep -q "^## $r" "$F" 2>/dev/null || _ko "rubrique absente : $r"
done

# Les réponses sont enregistrées, métiers traduits en descripteurs et codes CPV.
fichier_contient "$F" 'Martin Plomberie' "le nom de l'entreprise"
fichier_contient "$F" '(^|[^0-9])270 ' "le descripteur Plomberie"
fichier_contient "$F" '(^|[^0-9])61 ' "le descripteur Chauffage"
fichier_contient "$F" '45330000-9' "le code CPV de la plomberie"
rubrique "$F" "Zone d'intervention" | grep -q '69' || _ko "département 69 absent"
rubrique "$F" "Zone d'intervention" | grep -q '01' || _ko "département 01 absent"
rubrique "$F" "Références" | grep -qi 'Décines' || _ko "référence de Décines absente"
rubrique "$F" "Justificatifs" | grep -qiE 'URSSAF.*31/03/2027' || _ko "date de fin de validité URSSAF absente"

# Rien d'inventé : le chiffre d'affaires reste à compléter.
rubrique "$F" "Chiffre d'affaires" | grep -q 'À COMPLÉTER' || _ko "chiffre d'affaires non marqué [À COMPLÉTER]"
rubrique "$F" "Chiffre d'affaires" | grep -qE '[0-9]{2,3}[  .]?000' && _ko "chiffre d'affaires inventé"

# Les codes ne sont pas montrés à l'artisan.
toute_la_conversation
sortie_ne_contient_pas '45330000|descripteur' "des codes techniques"
vouvoie
fin
