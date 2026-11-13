# Mémoire technique : le cadre de l'acheteur

Beaucoup d'acheteurs fournissent dans le DCE un document à remplir pour le mémoire technique : le **cadre de réponse** (souvent appelé « cadre de mémoire technique », « cadre de réponse technique », « CRT », « modèle de mémoire »). Il fixe les rubriques, leur ordre, les questions posées et parfois des limites (nombre de pages, de caractères). Quand le règlement de consultation l'impose, un mémoire qui ne le suit pas peut être mal noté, voire écarté.

Cette fiche complète [memoire-technique.md](memoire-technique.md) : elle dit comment trouver ce cadre, comment construire la trame à partir de lui, et comment écrire les réponses **dans une copie du document de l'acheteur**. Les commandes propres au système sont dans [memoire-production-mac.md](memoire-production-mac.md) et [memoire-production-windows.md](memoire-production-windows.md).

## 1. Le trouver

À l'étape 1 de memoire-technique.md, cherchez dans `dce/` du sous-dossier de la consultation (sous-dossiers compris) un fichier dont le nom contient, sans tenir compte des majuscules, des accents ni des séparateurs (`_`, `-`, espace) : `cadre`, `CRT`, `modèle de mémoire`, `trame`, `mémoire technique`, `réponse technique`, `questionnaire technique`. Formats possibles : `.docx`, `.doc`, `.odt`, `.rtf`, plus rarement `.xlsx` ou `.pdf`.

- **Contrôlez avec le RC** : relisez l'article sur le contenu de l'offre et celui des critères. S'il cite un cadre ou un modèle de mémoire (« le mémoire est présenté selon le cadre joint », « l'utilisation du cadre est obligatoire »), retenez **le fichier qu'il nomme** et notez si son usage est **obligatoire** (avec l'article).
- Un fichier au nom trompeur (un CCTP qui contient « technique », un modèle de DC4) n'est pas un cadre : ouvrez-le avant de conclure. Un cadre pose des questions ou laisse des cases « réponse du candidat » à remplir.
- Plusieurs candidats possibles (un par lot, par exemple) : prenez celui du lot de l'artisan ; en cas de doute, demandez-lui (une seule question).
- **Aucun cadre** : la suite de memoire-technique.md s'applique sans changement.

**Dites-le à l'artisan** dès l'annonce de l'étape 1 (point 7), en une phrase : « Le DCE contient un cadre de mémoire de l'acheteur (`07_CRT…docx`) ; son usage est obligatoire (RC, article 10). Je vais remplir directement ce document. » Ne modifiez jamais le fichier de `dce/` lui-même.

## 2. La trame suit le cadre, exactement

Lisez le cadre paragraphe par paragraphe avec la commande `lister` (fiches de production), ou, pour un `.xlsx` ou un `.pdf`, comme une autre pièce du DCE. Puis, à la place de l'étape 2 de memoire-technique.md :

- **Les rubriques du cadre, dans son ordre, avec ses mots** (numéros compris) : une section par rubrique, une sous-section par question. N'ajoutez pas de rubrique, n'en fusionnez pas, n'en sautez pas. Les critères du RC servent à savoir combien pèse chaque rubrique (dites-le à l'artisan), pas à changer le plan.
- **Les questions du cadre** sont reprises telles quelles sous chaque rubrique : c'est à elles que l'artisan répond.
- **Les limites** : notez pour chaque rubrique le nombre maximum de caractères ou de pages, et pour l'ensemble le nombre de pages. Une réponse ne les dépasse jamais. Pour les pages, comptez environ 3 000 caractères par page de texte et dites à l'artisan que c'est une estimation, à vérifier à l'ouverture du fichier.
- La « Présentation de l'entreprise » et les « Références » n'apparaissent que si le cadre a une rubrique pour cela (c'est fréquent) ; sinon elles ne sont pas ajoutées dans le cadre. Toutes les règles de memoire-technique.md restent vraies : anti-invention, pas de prix, [À COMPLÉTER] pour ce qui manque.
- Une rubrique du cadre sur le prix ou les délais chiffrés que l'artisan seul connaît : [À COMPLÉTER], jamais un chiffre de votre part.

Les questions de l'étape 3 se choisissent d'après les questions du cadre ; `memoire-reponses.md` reprend ses intitulés.

## 3. Deux fichiers produits

1. **Notre mémoire** (`memoire-technique.docx`), comme d'habitude, mais avec la trame du cadre (mêmes rubriques, même ordre, questions reprises). Il sert de brouillon lisible et de solution de secours.
2. **Le cadre de l'acheteur rempli** : une **copie** du document de l'acheteur dans laquelle chaque réponse est écrite à la suite de sa rubrique ou de sa question, ou dans la case « réponse » prévue. Le texte de l'acheteur, sa mise en page, ses en-têtes et pieds de page ne sont pas modifiés. Nom : `memoire-technique-cadre-acheteur.docx`, dans le sous-dossier de la consultation, à côté de notre mémoire (jamais d'écrasement : `memoire-technique-cadre-acheteur-2.docx` s'il existe déjà).

## 4. Le fichier de réponses

Le remplissage se fait avec un script (fiches de production). Il lui faut le cadre et un fichier de réponses, `reponses-cadre.txt`, que vous écrivez dans le **dossier temporaire** de l'étape 4 (UTF-8, avec l'outil d'écriture de fichiers de l'agent).

