# API des DECP et Recherche d'entreprises

Fiche pour vous, pas pour l'artisan : n'y montrez ni requête, ni champ, ni réponse brute (voir [ton.md](ton.md)). Elle est utilisée par le bilan ([bilan.md](bilan.md)). **Dernière vérification : 13/11/2026**, par de vraies requêtes. À revérifier avant chaque session de formation.

Même règle que pour le BOAMP ([api-boamp.md](api-boamp.md)) : `curl` seul (`curl.exe` sous Windows), sans clé ni compte, **pas de script, ni Python, ni jq**. Mêmes conventions : `-G` avec `--data-urlencode`, paramètres entre guillemets doubles, texte entre apostrophes simples. `--compressed` est facultatif ici (retirez-le s'il est refusé).

## 1. Les DECP : qui a obtenu le marché ?

Les DECP (données essentielles de la commande publique) sont les marchés **déjà attribués**, publiés par les acheteurs. Jeu de données : **`decp-2022-marches-valides`** (« Données Essentielles de la Commande Publique, arrêté du 22/12/2022, marchés »), sur data.economie.gouv.fr (Opendatasoft). Il existe toujours, avec plus de 740 000 marchés, mis à jour chaque semaine (dernière mise à jour vue : 08/11/2026 ; dernières notifications : 07/11/2026).

```
curl -s --compressed -G "https://data.economie.gouv.fr/api/explore/v2.1/catalog/datasets/decp-2022-marches-valides/records" --data-urlencode "select=id,objet,acheteur_id,titulaire_id_1,titulaire_id_2,titulaire_id_3,titulaire_typeidentifiant_1,montant,datenotification,datepublicationdonnees,offresrecues,procedure,lieuexecution_code,codecpv" --data-urlencode "where=startswith(acheteur_id,'[SIREN]') and startswith(codecpv,'45') and datenotification>='[AAAA-MM-JJ]'" --data-urlencode "order_by=datenotification desc" --data-urlencode "limit=30"
```

Remplacez les valeurs entre crochets, et seulement elles. La réponse est du JSON : `total_count` (nombre de marchés trouvés) et `results` (la liste).

### Retrouver le marché de l'artisan

Il n'y a **aucun lien direct** entre l'avis du BOAMP et les DECP : pas d'identifiant commun, et le jeu ne contient pas le nom de l'acheteur, seulement son SIRET. On retrouve le marché par l'acheteur, l'objet et les dates.

1. **Le SIREN de l'acheteur** (9 chiffres) : cherchez son nom dans Recherche d'entreprises (partie 2, par exemple `q=Commune de Bron`, avec `departement=69` si utile). Les communes y sont enregistrées sous « COMMUNE DE … ». **Ne retenez un résultat que si son nom correspond exactement** à l'acheteur de la consultation et que le département est cohérent ; sinon dites que vous n'avez pas pu identifier l'acheteur, ne prenez pas « le plus proche ».
2. **Filtrez avec `startswith(acheteur_id,'SIREN')`**, pas avec l'égalité : `acheteur_id` est un SIRET de 14 chiffres et un même acheteur en a plusieurs (vérifié : une commune en a au moins deux).
3. **Limitez aux travaux** avec `startswith(codecpv,'45')` (les codes CPV de travaux commencent par 45) et à une période : le marché est notifié **après** la date limite de remise des offres, en général de quelques semaines à quelques mois. Utilisez `datenotification>='AAAA-MM-JJ'` avec la date limite de la consultation.
4. **Cherchez dans l'objet** avec `search(objet,'toiture')` (un mot par `search`, sans accent, à combiner avec `and`), ou lisez la liste triée par `datenotification desc`. L'objet est écrit par l'acheteur, en majuscules et sans règle : il reprend parfois le lot, parfois seulement le chantier, avec des fautes ou des doubles espaces. Comparez-le avec le titre et le lot de la consultation, et vérifiez que la date de notification est cohérente avec la date limite.
5. S'il reste **plusieurs marchés plausibles**, dites que vous ne savez pas lequel est le bon et présentez-les, ou demandez à l'artisan.
6. S'il n'y en a **aucun**, ne cherchez pas plus loin que deux ou trois variantes de mots : c'est une absence de données (voir [bilan.md](bilan.md)).

### Champs utiles

| Champ | Contenu |
|---|---|
| `id` | identifiant du marché (propre à l'acheteur) : jamais à l'artisan |
| `objet` | objet du marché ou du lot |
| `acheteur_id` | SIRET de l'acheteur |
| `titulaire_id_1`, `_2`, `_3` | SIRET des titulaires (plusieurs en cas de groupement) |
| `titulaire_typeidentifiant_1` | `SIRET` normalement ; autre chose (numéro étranger, TVA…) : ce n'est pas un SIRET, ne le cherchez pas |
| `montant` | montant du marché, en euros **hors taxes** (nombre) |
| `datenotification` | date de notification du marché au titulaire |
| `datepublicationdonnees` | date de publication des données |
| `offresrecues` | nombre d'offres reçues, quand l'acheteur l'indique |
| `procedure` | `Procédure adaptée`, `Appel d'offres ouvert`… |
| `codecpv` | code CPV principal |
| `dureemois` | durée en mois |

Le jeu a plus de 50 champs (modifications, sous-traitance…). Liste complète : `curl -s --compressed "https://data.economie.gouv.fr/api/explore/v2.1/catalog/datasets/decp-2022-marches-valides"`.

### Pièges

- **Valeurs vides déguisées.** Un champ sans information contient `CDL`, `CDL NC`, `MQ NC`, `NC`, ou est absent : ce n'est **pas** une donnée. Un `titulaire_id_2` à `CDL` veut dire « pas de second titulaire » ; `offresrecues` à `MQ NC` veut dire « non communiqué ».
- **Montant** : un montant absent, à 0, ou très rond (400 000, 800 000) peut être un **plafond d'accord-cadre** (marché à bons de commande, « entretien… ») ou une estimation, pas le prix payé. Dites-le au moindre doute.
- **Retard de publication** : l'acheteur publie ses données après la notification, parfois des mois plus tard, et beaucoup de petits marchés ne sont pas publiés du tout. Un marché absent ne veut pas dire que la consultation n'est pas attribuée.
- **Pas de nom** : ce jeu ne donne que des SIRET. Les noms viennent de Recherche d'entreprises (partie 2).
- **`like '45%'` ne marche pas** (0 résultat, sans erreur) : utilisez `startswith(...)`. Codes et SIRET sont du texte : entre apostrophes.
- **Sans `limit`**, la réponse ne contient que 10 marchés ; le maximum est 100.
- Une erreur de requête revient en JSON avec `message` et `error_code` : relisez la condition. Pas de réponse du tout : le site est injoignable, dites-le simplement (voir [bilan.md](bilan.md)).
- D'autres jeux portent des noms d'acheteurs (`decp-v3-marches-valides`, `decp_augmente`) mais l'un est l'ancien format de 2019, l'autre est marqué obsolète : ne les utilisez pas.

## 2. Recherche d'entreprises : le nom à partir du SIRET

API publique de l'État, sans clé : `https://recherche-entreprises.api.gouv.fr/search`.

```
curl -s -G "https://recherche-entreprises.api.gouv.fr/search" --data-urlencode "q=[SIRET]"
```

Exemple vérifié : `q=38417986700039` donne GIBERT, à Chassieu.

- **Par SIRET** (14 chiffres, sans espace) ou **par SIREN** (9 chiffres) : `q` donne l'entreprise. La réponse contient `total_results` et `results`.
- Dans `results[0]` : `nom_complet` (nom de l'entreprise), `siren`, `siege.libelle_commune` et `siege.code_postal` (où elle est), `siege.activite_principale`, `etat_administratif` (`A` en activité, `C` cessée), `matching_etablissements` (l'établissement du SIRET demandé). Les autres champs (dirigeants, finances…) : ne les utilisez pas ici. La réponse est longue : cherchez ces champs, ne la recopiez pas.
- **Par nom** : `q=Commune de Bron`, avec si utile `--data-urlencode "departement=69"`. Plusieurs résultats voisins sont renvoyés : prenez celui dont le nom est exactement le bon.
- **Aucun résultat** (`total_results` à 0, réponse 200) pour un SIRET : l'établissement n'est pas diffusé ou n'existe plus. Écrivez « nom introuvable » avec le numéro, ne le devinez pas.
- **Plusieurs titulaires** : une requête par SIRET, l'une après l'autre (au-delà de 7 par seconde, erreur 429 : attendez quelques secondes).
- Le nom est en majuscules : écrivez-le simplement (« Entreprise Exemple, à Lyon »). Donnez le nom, la commune et l'activité ; ne jugez pas l'entreprise.
