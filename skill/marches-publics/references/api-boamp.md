# API du BOAMP

Fiche pour vous, pas pour l'artisan : n'y montrez ni requête, ni champ, ni réponse brute (voir [ton.md](ton.md)). L'artisan ne voit que le résultat, dit simplement.

Le BOAMP (Bulletin officiel des annonces des marchés publics) publie ses avis en données ouvertes, sans clé ni compte. Vous l'interrogez avec `curl` (présent sur Mac, et sur Windows 10 et plus sous le nom `curl.exe`) et vous lisez la réponse vous-même. **N'écrivez ni script, ni programme, et n'utilisez ni Python ni jq** : l'artisan n'a rien d'autre que `curl`. Cette fiche est utilisée par la veille ([veille.md](veille.md)) et par la recherche de descripteurs pour un métier absent de la table ([metiers.md](metiers.md)).

## Requête

Sur Mac, tapez `curl`. Sous Windows, tapez `curl.exe` (dans PowerShell, `curl` seul est un autre outil). Le reste est identique.

```
curl -s --compressed -G "https://boamp-datadila.opendatasoft.com/api/explore/v2.1/catalog/datasets/boamp/records" --data-urlencode "select=CHAMPS" --data-urlencode "where=CONDITIONS" --data-urlencode "order_by=datelimitereponse" --data-urlencode "limit=30"
```

