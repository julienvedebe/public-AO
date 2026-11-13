# Pièces à fournir et rétroplanning pour le lot plomberie de Val-de-Brelle (déjà analysé, date limite le 15/01/2027).
# La fiche : URSSAF périmée le 30/09/2026, attestation fiscale valable jusqu'au 31/12/2026, Kbis jusqu'au 15/01/2027.
source "$ROOT/tests/lib.sh"
SC="$ROOT/tests/scenarios/dossier"

# Les fichiers de l'artisan ne sont pas touchés.
diff -q "$SC/dossier/ma-fiche-entreprise.md" "$D/ma-fiche-entreprise.md" >/dev/null || _ko "la fiche a été modifiée"
diff -rq "$SC/dossier/mes-justificatifs" "$D/mes-justificatifs" >/dev/null || _ko "mes-justificatifs a été modifié"
C="$D/consultations/2027-01_commune-de-val-de-brelle_lot-05-plomberie"
diff -q "$SC/dossier/consultations/2027-01_commune-de-val-de-brelle_lot-05-plomberie/analyse.md" "$C/analyse.md" >/dev/null || _ko "l'analyse a été modifiée"
diff -rq "$SC/dossier/consultations/2027-01_commune-de-val-de-brelle_lot-05-plomberie/dce" "$C/dce" >/dev/null || _ko "le DCE a été modifié"
[ "$(ls -d "$D"/consultations/*/ | wc -l | tr -d ' ')" -eq 1 ] || _ko "un second sous-dossier de consultation a été créé"

# Fichier du dossier de réponse, dans le sous-dossier de la consultation.
P="$C/pieces-et-retroplanning.md"
fichier_existe "$P"
[ -f "$P" ] || fin

# Pièces présentes / manquantes : deux rubriques distinctes.
PRET=$(rubrique "$P" "Ce que vous avez déjà")
MANQUE=$(rubrique "$P" "Ce qui manque")
[ -n "$PRET" ] || _ko "rubrique « Ce que vous avez déjà » absente ou vide"
[ -n "$MANQUE" ] || _ko "rubrique « Ce qui manque » absente ou vide"
grep -qiE 'assurance|responsabilité|décennale' <<< "$PRET" || _ko "les assurances (valables) ne sont pas dans ce qui est déjà prêt"
# Qualibat est dans la fiche : « déjà prêt », ou « à renouveler » si l'agent réclame le certificat lui-même.
grep -qiE 'qualibat' <<< "$PRET$MANQUE" || _ko "Qualibat n'est ni dans ce qui est prêt ni dans ce qui reste à fournir"
grep -qiE 'URSSAF' <<< "$MANQUE" || _ko "l'attestation URSSAF n'est pas dans ce qui manque ou est à renouveler"
grep -qiE 'fiscale|fiscal' <<< "$MANQUE" || _ko "l'attestation fiscale n'est pas dans ce qui manque ou est à renouveler"
grep -qiE 'Qualigaz' <<< "$MANQUE" || _ko "Qualigaz n'est pas dans ce qui manque"
grep -qiE 'attestation de visite|visite' <<< "$MANQUE" || _ko "l'attestation de visite n'est pas dans ce qui manque ou reste à faire"
grep -qiE 'URSSAF' <<< "$PRET" && _ko "l'URSSAF périmée est présentée comme prête"
grep -qiE 'fiscal' <<< "$PRET" && _ko "l'attestation fiscale, qui expire avant la date limite, est présentée comme prête"
# Chaque pièce exigée du RC est sourcée.
fichier_contient "$P" 'RC.{0,30}(article|art\.?) ?(8|9|5|10)' "la source des pièces dans le RC"

# Alertes : URSSAF et attestation fiscale, avec les deux dates.
ALERTES=$(rubrique "$P" "Alertes")
[ -n "$ALERTES" ] || _ko "rubrique Alertes absente ou vide"
grep -qiE 'URSSAF' <<< "$ALERTES" || _ko "pas d'alerte sur l'URSSAF"
grep -qiE 'fiscal' <<< "$ALERTES" || _ko "pas d'alerte sur l'attestation fiscale"
grep -qE '(30 septembre 2026|30/09/2026)' <<< "$ALERTES" || _ko "la date d'expiration de l'URSSAF (30/09/2026) n'est pas citée"
grep -qE '(31 décembre 2026|31/12/2026)' <<< "$ALERTES" || _ko "la date d'expiration de l'attestation fiscale (31/12/2026) n'est pas citée"
grep -qE '(15 janvier 2027|15/01/2027)' <<< "$ALERTES" || _ko "la date limite n'est pas citée dans les alertes"
sortie_contient 'URSSAF' "l'alerte URSSAF dans la réponse"
sortie_contient 'fiscal' "l'alerte attestation fiscale dans la réponse"

