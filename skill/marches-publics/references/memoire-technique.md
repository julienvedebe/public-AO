# Mémoire technique

Le mémoire technique est le document où l'artisan explique comment il réalisera le lot (équipe, matériel, méthode, planning). L'acheteur le note selon les critères de son règlement de consultation. Cette étape le construit **à partir de ces critères**, en posant à l'artisan des questions ciblées, et le livre en `.docx` (ou `.rtf`) que l'artisan finalise lui-même.

**Si le DCE contient un cadre de mémoire de l'acheteur** (un document à remplir, souvent appelé « cadre de réponse technique » ou « CRT »), la trame suit exactement ce cadre et les réponses sont écrites directement dans une copie de ce document : voir [memoire-cadre-acheteur.md](memoire-cadre-acheteur.md), qui complète les étapes ci-dessous.

Cette fiche a deux parties :

- **Partie commune** (étapes 1 à 5 et règles) : la trame, les questions, la règle anti-invention, le HTML intermédiaire. Elle ne dépend pas de l'ordinateur.
- **Partie propre au système** (étape 6) : la conversion du HTML en `.docx`. Mac : [memoire-production-mac.md](memoire-production-mac.md). Windows : [memoire-production-windows.md](memoire-production-windows.md).

Lisez d'abord [dossier-de-travail.md](dossier-de-travail.md) et la fiche entreprise (`ma-fiche-entreprise.md`).

## Règle anti-invention (ADR 0002) : à respecter à chaque phrase

Le mémoire engage l'artisan, et un texte inventé se repère. Un seul chantier, un seul matériel ou un seul chiffre faux peut coûter la consultation.

**Seules sources de ce que l'entreprise a, est ou fait :**

1. **La fiche entreprise** : effectif, certifications, références, assurances, métiers.
2. **Les réponses de l'artisan**, dans cette conversation ou dans `memoire-reponses.md` (étape 3).

**Les documents de l'acheteur** (RC, CCTP, CCAP, analyse) servent à dire **ce qui est demandé**, jamais ce que l'artisan fait ou possède. Vous pouvez écrire « Le CCTP impose un essai de mise en pression de 24 heures (article 3.2) » ; vous ne pouvez pas écrire « Nous réalisons cet essai » tant que l'artisan ne l'a pas dit.

**Interdit**, même si cela « sonne bien » ou paraît évident pour le métier :

- un chiffre, une durée, un nombre de personnes, une date, une marque, une norme, un label qui ne vient pas de la fiche ou d'une réponse ;
- un matériel, un véhicule, un outil, un fournisseur, un chantier, un client non cités ;
- une certification ou une qualification absente de la fiche. Si le RC exige une qualification que la fiche ne contient pas, ne l'affirmez jamais : ne la mentionnez pas, ou écrivez [À COMPLÉTER] ;
- les phrases creuses qui affirment sans rien dire : « personnel qualifié et expérimenté », « matériel adapté et entretenu », « nous respectons toutes les normes en vigueur », « notre savoir-faire reconnu », « une démarche qualité rigoureuse » ;
- un engagement de l'artisan (respecter le délai, les horaires, un protocole) qu'il n'a pas confirmé ;
- un prix, un montant, une remise, un tarif (voir « Le prix » plus bas). Seuls les montants des références de la fiche et ceux que le DCE cite (estimation, pénalités) peuvent apparaître.

**Permis :** reprendre les mots de l'artisan en les nettoyant (orthographe, ponctuation, transcription vocale mal comprise, ordre des idées), sans rien ajouter de substance ni d'adjectif flatteur. Si sa réponse est courte, le paragraphe est court. Une réponse vague (« on fait attention aux enfants ») reste vague, suivie d'un [À COMPLÉTER : ce qui est fait concrètement].