- `--compressed` est obligatoire : sans lui, le serveur renvoie du texte compressé illisible.
- `-G` avec `--data-urlencode` se charge d'encoder les espaces, les apostrophes et les parenthèses : n'encodez rien à la main.
- Mettez chaque paramètre entre **guillemets doubles** et les valeurs de texte entre **apostrophes simples** à l'intérieur (`where=type_marche='TRAVAUX'`). Cela fonctionne tel quel dans le Terminal du Mac et dans PowerShell.
- `limit` vaut 100 au maximum.
- La réponse est du JSON : `total_count` (nombre d'avis qui correspondent) et `results` (la liste).

## La requête de la veille

Remplacez les valeurs entre crochets, et seulement elles :

```
curl -s --compressed -G "https://boamp-datadila.opendatasoft.com/api/explore/v2.1/catalog/datasets/boamp/records" --data-urlencode "select=idweb,objet,nomacheteur,code_departement,datelimitereponse,famille,url_avis" --data-urlencode "where=type_marche='TRAVAUX' and nature_categorise='appeloffre/standard' and etat='INITIAL' and datelimitereponse>=now(days=+10) and code_departement in ([DEPARTEMENTS]) and descripteur_code in ([DESCRIPTEURS])" --data-urlencode "order_by=datelimitereponse" --data-urlencode "limit=30"
```

Exemple pour des départements 69 et 01 et des descripteurs 270, 319, 61 et 452 :

`code_departement in ('69','1') and descripteur_code in ('270','319','61','452')`

Ce que fait chaque condition :

| Condition | Sens |
|---|---|
| `type_marche='TRAVAUX'` | avis de travaux (pas fournitures ni services) |
| `nature_categorise='appeloffre/standard'` | avis d'appel à la concurrence (la consultation est ouverte). Les autres natures sont des résultats d'attribution, des modifications, des annulations, des concessions, des concours |
| `etat='INITIAL'` | avis d'origine. Les rectificatifs (`RECTIFICATIF`) et les annulations sont d'autres avis sur la même consultation : les garder créerait des doublons |
| `datelimitereponse>=now(days=+10)` | date limite de réponse dans au moins 10 jours à partir de maintenant. Le serveur fait le calcul : pas de date à écrire. Les avis sans date limite sont écartés |
| `code_departement in (...)` | au moins un des départements de l'avis est dans la zone |
| `descripteur_code in (...)` | au moins un des descripteurs de l'avis est dans la liste |

Les listes de départements et de descripteurs sont les valeurs de la fiche entreprise, converties comme indiqué ci-dessous.

## Lire les détails d'un avis

Le champ `donnees` est lourd (jusqu'à 25 000 caractères par avis) : ne le demandez que pour les consultations que vous allez présenter, quelques-unes à la fois.

```
curl -s --compressed -G "https://boamp-datadila.opendatasoft.com/api/explore/v2.1/catalog/datasets/boamp/records" --data-urlencode "select=idweb,famille,donnees" --data-urlencode "where=idweb in ('26-102822','26-108493')"
```

`donnees` est du JSON écrit comme un texte, dans le JSON de la réponse : les guillemets y sont précédés d'une barre oblique inverse. Lisez-le tel quel. Si la réponse est très longue, enregistrez-la dans un fichier temporaire (`-o` de `curl`) et cherchez les mots utiles dedans (`grep` sur Mac, `Select-String` sous Windows) plutôt que de la lire en entier.

### Lecture tolérante

La structure de `donnees` dépend du champ `famille` et n'est jamais garantie. Cherchez les noms ci-dessous **où qu'ils soient** dans le texte, et si vous ne trouvez rien, dites « non précisé » : ne devinez jamais.

| Famille | Qu'est-ce que c'est | Montant estimé | Lien vers le DCE |
|---|---|---|---|
| `FNS` | avis national standard | `valeurEstimee` : `valeur`, ou `fourchette` avec `valeurBasse` et `valeurHaute` ; par lot : `estimationValeur`, `valeur` | `urlDocConsul` (lien direct), sinon `urlProfilAch` |
| `MAPA` | procédure adaptée (petits et moyens marchés) | rarement indiqué : cherchez « montant » ou « estim » dans les textes `rensgComplt` et `quantites` | `urlProfilAcheteur` (la plateforme de l'acheteur, pas le dossier lui-même) ; le texte `rensgComplt` précise souvent où le télécharger |
| `JOUE` | avis européen (format eForms) | `EstimatedOverallContractAmount` ; **une valeur à 0 veut dire « non précisé »** ; `FrameworkMaximumAmount` est le plafond d'un accord-cadre, pas le prix du lot | `CallForTendersDocumentReference` puis `URI` (lien direct), sinon `BuyerProfileURI` |
| `DIVERS`, `DSP` | autres | cherchez comme ci-dessus | `url_avis` |

- Un montant à 0, vide ou absent n'est pas un montant : écrivez « non précisé ».
- Si `donnees` est vide ou illisible, présentez la consultation avec ce que les champs simples donnent (objet, acheteur, date limite, `url_avis`).
- Les montants sont en euros hors taxes, sauf mention contraire.

## Champs utiles

| Champ | Contenu |
|---|---|
| `idweb` | identifiant de l'avis (exemple `26-102822`) : sert à retrouver un avis, jamais à l'artisan |
| `objet` | titre de la consultation, souvent en majuscules et très long |
| `nomacheteur` | nom de l'acheteur |
| `code_departement` | liste des départements (une consultation peut en couvrir plusieurs) |
| `type_marche` | liste, contient `TRAVAUX`, `FOURNITURES` ou `SERVICES` |
| `nature_categorise` | `appeloffre/standard` pour un appel à la concurrence |
| `datelimitereponse` | date et heure limite de remise des offres. L'heure affichée est l'heure locale de l'acheteur, malgré le « +00:00 » : ne la convertissez pas |
| `dateparution` | date de publication de l'avis |
| `descripteur_code`, `descripteur_libelle` | listes de même longueur dans le même ordre : le 1er code va avec le 1er libellé |
| `url_avis` | page de l'avis sur le site du BOAMP : c'est le lien à donner |
| `famille` | `FNS`, `MAPA`, `JOUE`… : donne la structure de `donnees` |
| `etat` | `INITIAL`, `RECTIFICATIF`, `ANNULATION`, `MODIFICATION` |
| `donnees` | détails de l'avis (voir plus haut) |

Pour voir la liste complète des champs : `curl -s --compressed "https://boamp-datadila.opendatasoft.com/api/explore/v2.1/catalog/datasets/boamp"`.

## Pièges

- **Les départements s'écrivent sans zéro initial** : l'Ain est `'1'` et non `'01'`, l'Ariège `'9'` (vérifié : `'01'` et `'2A'` renvoient 0 avis, `'1'` en renvoie plusieurs milliers, et `'20A'` aussi). Un avis cite souvent plusieurs départements : il suffit qu'un seul soit dans la zone. À partir de 10, rien ne change (`'69'`). La Corse est `'20A'` (Corse-du-Sud) et `'20B'` (Haute-Corse), l'outre-mer `'971'`, `'972'`, `'973'`, `'974'`, `'976'`. La fiche contient les numéros usuels (01, 2A) : convertissez-les.
- **Les champs à plusieurs valeurs** (`code_departement`, `descripteur_code`, `type_marche`) se filtrent avec `in (...)` ou avec `=` : la condition est vraie si l'une des valeurs correspond.
- **Les codes sont du texte** : mettez-les entre apostrophes (`'270'`).
- **Ne regroupez jamais deux champs à plusieurs valeurs** avec `group_by` (par exemple `descripteur_code` et `descripteur_libelle`) : le résultat est un produit croisé et mélange les codes et les libellés. Demandez les deux listes par avis, et associez-les par position.
- **Les avis de rectification** (`etat` différent de `INITIAL`) répètent une consultation déjà publiée : filtrez sur `etat='INITIAL'`.
- **Une consultation peut mêler plusieurs lots et plusieurs métiers** : son `objet` n'est pas toujours celui du lot de l'artisan. Lisez-le avant de présenter la consultation comme adaptée.
- **Texte à chercher dans l'objet** : `search(objet,'piscine')` (un mot, sans accent ni apostrophe), combinable avec `and`.
- Une erreur de requête revient en JSON avec un message (`message`, `error_code`) : relisez la condition. Pas de réponse du tout ou erreur du serveur : le site est injoignable (voir [veille.md](veille.md)).