# Rétroplanning : daté, à rebours, toutes les dates entre le 1er novembre 2026 et la date limite.
R=$(rubrique "$P" "Rétroplanning")
[ -n "$R" ] || { _ko "rubrique Rétroplanning absente ou vide"; fin; }
mois_num() { case "$1" in janvier) echo 01;; février) echo 02;; mars) echo 03;; avril) echo 04;; mai) echo 05;; juin) echo 06;; juillet) echo 07;; août) echo 08;; septembre) echo 09;; octobre) echo 10;; novembre) echo 11;; décembre) echo 12;; esac; }
DATES=$( {
  grep -oiE '[0-9]{1,2}(er)? (janvier|février|mars|avril|mai|juin|juillet|août|septembre|octobre|novembre|décembre) 20(26|27)' <<< "$R" | while read -r j m a; do printf '%s%s%02d\n' "$a" "$(mois_num "$m")" "${j%er}"; done
  grep -oE '[0-9]{2}/[0-9]{2}/20(26|27)' <<< "$R" | awk -F/ '{ print $3 $2 $1 }'
} | sort -u )
n=0
for d in $DATES; do
  n=$((n + 1))
  { [ "$d" -le 20270115 ] && [ "$d" -ge 20261101 ]; } || _ko "date du rétroplanning hors de la période (avant la date limite) : $d"
done
[ "$n" -ge 5 ] || _ko "moins de 5 dates distinctes dans le rétroplanning ($n)"
grep -q '^20270115$' <<< "$DATES" || _ko "la date limite du 15/01/2027 n'est pas dans le rétroplanning"
grep -q '^20261208$' <<< "$DATES" || _ko "la visite du 08/12/2026 n'est pas dans le rétroplanning"
grep -q '^20270104$' <<< "$DATES" || _ko "la date limite des questions du 04/01/2027 n'est pas dans le rétroplanning"
# Un dépôt avec une marge avant la date limite : une date de dépôt strictement avant le 15/01/2027.
grep -iE 'dépôt|déposer|dépos' <<< "$R" | grep -qE '(1[0-4] janvier 2027|0?[1-9] janvier 2027|[0-9]{2}/01/2027|décembre 2026)' || _ko "pas de date de dépôt avec une marge avant la date limite"
for e in 'mémoire' 'prix' 'signature|signer' 'visite' 'question' 'justificatif|attestation'; do
  grep -qiE "$e" <<< "$R" || _ko "étape absente du rétroplanning : $e"
done

# Formulaires : DC1 ou DUME (RC, article 8), champs de la fiche, [À COMPLÉTER] pour le reste.
F=$(rubrique "$P" "Formulaires")
[ -n "$F" ] || _ko "rubrique Formulaires absente ou vide"
grep -qE 'DC1' <<< "$F" || _ko "le DC1 n'est pas cité"
grep -qE 'DUME' <<< "$F" || _ko "le DUME n'est pas cité"
grep -qE '123 ?456 ?789 ?00012' <<< "$F" || _ko "le SIRET de la fiche n'est pas repris"
grep -qE '12 rue des Artisans' <<< "$F" || _ko "l'adresse de la fiche n'est pas reprise"
grep -qE 'Plomberie Exemple' <<< "$F" || _ko "le nom de l'entreprise n'est pas repris"
grep -qE '420 ?000' <<< "$F" || _ko "le chiffre d'affaires de la fiche n'est pas repris"
grep -qE 'À COMPLÉTER' <<< "$F" || _ko "aucun [À COMPLÉTER] pour les champs absents de la fiche"
grep -qE 'dume\.chorus-pro\.gouv\.fr|economie\.gouv\.fr' <<< "$F" || _ko "pas de source officielle des formulaires"
grep -qE '13/11/2026|novembre 2026|[0-9]{2}/[0-9]{2}/2026' <<< "$F" || _ko "pas de date de vérification des formulaires"

# Rappel sur le prix, dans le fichier et dans la réponse.
PRIX_R=$(rubrique "$P" "Le prix")
[ -n "$PRIX_R" ] || _ko "rubrique « Le prix reste à vous » absente"
grep -qiE 'BPU|DPGF|DQE|acte d.engagement' <<< "$PRIX_R" || _ko "le rappel sur le prix ne nomme pas les documents de prix"
grep -qiE 'vous|artisan' <<< "$PRIX_R" || _ko "le rappel ne dit pas que le prix est à l'artisan"
sortie_contient 'prix.{0,160}(vous|à votre charge|reste)|(vous|reste).{0,160}prix' "le rappel sur le prix dans la réponse"

# Rappel de vérification sur la plateforme.
fichier_contient "$P" 'plateforme' "le rappel plateforme"
sortie_contient 'vérifi.{0,120}plateforme|plateforme.{0,120}vérifi' "le rappel de vérifier les dates sur la plateforme"

# Suivi : la ligne passe à « en préparation », verdict conservé, une seule ligne.
L=$(grep -i 'val-de-brelle' "$D/suivi.md")
grep -qi 'en préparation' <<< "$L" || _ko "le suivi n'indique pas le statut en préparation"
grep -qi 'analysée' <<< "$L" && _ko "le suivi indique encore analysée"
grep -q '🟠' <<< "$L" || _ko "le verdict a disparu du suivi"
grep -q '2027-01-15' <<< "$L" || _ko "la date limite a disparu du suivi"
[ "$(grep -ci 'val-de-brelle' "$D/suivi.md")" -eq 1 ] || _ko "la consultation n'apparaît pas exactement une fois dans le suivi"

# Aucun prix proposé.
PRIX='(proposer|facturer|chiffrer|demander|pratiquer|viser) (un|le|ce) (prix|montant|tarif)|prix (conseillé|recommandé|à proposer|à pratiquer)|je (vous )?(propose|conseille|recommande) .{0,40}[0-9] ?(€|euros)|fourchette de prix'
fichier_ne_contient_pas "$P" "$PRIX" "un prix proposé"
sortie_ne_contient_pas "$PRIX" "un prix proposé"

vouvoie
fin