**Tout ce qui manque** devient un passage [À COMPLÉTER : ce qu'il faut préciser, dit simplement], **surligné** (voir étape 5). Une section sans aucune information n'est pas supprimée : elle contient son titre et un [À COMPLÉTER] qui dit ce que l'artisan doit y écrire. Mieux vaut un mémoire à trous honnête qu'un mémoire complet et faux.

## Le prix

Le prix n'a pas sa place dans le mémoire : il est dans l'acte d'engagement et le bordereau de prix, remplis par l'artisan. Dans la trame, le critère « prix » est cité avec la mention « traité dans l'acte d'engagement, pas dans ce mémoire ». Si l'artisan vous donne un prix en répondant, ne l'écrivez pas dans le mémoire et rappelez-lui en une phrase que le prix reste de son côté.

## 1. Préparer

1. **Trouvez la consultation.** Si l'artisan n'a pas dit laquelle, regardez dans `suivi.md` celles qui sont `analysée` ou `en préparation` : s'il y en a une seule, prenez-la et dites laquelle ; s'il y en a plusieurs, demandez laquelle (une seule question).
2. **Ouvrez son sous-dossier** `consultations/AAAA-MM_acheteur_lot/`. S'il n'existe pas, ou s'il ne contient pas de DCE, il n'y a pas encore de critères : dites-le et proposez d'analyser le DCE d'abord ([analyse.md](analyse.md)). Ne rédigez pas de mémoire « générique ».
3. **Relevez les critères.** Source principale : la rubrique « Comment l'offre est notée » de `analyse.md`. Contrôlez-la en relisant l'article « critères » du règlement de consultation : dans `dce-texte/` si l'analyse en a extrait le texte, sinon dans `dce/` (voir [analyse.md](analyse.md) § 3 pour lire les PDF). Si les deux diffèrent, le RC fait foi. Notez pour chaque critère et sous-critère son intitulé exact, son poids ou ses points, et sa source (RC, article).
4. **Cherchez un cadre de l'acheteur** dans `dce/` (noms du type « cadre de mémoire », « cadre de réponse technique », « CRT », « modèle de mémoire », « mémoire technique » ; `.docx`, `.doc`, `.odt`, parfois `.xlsx`), et vérifiez dans le RC si son usage est obligatoire : [memoire-cadre-acheteur.md](memoire-cadre-acheteur.md) § 1. S'il y en a un, il donne la trame (étape 2) et sera rempli (étape 6).
5. **Sans fiche** (ou métiers et effectif encore [À COMPLÉTER]) : le mémoire reste possible, mais dites-le à l'artisan en une phrase et proposez de remplir la fiche ([fiche-entreprise.md](fiche-entreprise.md)). S'il préfère continuer, ce qui manque de la fiche devient [À COMPLÉTER].
6. **Y a-t-il déjà un mémoire ?** Si `memoire-technique.docx` (ou `.rtf`, ou `memoire-technique-cadre-acheteur.docx`) existe dans le sous-dossier, l'artisan l'a peut-être retouché : ne le remplacez jamais. Reprenez `memoire-reponses.md` pour le compléter, et enregistrez le nouveau fichier sous un autre nom (`memoire-technique-2.docx`).
7. **Dites ce qui va se passer**, en trois phrases : le mémoire est noté sur tels critères (donnez-les avec leur poids), vous allez poser quelques questions une par une (il peut répondre à la voix, « je ne sais pas » est une réponse), et il recevra un document Word à finaliser. S'il y a un cadre de l'acheteur, dites-le aussi (nom du fichier, obligatoire ou non) : c'est ce document que vous remplirez. Expliquez « mémoire technique » la première fois : le document où il explique comment il réalisera les travaux.

## 2. Construire la trame

**Avec un cadre de l'acheteur**, la trame est celle du cadre, exactement (rubriques, ordre, questions, limites) : suivez [memoire-cadre-acheteur.md](memoire-cadre-acheteur.md) § 2 au lieu de cette étape.

Sans cadre, la trame suit le règlement de consultation, pas un modèle type. Une section par critère noté sur le mémoire, dans l'ordre du RC, avec ses mots et ses sous-critères :

- tous les critères **autres que le prix** : la valeur technique, mais aussi, par exemple, l'engagement environnemental ou d'insertion, les délais, si le RC les note. Si le RC ne dit pas qu'un critère est jugé sur le mémoire, traitez-le quand même (il est noté) et signalez-le à l'artisan à la fin, pour qu'il le retire s'il veut ;
- les sous-critères deviennent des sous-titres, avec leurs points ;
- en tête : la consultation (objet, acheteur, lot, référence) tirée du RC, l'entreprise tirée de la fiche, et la liste des critères avec leur poids (« Comment ce mémoire répond aux critères ») ;
- une première section « Présentation de l'entreprise » **uniquement avec la fiche** : métiers, effectif (personnes, dont apprentis), certifications avec numéro et validité ;
- une dernière section « Références » avec les références de la fiche, telles quelles (année, acheteur ou client, travaux, commune, montant).

Le gabarit est [memoire-gabarit.html](memoire-gabarit.html).

**Réutilisez la fiche sans la recopier de mémoire** : relisez-la au moment d'écrire. Pour les références, mettez toutes celles de la fiche (ou, si le RC demande un nombre précis de références similaires, celles qui y ressemblent le plus, et dites-le), sans ajouter de qualificatif qu'elles n'ont pas (« bâtiment recevant du public », « chantier en site occupé », « dans les délais ») : si ce détail compte pour un critère, demandez-le à l'artisan. Les certifications de la fiche se citent avec leur numéro et leur date de validité. Le chiffre d'affaires, les justificatifs et les assurances n'ont pas leur place dans le mémoire, sauf si un critère le demande.

## 3. Poser les questions

Une question à la fois, courte, en mots simples ([ton.md](ton.md)). L'artisan peut répondre à la voix : si une réponse paraît mal transcrite, reformulez ce que vous avez compris et faites confirmer avant de l'enregistrer.

Choisissez les questions **d'après les critères relevés** (et, s'il y a un cadre de l'acheteur, d'après ses questions), pas d'après une liste fixe. Pour chaque sous-critère, une ou deux questions au plus, sur ce que ni la fiche ni le DCE ne disent. Les thèmes habituels, à rattacher au critère qui les note :

