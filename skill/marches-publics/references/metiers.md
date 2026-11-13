# Table des métiers

Cette table traduit le métier de l'artisan en **descripteurs BOAMP** (les mots-clés du site officiel des annonces, qui servent à la veille) et en **codes CPV** (la nomenclature européenne des achats publics, qui sert à affiner). Ne montrez jamais ces codes à l'artisan pendant le questionnaire : ils sont enregistrés dans sa fiche, c'est tout.

## Table

Une ligne par métier. Pour ajouter un métier, ajoutez une ligne au même format.

| Métier (et mots de l'artisan) | Descripteurs BOAMP | Codes CPV |
|---|---|---|
| Plombier (plomberie, sanitaire) | 270 Plomberie (travaux) ; 319 Sanitaire | 45330000-9 ; 45332000-3 |
| Chauffagiste (chauffage, pompe à chaleur, chaudière) | 61 Chauffage (travaux) ; 452 Géothermie | 45331000-6 ; 45331100-7 |
| Climaticien, ventilation (clim, VMC) | 62 Climatisation ; 360 Ventilation | 45331200-8 ; 45331210-1 |
| Électricien (électricité, courants faibles) | 105 Electricité (travaux) ; 47 Câblage ; 81 Contrôle d'accès | 45310000-3 ; 45311000-0 ; 45317000-2 |
| Éclairage public | 102 Eclairage public | 45316100-6 |
| Installateur photovoltaïque (panneaux solaires) | 476 Photovoltaïque | 45261215-4 ; 45311200-2 |
| Menuisier (menuiserie bois, PVC, alu, portes, fenêtres) | 222 Menuiserie ; 38 Bois | 45421000-4 ; 45421100-5 ; 45421150-0 |
| Charpentier | 57 Charpente ; 38 Bois | 45261100-5 ; 45422000-1 |
| Couvreur, zingueur (toiture, gouttières) | 74 Couverture ; 372 Zinguerie | 45261210-9 ; 45261300-7 ; 45261000-4 |
| Étancheur (toiture-terrasse) | 117 Etanchéité | 45261420-4 |
| Maçon (maçonnerie, gros œuvre) | 195 Maçonnerie ; 144 Gros oeuvre | 45262500-6 ; 45223220-4 ; 45262300-4 |
| Façadier (ravalement, bardage) | 299 Ravalement ; 30 Bardage | 45443000-4 |
| Plâtrier, plaquiste (cloisons, faux plafonds) | 269 Plâtrerie ; 63 Cloison, faux plafond | 45410000-4 ; 45421152-4 ; 45421146-9 |
| Isolation (isolation thermique, combles) | 169 Isolation | 45320000-6 ; 45321000-3 ; 45261410-1 |
| Peintre (peinture, revêtements muraux) | 264 Peinture (travaux) ; 309 Revêtements muraux | 45442100-8 ; 45442110-1 |
| Carreleur | 53 Carrelage | 45431000-7 |
| Solier (sols souples, parquet, moquette) | 308 Revêtements de sols | 45432100-5 |
| Serrurier, métallier (serrurerie, ferronnerie, portails) | 321 Serrurerie ; 223 Métallerie ; 126 Ferronnerie ; 412 Porte automatique, portail | 45421140-7 ; 45421148-3 ; 45262400-5 |
| Vitrier | 363 Vitrerie | 45441000-0 |
| Sécurité incendie | 332 Sécurité incendie ; 90 Détection incendie | 45343000-3 |
| Démolition, désamiantage | 87 Démolition ; 479 Amiante (désamiantage) | 45111100-9 ; 45262660-5 |
| Terrassier, VRD (voirie et réseaux divers) | 341 Terrassement ; 366 Voirie et réseaux divers ; 18 Assainissement | 45112500-0 ; 45233140-2 ; 45232410-9 |
| Paysagiste (espaces verts, clôtures) | 116 Espaces verts ; 64 Clôture | 45112710-5 ; 45342000-6 |
| Entreprise générale, tous corps d'état | 345 Tous corps d'état ; 33 Bâtiment | 45210000-2 ; 45453000-7 |

Pour un artisan qui a plusieurs métiers, réunissez les descripteurs et les codes de chaque ligne, sans doublon.

## Métier absent de la table

Si le métier de l'artisan n'est dans aucune ligne :

1. Choisissez un ou deux mots qui décrivent **le chantier**, pas le métier : « piscine » plutôt que « pisciniste », « ascenseur » plutôt qu'« ascensoriste ».
2. Cherchez les avis de travaux qui contiennent ce mot sur le site officiel des annonces (API du BOAMP, sans clé) :

   ```
   curl -s -G "https://boamp-datadila.opendatasoft.com/api/explore/v2.1/catalog/datasets/boamp/records" --data-urlencode "select=descripteur_code,descripteur_libelle" --data-urlencode "where=type_marche='TRAVAUX' and search(objet,'MOT')" --data-urlencode "order_by=dateparution desc" --data-urlencode "limit=50"
   ```

   Remplacez `MOT` par votre mot, sans accent ni apostrophe. Sous Windows, tapez `curl.exe` au lieu de `curl`.
3. Dans chaque avis, `descripteur_code` et `descripteur_libelle` sont deux listes dans le même ordre : le premier code correspond au premier libellé, et ainsi de suite. Comptez les descripteurs qui reviennent, et gardez ceux dont le libellé décrit vraiment le métier (pas « Bâtiment » ni « Electricité (travaux) » pour un pisciniste).
4. Pour les codes CPV, prenez le code de la famille 45 (travaux) dont le libellé correspond. Si vous n'êtes pas sûr, n'en mettez pas : la veille fonctionne avec les seuls descripteurs.
5. Dites à l'artisan, en une phrase et sans codes, ce que vous avez trouvé (« Je chercherai les consultations classées "Piscine" ») et demandez-lui si cela lui convient. Enregistrez-les dans sa fiche seulement s'il est d'accord.
6. Si la recherche ne donne rien, ou si l'API ne répond pas, dites-le simplement, enregistrez le métier tel qu'il l'a dit et marquez les descripteurs [À COMPLÉTER].

Ne modifiez pas cette table depuis la conversation : elle est remplacée à chaque mise à jour de l'outil. Le formateur la complète dans le dépôt.
