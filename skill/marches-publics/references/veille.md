# Veille

La veille cherche, sur le site officiel des annonces (le BOAMP), les consultations ouvertes qui correspondent à la fiche entreprise de l'artisan. Elle se lance à la demande : « trouvez-moi des chantiers », « trouvez-moi des consultations ». Pas de script : vous construisez vous-même les requêtes avec `curl`, comme l'explique [api-boamp.md](api-boamp.md) (lisez-la avant la première requête).

## 1. Lire la fiche

Lisez `ma-fiche-entreprise.md` ([fiche-entreprise.md](fiche-entreprise.md)).

- **Pas de fiche, ou descripteurs BOAMP encore [À COMPLÉTER], ou aucun département** : dites-le en une phrase (« Pour chercher, j'ai d'abord besoin de savoir quel est votre métier et où vous travaillez. ») et proposez de remplir la fiche, c'est l'étape 1 du menu. Ne lancez aucune requête.
- Sinon, relevez :
  - les **descripteurs** : le numéro au début de chaque descripteur (« 270 Plomberie (travaux) » donne `270`) ;
  - les **départements** : convertis pour le BOAMP (`01` devient `1`, `2A` devient `20A`, `2B` devient `20B` ; voir les pièges d'api-boamp.md) ;
  - la **fourchette de montant** d'un lot, si elle est renseignée.

## 2. Interroger le BOAMP

Lancez la requête de la veille d'[api-boamp.md](api-boamp.md) : travaux, avis d'appel à la concurrence, départements et descripteurs de la fiche, date limite dans au moins 10 jours, triés par date limite, avec `limit=30`. Les codes CPV de la fiche ne servent pas à filtrer.

Pourquoi 30 et non 10 : certaines consultations sont déjà dans le suivi et seront écartées à l'étape suivante. Si les 30 sont toutes déjà suivies et que `total_count` en annonce davantage, ajoutez `offset=30` pour lire la suite.

**Si le site ne répond pas** (pas de réponse, erreur du serveur, texte illisible même avec `--compressed`) : dites-le simplement, sans détail technique (« Je n'arrive pas à joindre le site des annonces pour le moment. Vous pouvez me redemander dans quelques minutes. »). Ne touchez pas au suivi et n'inventez aucune consultation.

## 3. Écarter ce qui est déjà suivi

Lisez `suivi.md` (créez-le comme indiqué dans [dossier-de-travail.md](dossier-de-travail.md) s'il n'existe pas).

Une consultation est déjà suivie quand son identifiant d'avis (ex. `26-102822`) apparaît dans la ligne d'une consultation du suivi (colonne Notes), ou quand une ligne a le même acheteur et un titre qui désigne clairement le même chantier. Écartez-la : elle n'est pas « nouvelle ». Ne modifiez pas sa ligne.

Gardez les **10 premières** consultations restantes (déjà triées par date limite). Il n'y en a jamais plus de 10 dans votre réponse.

## 4. Lire les détails

Pour ces consultations seulement, lisez `donnees` (une requête par idweb, ou quelques-unes à la fois ; voir « Lire les détails d'un avis » dans [api-boamp.md](api-boamp.md)) pour trouver, quand ils sont indiqués :

- le **montant estimé** (euros hors taxes) ;
- le **lien vers le DCE** (le dossier de la consultation), sinon celui de la plateforme de l'acheteur.

La lecture est tolérante : une information introuvable devient « non précisé », jamais une valeur devinée. Un montant à 0 n'est pas un montant.

## 5. Présenter les résultats

La conclusion d'abord : combien de nouvelles consultations, et s'il y en a déjà dans le suivi, combien (« J'ai trouvé 6 nouvelles consultations. Vous en suiviez déjà 2. »). Puis une liste numérotée, dans l'ordre de la date limite. Pour chacune :

1. **Un résumé en une phrase**, en mots simples, tiré de l'objet de l'avis : quel chantier, où, quel lot ou quels métiers concernés (n'écrivez pas le titre en majuscules tel quel).
2. L'**acheteur** (le nom de l'organisme qui lance la consultation).
3. Le **montant estimé** s'il est connu, sinon « montant non précisé ». S'il est connu et en dehors de la fourchette de la fiche, dites-le en quelques mots.
4. La **date limite** de remise des offres.
5. Le **lien vers l'avis** (`url_avis`).
6. Le **lien vers le DCE** quand il est connu. Sinon, dites que le dossier se télécharge depuis la page de l'avis ou la plateforme de l'acheteur.

Si une consultation couvre beaucoup de départements ou de métiers, ou ressemble à un chantier trop gros ou sans rapport avec le métier de l'artisan, dites-le en une phrase plutôt que de la cacher.

Aucun code technique dans votre réponse : ni numéro de descripteur, ni identifiant d'avis, ni nom de champ.

Si une première lecture a donné plus de 10 consultations nouvelles, dites qu'il y en a d'autres et qu'elles viendront à la prochaine recherche.

**Aucune nouvelle consultation** : dites-le en une phrase (« Je n'ai rien de nouveau pour le moment. ») et rappelez que seules comptent celles dont la date limite est dans plus de 10 jours, laissant le temps de préparer une offre. Ne proposez pas d'élargir la zone ou les métiers sans qu'il le demande.

## 6. Mettre à jour le suivi

Ajoutez au bas du tableau de `suivi.md` une ligne par consultation **présentée** (jamais plus de 10), avec le statut `repérée` :

```markdown
| Rénovation de la chaufferie de l'école (lot chauffage) | Commune de Bron | 2026-12-04 | repérée | | Avis : https://www.boamp.fr/pages/avis/?q=idweb:26-109258 |
```

- Colonne Consultation : un titre court et lisible, pas l'objet en majuscules.
- Colonne Acheteur : son nom.
- Colonne Date limite : `AAAA-MM-JJ`, comme les autres lignes.
- Colonne Verdict : vide (c'est l'analyse qui le remplit).
- Colonne Notes : `Avis : ` suivi du lien de l'avis, sans rien d'autre qui le casse (c'est lui qui permet de ne pas reproposer la consultation) ; ajoutez `DCE : ` suivi du lien si vous le connaissez.

N'effacez, ne réécrivez et ne réordonnez aucune ligne existante. Ne changez pas le statut d'une consultation déjà dans le suivi.

## 7. Terminer

Dites en une phrase que ces consultations sont notées dans son suivi. Puis donnez, en quelques phrases, deux repères :

- **Le DCE** se télécharge sur la plateforme de l'acheteur : le lien de l'avis y mène, et le plus souvent le téléchargement est gratuit (une inscription simple est parfois demandée). Vous ne le téléchargez pas à sa place (ADR 0002) : une fois le dossier sur son ordinateur, il peut le glisser dans le dossier de la consultation et vous l'analyserez avec lui (étape 3 du menu).
- **Les petits marchés ne sont pas tous publiés au BOAMP.** Sous 100 000 € HT, un acheteur peut consulter directement des entreprises sans publier d'avis : ce que vous venez de voir n'est donc qu'une partie des chantiers publics. Pour être consulté, il faut aussi se faire connaître des acheteurs proches (étape 7 du menu).

Terminez par **une seule question** : laquelle des consultations il veut analyser, ou s'il préfère passer à autre chose.