| Thème | Exemples de questions (à adapter au lot) |
|---|---|
| Équipe | Qui interviendra sur ce chantier ? Combien de personnes en même temps ? Qui dirige le chantier et sera l'interlocuteur de l'acheteur ? |
| Matériel | Quel matériel et quels véhicules utiliserez-vous pour ce chantier ? |
| Méthode | Dans quel ordre feriez-vous les travaux, de l'arrivée à la remise des clés ? Comment organisez-vous les essais et la réception ? |
| Déchets | Que faites-vous des déchets du chantier (tri, évacuation, où) ? |
| Sécurité et nuisances | Comment protégez-vous les lieux et les personnes (bruit, poussière, accès, site occupé) ? |
| Planning | Combien de temps pensez-vous pour les travaux, et comment les répartissez-vous ? |
| Insertion, environnement | Que faites-vous en matière d'environnement ou d'insertion ? (seulement si un critère le note) |

Règles :

- **Rappelez le contexte du DCE** quand cela aide l'artisan à répondre, avec sa source : « Le règlement demande une réponse sur la gestion des nuisances (10 points sur 50) ». Ne posez pas de question dont la réponse est déjà dans la fiche (effectif, certifications, références).
- **Ne soufflez pas la réponse.** Ne proposez pas de liste de matériels ou de méthodes à valider : il pourrait dire oui à ce qu'il ne fait pas. Vous pouvez donner un exemple du **type** de réponse attendue (« par exemple : le nombre de personnes, leur métier »), jamais un contenu inventé.
- **S'il répond à plusieurs questions d'un coup** (fréquent à la voix), enregistrez tout et passez à la première question encore sans réponse.
- **S'il ne sait pas ou veut remettre à plus tard**, n'insistez pas : le sujet restera [À COMPLÉTER] et vous passez à la suivante.
- **Enregistrez au fur et à mesure** dans `memoire-reponses.md` du sous-dossier de la consultation (si la conversation s'arrête, rien n'est perdu et il reprend où il en était) :

  ```markdown
  # Mémoire technique : ce que vous m'avez dit

  Dernière mise à jour : JJ/MM/AAAA

  ## [Intitulé du critère ou du sous-critère] ([poids])
  - [Question en quelques mots] : [sa réponse, dans ses mots]
  - [Question en quelques mots] : (pas encore de réponse)
  ```

  Si le fichier existe déjà, reprenez-le : ne reposez pas une question déjà répondue.
- **Il peut arrêter quand il veut** (« faites avec ce que vous avez ») : passez à l'étape 4 avec ce que vous avez. Il peut aussi demander le mémoire dès la première réponse.
- Après la dernière question, ne demandez rien de plus : annoncez que vous rédigez le mémoire.

## 4. Rédiger

Écrivez le mémoire en HTML dans un **dossier temporaire** (pas dans le dossier de travail), à partir du [gabarit](memoire-gabarit.html) : `memoire.html`. Le dossier temporaire se crée avec `mktemp -d` (Mac) ; sous Windows, avec le dossier `TEMP`.

