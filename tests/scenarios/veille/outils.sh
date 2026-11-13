# Fonctions communes aux scénarios « veille » (chargées par leur check.sh, après tests/lib.sh).
# Elles relisent le suivi, puis interrogent l'API du BOAMP en direct, par identifiant d'avis.

BOAMP_API="https://boamp-datadila.opendatasoft.com/api/explore/v2.1/catalog/datasets/boamp/records"

# Identifiants d'avis (idweb) présents dans le suivi, un par ligne.
ids_du_suivi() { grep -oE 'idweb:[0-9]+-[0-9]+' "$D/suivi.md" 2>/dev/null | sed 's/^idweb://'; }

# Date J+10 au format AAAA-MM-JJ (macOS, puis Linux).
date_j10() { date -v+10d +%F 2>/dev/null || date -d '+10 days' +%F; }

# Le suivi garde les deux consultations de départ, intactes.
suivi_garde_le_depart() {
  fichier_contient "$D/suivi.md" 'Rénovation sanitaires école.*Mairie de Villeurbanne.*2026-12-15.*analysée' "la ligne « Rénovation sanitaires école » d'origine"
  fichier_contient "$D/suivi.md" 'Chaufferie gymnase.*Mairie de Bron.*2026-12-20.*repérée' "la ligne « Chaufferie gymnase » d'origine"
}

# Au plus 10 consultations nouvelles, chacune au statut « repérée », sans doublon.
suivi_sans_doublon() {  # $1 = nombre maximal de consultations nouvelles
  local n dup ligne
  n=$(ids_du_suivi | wc -l | tr -d ' ')
  [ "$n" -ge 1 ] || _ko "le suivi ne contient aucune consultation repérée avec son lien"
  [ "$n" -le "$1" ] || _ko "$n consultations ajoutées au suivi (au plus $1 attendues)"
  dup=$(ids_du_suivi | sort | uniq -d | tr '\n' ' ')
  [ -z "$dup" ] || _ko "consultations en double dans le suivi : $dup"
  while IFS= read -r ligne; do
    grep -qi 'repérée' <<< "$ligne" || _ko "ligne ajoutée sans le statut « repérée » : ${ligne:0:80}"
  done < <(grep -E '^\|.*idweb:[0-9]+-[0-9]+' "$D/suivi.md")
}

# Contrôle chaque consultation du suivi dans l'API : travaux, appel à la concurrence,
# dans la zone (regex sur les numéros de département de l'API), date limite >= J+10.
# Si l'API ne répond pas au moment du contrôle, on le signale sans échouer.
verifie_dans_api() {  # $1 = regex des départements de l'API, ex. '69|1'
  local id rep limite j10
  j10=$(date_j10)
  for id in $(ids_du_suivi | sort -u); do
    rep=$(curl -s --compressed -m 40 -G "$BOAMP_API" \
      --data-urlencode "select=idweb,type_marche,nature_categorise,code_departement,datelimitereponse" \
      --data-urlencode "where=idweb='$id'")
    if ! grep -q '"total_count"' <<< "$rep"; then
      echo "    (contrôle de $id ignoré : l'API ne répond pas)"; continue
    fi
    grep -q "\"idweb\": \"$id\"" <<< "$rep" || { _ko "avis $id introuvable dans l'API"; continue; }
    grep -q '"type_marche": \[[^]]*"TRAVAUX"' <<< "$rep" || _ko "avis $id : pas un marché de travaux"
    grep -q '"nature_categorise": "appeloffre/' <<< "$rep" || _ko "avis $id : pas un appel à la concurrence"
    grep -qE "\"code_departement\": \[[^]]*\"($1)\"" <<< "$rep" || _ko "avis $id : hors de la zone"
    limite=$(grep -oE '"datelimitereponse": "[0-9]{4}-[0-9]{2}-[0-9]{2}' <<< "$rep" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
    if [ -z "$limite" ]; then _ko "avis $id : pas de date limite"
    elif [[ "$limite" < "$j10" ]]; then _ko "avis $id : date limite $limite avant $j10 (J+10)"; fi
  done
}

# Toutes les consultations ajoutées au suivi ont été présentées à l'artisan (lien dans la réponse),
# et la réponse n'en présente pas plus de 10.
reponse_presente_le_suivi() {
  local id n
  for id in $(ids_du_suivi | sort -u); do
    grep -q "idweb:$id" "$SORTIE" || _ko "l'avis $id est dans le suivi mais pas dans la réponse"
  done
  n=$(grep -oE 'idweb:[0-9]+-[0-9]+' "$SORTIE" | sort -u | wc -l | tr -d ' ')
  [ "$n" -le 10 ] || _ko "la réponse présente $n consultations (au plus 10 attendues)"
}
