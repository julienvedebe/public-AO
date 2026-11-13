# Analyse d'un DCE

Cette étape transforme un DCE (le dossier de la consultation, avec tous les documents de l'acheteur) en un avis que l'artisan peut lire en deux minutes (le verdict : dossier favorable, points de vigilance, ou dossier défavorable), puis le laisse décider s'il répond. **C'est toujours l'artisan qui décide** : vous éclairez, vous ne tranchez pas. Lisez d'abord [dossier-de-travail.md](dossier-de-travail.md) et la fiche entreprise de l'artisan (`ma-fiche-entreprise.md`). Sans fiche, ou si les métiers sont encore [À COMPLÉTER], proposez de la remplir d'abord ([fiche-entreprise.md](fiche-entreprise.md)).

## Ce que vous ne faites jamais ici

- **Télécharger le DCE à la place de l'artisan**, ni vous connecter à la plateforme de l'acheteur. S'il n'a pas le DCE, dites-lui où cliquer : sur la page de la consultation de la plateforme de l'acheteur, bouton « Télécharger le dossier de consultation » (souvent sans compte, parfois avec un compte gratuit à créer par lui). Il le dépose ensuite dans son dossier de travail ou vous donne son chemin.
- **Chiffrer, proposer ou commenter un prix.** Vous pouvez dire comment le prix est noté, pas combien l'artisan doit demander.
- **Inventer** une date, une exigence, un article ou une page. Ce que vous ne trouvez pas dans les documents est écrit « non trouvé dans le dossier ».

## 1. Récupérer le DCE

1. Trouvez ce que l'artisan a déposé : un ZIP ou des fichiers, dans le dossier de travail (souvent à sa racine, ou dans Téléchargements s'il l'indique). S'il dit « le DCE » sans préciser, cherchez dans le dossier de travail les `.zip` et les PDF qui ne sont pas encore rangés dans `consultations/`. S'il y en a plusieurs, listez-les et demandez lequel (une seule question).
2. Déterminez l'acheteur, la date limite de remise et le lot, d'après le suivi (`suivi.md`) ou, à défaut, d'après le règlement de consultation (après l'étape 2).
3. Créez le sous-dossier `consultations/AAAA-MM_acheteur_lot/` ([dossier-de-travail.md](dossier-de-travail.md) : minuscules, sans accents ni espaces ; AAAA-MM est le mois de la date limite de remise). Si la date limite n'est pas encore connue, créez-le après avoir lu le règlement. Si le sous-dossier existe déjà, réutilisez-le.
4. **Copiez** le ZIP dans ce sous-dossier, puis décompressez la copie dans `dce/` (`consultations/…/dce/`). Ne déplacez et ne supprimez pas l'original déposé par l'artisan. Ne remplacez jamais un fichier existant.
   - Mac : `unzip -n fichier.zip -d dce` (l'option `-n` n'écrase rien) ou `ditto -x -k fichier.zip dce`.
   - Windows : PowerShell `Expand-Archive -Path fichier.zip -DestinationPath dce`.
   - Si l'artisan a déposé des fichiers séparés plutôt qu'un ZIP, copiez-les dans `dce/`.
   - Un ZIP dans un ZIP : décompressez aussi le second.
   - Un ZIP protégé par un mot de passe ou illisible : dites-le simplement et demandez-lui de le télécharger à nouveau.

## 2. Inventorier les pièces

Listez tous les fichiers de `dce/` et classez-les, avec un mot d'explication la première fois :

| Pièce | Ce que c'est |
|---|---|
| RC | règlement de la consultation : les règles du jeu (dates, critères, pièces à fournir) |
| CCAP | cahier des clauses administratives particulières : les règles du contrat (paiement, pénalités, délais) |
| CCTP | cahier des clauses techniques particulières : ce qu'il faut faire, lot par lot |
| AE | acte d'engagement : le document que l'artisan signe avec son prix |
| BPU / DPGF / DQE | bordereaux de prix : les listes de prix à remplir |
| Plans, notes de calcul, diagnostics (amiante, plomb), PGC | informations sur le chantier |
| DC1, DC2, DUME | formulaires de candidature |

Notez les pièces absentes ou illisibles. Rendez l'inventaire avec le nombre de documents, pas la liste complète (elle va dans le fichier d'analyse).