D'abord, `lister` le cadre : chaque paragraphe s'affiche avec son numéro, sa place dans un tableau s'il y est, son style, et son texte (`(vide)` pour une ligne vide) :

```
¶6 {Heading2} | 1.1 Décrivez l'enchaînement des travaux, de la dépose à la mise en service.
¶7 {Consigne} | 3 000 caractères maximum, espaces compris.
¶8 | (vide)
¶16 [tableau 1, ligne 2, cellule 1] | 2.1 Composition de l'équipe affectée au chantier
¶17 [tableau 1, ligne 2, cellule 2] | (vide)
```

Puis un bloc par endroit à remplir :

```
### 8
@max 3000
Nous commençons par la dépose des anciens appareils, puis …
[À COMPLÉTER : la mise en service du ballon d'eau chaude]

### 17
Trois personnes : le dirigeant et deux compagnons.

### 22 | 3.1 Décrivez les mesures prises
[À COMPLÉTER : les mesures pour isoler le chantier, le bruit et la poussière]
```

- `### <numéro>` désigne le paragraphe du cadre. **Choisissez l'endroit prévu pour la réponse** : la case vide à droite de la question dans un tableau (¶17), la ligne vide laissée sous la question (¶8) ; s'il n'y en a pas, la question elle-même (¶22) ou la consigne qui la suit.
- Après `|`, recopiez le **début du texte** de ce paragraphe tel que `lister` l'affiche ; rien pour un paragraphe `(vide)`. Le script refuse un numéro dont le texte ne correspond pas : c'est la garantie que la réponse va au bon endroit.
- La réponse s'écrit **après** un paragraphe qui a du texte, et **à la place** d'un paragraphe vide (juste avant lui : la ligne vide de l'acheteur reste en dessous).
- `@max <nombre>` (facultatif, juste sous `###`) : la limite de caractères du cadre pour cette réponse. Le script refuse une réponse plus longue.
- Ensuite, une ligne par paragraphe. Une ligne qui commence par `- ` devient une ligne de liste (tiret et retrait). Pas de HTML, pas de mise en forme : la réponse prend le style normal du document de l'acheteur.
- [À COMPLÉTER : …] s'écrit tel quel dans la ligne : le script le surligne en jaune et le met en gras rouge.
- Chaque rubrique ou question du cadre reçoit un bloc, même s'il ne contient qu'un [À COMPLÉTER]. Une rubrique sans question (simple titre suivi de sous-questions) n'en a pas besoin. Ne remplissez pas les zones de signature, de date ou de prix.
- Les réponses sont les mêmes phrases que dans notre mémoire : même source, mêmes [À COMPLÉTER].

## 5. Ce que dit le script

La dernière ligne affichée est `CADRE <chemin> <blocs> <surlignés>` quand tout va bien. Avant elle, deux avertissements possibles : `CONVERTI <format>` (Mac : le `.doc`, `.odt` ou `.rtf` de l'acheteur a été converti en `.docx` ; la mise en forme, en particulier les tableaux, a pu changer) et `PROTEGE` (le document de l'acheteur est protégé contre la modification dans Word : l'artisan devra peut-être retirer la protection, ou recopier ses réponses dans les zones autorisées).

| Code | Sens | Que faire |
|---|---|---|
| 0 | Cadre rempli et contrôlé | Rendez compte (étape 7 de memoire-technique.md). Avec `CONVERTI`, dites que la mise en forme a pu changer par rapport au document de l'acheteur et qu'il faut la comparer à l'original. |
| 4 | Le fichier existe déjà | Autre nom (`memoire-technique-cadre-acheteur-2.docx`), et relancez. Ne supprimez rien. |
| 6 | Le fichier de réponses ne correspond pas au cadre (numéro absent, texte d'ancrage différent, limite dépassée) | Le message dit quel bloc. Corrigez `reponses-cadre.txt` (relancez `lister` au besoin, raccourcissez la réponse sans perdre d'information de l'artisan) et relancez. |
| 5 | Format non pris en charge (`.xlsx`, `.pdf` ; sous Windows aussi `.doc`, `.odt`, `.rtf`) | Solution de secours, ci-dessous. |
| 2, 3, 7 | Fichier introuvable ou illisible, outil absent, contrôle final échoué : rien n'est produit | Solution de secours, ci-dessous. Ne cachez pas l'échec. |

**Solution de secours** : notre `memoire-technique.docx`, qui suit déjà la structure du cadre, est la réponse. Dites à l'artisan, en une phrase, que vous n'avez pas pu écrire dans le document de l'acheteur (dites pourquoi, simplement) et qu'il doit recopier chaque réponse sous la rubrique correspondante du cadre, avant de déposer ce cadre. Si l'usage du cadre est obligatoire, insistez : déposer seulement notre mémoire ne suffit pas.

Sous Windows, n'essayez pas d'ouvrir le document avec Word pour le convertir ou le remplir : le pilotage de Word peut se bloquer sans rendre la main (constaté en test).