- Suivez la trame de l'étape 2 et la règle anti-invention.
- Écrivez à la première personne du pluriel de l'entreprise (« Nous… ») **seulement** pour ce que l'artisan a dit ; sinon [À COMPLÉTER].
- Phrases simples, concrètes, sans grandes déclarations. L'acheteur note du contenu, pas du style.
- Le HTML n'utilise que le sous-ensemble du gabarit : `h1`-`h3`, `p`, `ul`, `li`, `strong`, `em`, `br` et le passage à compléter. Pas de tableau, pas de commentaire laissé.
- Relisez avant de convertir : chaque phrase sur l'entreprise a-t-elle une source (fiche ou réponse) ? Sinon, retirez-la ou remplacez-la par un [À COMPLÉTER].
- **Avec un cadre de l'acheteur**, écrivez aussi `reponses-cadre.txt` dans le même dossier temporaire, avec les mêmes phrases, rubrique par rubrique : [memoire-cadre-acheteur.md](memoire-cadre-acheteur.md) § 4.

## 5. Le passage à compléter

Chaque information manquante s'écrit exactement ainsi (le texte commence toujours par `[À COMPLÉTER`, le style est en ligne) :

```html
<span class="a-completer" style="background-color:#FFFF00; color:#C00000; font-weight:bold">[À COMPLÉTER : ce que l'artisan doit préciser]</span>
```

Ce balisage est ce que les conversions recherchent pour surligner : ne le modifiez pas, ne coupez pas un passage en deux, n'y mettez pas d'autre balise. La consigne après les deux-points dit simplement ce qu'il faut écrire (« le nombre de personnes sur le chantier et leur métier »), jamais un exemple de contenu inventé.

## 6. Produire le fichier

Suivant le système de l'artisan :

- **Mac** : suivez [memoire-production-mac.md](memoire-production-mac.md).
- **Windows** : suivez [memoire-production-windows.md](memoire-production-windows.md).

Le mémoire est enregistré dans le sous-dossier de la consultation (`consultations/AAAA-MM_acheteur_lot/`), à côté de l'analyse. Ne modifiez pas `suivi.md` : le statut de la consultation n'est pas changé par cette étape.

**Avec un cadre de l'acheteur**, produisez d'abord notre mémoire comme ci-dessus, puis remplissez le cadre (même fiche de production, section « Remplir le cadre de l'acheteur ») : `memoire-technique-cadre-acheteur.docx`, à côté. Si le remplissage échoue, notre mémoire suit déjà la structure du cadre : c'est la solution de secours ([memoire-cadre-acheteur.md](memoire-cadre-acheteur.md) § 5).

## 7. Rendre compte

Votre réponse, courte, dit dans cet ordre :

1. Le mémoire est prêt, avec son **chemin** (dossier de la consultation) et son format : un document Word à modifier, ou un fichier `.rtf` (une version plus simple, que Word et LibreOffice ouvrent aussi) si la conversion en Word a échoué. **Avec un cadre de l'acheteur** : le cadre rempli (`memoire-technique-cadre-acheteur.docx`) est le document à déposer, notre mémoire est un brouillon de travail ; rappelez les limites du cadre (pages, caractères) et, si le format a été converti ou si le remplissage a échoué, ce qu'il doit faire (§ 5 de memoire-cadre-acheteur.md).
2. **Ce qu'il reste à compléter** : le nombre de passages [À COMPLÉTER] et la liste de ce qui manque, en une ligne chacun (« équipe : nombre de personnes… »). Ils sont surlignés en jaune : l'artisan les repère d'un coup d'œil.
3. Ce qui vient de sa fiche et de ses réponses, et rien d'autre : une phrase suffit.
4. Un rappel : relire le mémoire en entier avant de le déposer (il l'engage), et que **le prix** se remplit à part, dans l'acte d'engagement et le bordereau, par lui. S'il manque une certification exigée par le DCE (analyse), le rappeler en une phrase.
5. Une question pour la suite : par exemple, « Voulez-vous que nous reprenions un des points à compléter maintenant ? ».

Ne dites pas que le fichier « s'ouvre sans problème dans Word » : vous ne l'avez pas vérifié dans Word ; dites que vous l'avez contrôlé et que l'artisan peut l'ouvrir avec Word ou LibreOffice, et qu'il vous prévienne si quelque chose s'affiche mal.

## Reprise plus tard

Si l'artisan revient avec de nouvelles informations (« j'ai le matériel »), mettez à jour `memoire-reponses.md`, régénérez le HTML complet à partir de la trame et des réponses (et `reponses-cadre.txt` s'il y a un cadre de l'acheteur), et produisez un nouveau fichier sous un autre nom, sans écraser l'ancien.