## 3. Lire les documents

Un DCE compte souvent plus de cent fichiers. **Ne lisez que les pièces utiles**, dans cet ordre : le RC en entier (dates, critères, pièces), le CCAP (pénalités, paiement), le CCTP du lot de l'artisan, puis au besoin le planning, la notice de chantier et les questions-réponses de l'acheteur. Ne lisez ni les plans, ni les bordereaux de prix, ni les lots d'autres métiers.

**Extrayez le texte de ces pièces une seule fois**, dans le sous-dossier `dce-texte/` de la consultation (un `.txt` par pièce, du même nom que le PDF). Les étapes suivantes (pièces, mémoire) le relisent au lieu de rouvrir les PDF. Méthodes, de la plus rapide à la plus lente :

1. **`pdftotext`, s'il est présent.** Il extrait un PDF de cent pages en une seconde, et sépare les pages par un saut de page (caractère « form feed »), ce qui donne le numéro de page de chaque information.
   - **Windows** : il est fourni avec Git pour Windows, souvent installé avec Claude Code. Cherchez-le :
     `$pt = (Get-Command pdftotext.exe -ErrorAction SilentlyContinue).Source; if (-not $pt) { $pt = @("$env:ProgramFiles\Git\mingw64\bin\pdftotext.exe", "$env:LOCALAPPDATA\Programs\Git\mingw64\bin\pdftotext.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1 }`
     puis, s'il est trouvé : `& $pt -layout -enc UTF-8 "CHEMIN.pdf" "SORTIE.txt"`.
   - **Mac** : `pdftotext` n'est pas fourni avec le Mac ; utilisez-le seulement s'il répond (`command -v pdftotext`).
2. **Mac, sans rien installer** : PDFKit, fourni avec le Mac :
   `osascript -l JavaScript -e 'ObjC.import("PDFKit"); var d=$.PDFDocument.alloc.initWithURL($.NSURL.fileURLWithPath("CHEMIN.pdf")); ObjC.unwrap(d.string)'`
   Pour le numéro d'une page, lisez `d.pageAtIndex(n).string` page par page (`d.pageCount` donne le nombre).
3. **Votre outil de lecture de fichiers**, par **tranches de pages** (par exemple 20 pages à la fois) : un long PDF lu d'un seul coup échoue souvent.
4. **PDF scanné** (image sans texte, ou texte extrait vide) : lisez-le comme image si votre outil le permet. Sinon, dites à l'artisan quelle pièce n'est pas lisible et ce que vous n'avez donc pas pu vérifier. N'en tirez aucune conclusion.

**N'ouvrez jamais un PDF avec Word** : la conversion est très lente et Word peut se bloquer sans rien dire. Les autres formats : Word, RTF ou OpenDocument se convertissent avec `textutil -convert txt` sur Mac ; sous Windows, un `.docx` est un ZIP dont le texte est dans `word/document.xml`. Un ancien `.doc` sous Windows ne s'ouvre avec Word qu'en dernier recours : si Word ne répond pas au bout d'une minute, arrêtez-le et signalez la pièce comme illisible.

**Retenez la source de chaque information en lisant** : nom du document, numéro d'article, numéro de page.

## 4. Isoler le lot de l'artisan

1. Prenez les métiers de la fiche et cherchez dans le RC (article « allotissement » ou « lots ») le ou les lots qui correspondent (plombier : « plomberie », « sanitaires », « CVC » s'il fait aussi le chauffage).
2. Si plusieurs lots lui conviennent, ou si le lot est regroupé avec d'autres métiers, dites-le et demandez lequel il vise (une question).
3. Si **aucun lot** ne correspond à ses métiers, dites-le (« je ne trouve pas de lot pour votre métier dans cette consultation »), donnez le verdict 🔴 et proposez le choix de la fin (étape 6) sans analyser plus loin.
4. Retrouvez le CCTP de ce lot et l'estimation de l'acheteur s'il y en a une.

**Lot trop gros.** Si l'estimation du lot dépasse le maximum de « Lots qui m'intéressent » dans la fiche, ou si le lot exige des moyens ou un chiffre d'affaires qu'il n'a pas, ne lui dites pas de renoncer. Expliquez en quelques phrases :

- **Le groupement momentané d'entreprises** (GME, aussi appelé cotraitance) : plusieurs entreprises répondent ensemble, chacune pour sa part des travaux, avec un mandataire (le chef de file) qui dépose l'offre. Les capacités (chiffre d'affaires, références) peuvent s'additionner. Cela suppose de trouver un partenaire.
- **La sous-traitance** : l'artisan répond seul au lot, mais confie une partie des travaux à une entreprise qu'il paie lui-même. Elle doit être acceptée par l'acheteur ; elle est autorisée ou non selon le CCAP (citez l'article). L'artisan reste responsable envers l'acheteur de l'ensemble.
- Pour un lot trop gros d'un facteur modeste, la sous-traitance est souvent plus simple ; pour un lot très gros ou qui demande une qualification qu'il n'a pas, le groupement est plus adapté.

Montrez ce conseil **dans l'analyse**. Tant que l'artisan n'a pas de partenaire, le verdict est au mieux 🟠.

## 5. Produire l'analyse

Rédigez le fichier `analyse.md` dans le sous-dossier de la consultation. Il doit rester lisible par l'artisan, sans jargon non expliqué. Plan à suivre :

```markdown
# Analyse : [objet], [acheteur], lot [n°] [intitulé]

Analyse faite le JJ/MM/AAAA.

## Verdict
🟢 Dossier favorable, ou 🟠 Points de vigilance, ou 🔴 Dossier défavorable : [une phrase qui résume les éléments décisifs]
- [3 à 5 éléments, favorables ou défavorables, chacun avec sa source]

C'est un avis : vous décidez de répondre ou non.

## Dates à retenir
| Quoi | Date | Source |
|---|---|---|
| Visite du site (obligatoire ou non) | … | RC, article 5, p. 2 |
| Dernier jour pour poser une question | … | … |
| Remise des offres | … | … |
| Démarrage des travaux et délai | … | … |

## Visite obligatoire
[oui/non, quand, où, ce qu'on y remet, conséquence d'une absence, source]

## Comment l'offre est notée
| Critère | Poids | Source |
|---|---|---|
(la formule de notation du prix si elle est donnée)

## Ce qui est exigé, comparé à votre fiche
| Exigence | Source | Votre fiche | Résultat |
|---|---|---|---|
(résultat : ✅ rempli, ❌ manquant, ❓ à vérifier)

## Pièges
(pénalités, délais, retenue de garantie, variantes interdites, révision de prix, avance, sous-traitance, période de travaux…, chacun avec sa source et pourquoi cela compte pour lui)

## Le lot et les pièces du dossier
(lot retenu, travaux principaux en 3-5 lignes, estimation de l'acheteur, liste des pièces trouvées, pièces absentes ou illisibles)

## Si le lot est trop gros
(uniquement dans ce cas : groupement et sous-traitance)

## À vérifier avant de vous lancer
Les dates ci-dessus viennent des documents que vous m'avez donnés. Vérifiez-les sur la plateforme de l'acheteur avant de vous organiser : l'acheteur peut les avoir changées par un avis rectificatif.
```

### Règles de fond

- **Une source pour chaque date et chaque exigence** : `RC, article 7, p. 2`. Si le numéro de page n'est pas fiable, citez le document et l'article. Ne mettez jamais une date sans source.
- **Dates** : écrivez-les en toutes lettres avec le jour de la semaine et l'heure (« vendredi 15 janvier 2027 à 12 h »). Si deux documents se contredisent, signalez-le, donnez les deux sources et dites que la plateforme fait foi.
- **Visite** : « non obligatoire » ne se conclut que si le document le dit ; sinon écrivez « non mentionnée ». Si la date de visite est passée, dites-le et que l'offre est probablement perdue d'avance.
- **Exigences à confronter à la fiche** : certifications et qualifications (Qualibat, Qualifelec, Qualigaz, RGE…), assurances (responsabilité civile, décennale, montants minimums), chiffre d'affaires minimum, nombre et type de références, effectif, justificatifs en cours de validité à la date de remise (comparez avec les dates de la rubrique « Justificatifs » de la fiche : un document qui sera périmé à la date de remise est à renouveler). Une exigence que la fiche ne permet pas de vérifier est ❓, pas ✅. Une exigence « ou équivalent » est ❓ tant que l'artisan ne dit pas s'il a un équivalent.
- **Critères** : tous les critères et sous-critères avec leur poids ; le total doit faire 100 %, sinon signalez-le.
- **Pièges à chercher systématiquement** : pénalités de retard (montant par jour, plafond ou non), pénalités d'absence aux réunions, retenue de garantie, avance, délai de paiement, prix fermes ou révisables, variantes interdites ou obligatoires, options, période de travaux imposée (vacances scolaires…), délai court, coordination avec les autres lots, intervention en site occupé, clauses d'insertion ou environnementales, sous-traitance, validité de l'offre, obligations de visite, négociation possible, remise par voie électronique seulement.

### Le verdict

Le verdict est un **avis**, pas une décision. Choisissez **un seul** des trois, jamais deux, et donnez-le d'abord avec les éléments qui le motivent :

- 🟢 **Dossier favorable** : le lot correspond au métier, les montants sont dans la fourchette de la fiche, toutes les exigences vérifiables sont remplies, les dates sont tenables, aucun piège lourd.
- 🟠 **Points de vigilance** : une exigence manque ou n'est pas vérifiable (certification, assurance, référence), le lot dépasse la fourchette, un piège pèse lourd (pénalités élevées, délais très serrés), ou une visite obligatoire est proche. Dites précisément ce qu'il faudrait régler et si cela paraît faisable avant la remise (délai d'obtention d'une certification, partenaire pour un groupement).
- 🔴 **Dossier défavorable** : des éléments pèsent fortement contre une réponse, par exemple aucun lot pour son métier, une exigence éliminatoire difficile à remplir à temps, une visite obligatoire déjà passée, une date limite dépassée, un lot sans rapport avec sa zone ou sa taille.

Un verdict argumenté, c'est trois à cinq éléments sourcés, pas un chiffre. **N'écrivez jamais à sa place** « passez votre tour », « laissez tomber », « n'y allez pas » ou « on y va » : décrivez ce qui est favorable ou défavorable, et laissez-le choisir. Ne dites pas qu'il va gagner ou perdre. Même en 🔴, s'il veut répondre, c'est son droit : l'outil l'accompagne.

## 6. Rendre compte et mettre à jour le suivi

1. Enregistrez `analyse.md` **avant** de répondre.
2. Mettez à jour `suivi.md` : dans la ligne de la consultation, mettez le statut `analysée` et le verdict (🟢, 🟠 ou 🔴), ajoutez la date limite si elle manquait, et une courte note (par exemple « visite obligatoire 08/12 »). S'il n'y a pas de ligne pour cette consultation, ajoutez-la. Ne touchez pas aux autres lignes.
3. Répondez à l'artisan : le verdict et sa phrase de conclusion d'abord, puis un résumé **en 5 lignes** (le verdict, la date de remise, la visite, la principale exigence ou le principal piège, ce qu'il doit faire maintenant), puis, **si le lot est trop gros**, deux ou trois phrases qui nomment et expliquent le groupement momentané d'entreprises et la sous-traitance (le détail est dans l'analyse), puis où se trouve l'analyse complète (donnez le chemin du dossier de la consultation). Terminez la réponse par le rappel de vérifier les dates sur la plateforme de l'acheteur.
4. **Laissez-le choisir**, en une seule question : « Que voulez-vous faire pour cette consultation ? », avec ces choix (à cliquer si possible, sinon numérotés, voir [ton.md](ton.md)) :
   - **Répondre** : passez à la préparation des pièces ([dossier.md](dossier.md)), sans lui redemander s'il en est sûr ;
   - **Décliner** : mettez le statut `déclinée` dans la ligne du suivi, gardez le verdict, notez sa raison s'il en donne une, puis proposez de chercher d'autres consultations ;
   - selon le cas, un troisième choix utile : **Poser d'abord une question à l'acheteur** (s'il reste un doute que l'acheteur peut lever avant la date limite des questions) ou **Chercher un partenaire** (groupement ou sous-traitance, quand le lot dépasse son métier ou sa taille) ;
   - il peut aussi dire « je réfléchis » : laissez le statut `analysée`, rien d'autre.

N'écrivez aucun prix, ni dans l'analyse, ni dans votre réponse, sauf pour citer ceux du dossier (estimation de l'acheteur, montants de pénalités).
