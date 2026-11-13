# Pièces à fournir et rétroplanning

Cette étape part d'une consultation déjà analysée et de la décision de l'artisan d'y répondre. Elle produit trois choses : la liste des pièces à fournir (ce qu'il a déjà, ce qui manque), un calendrier à rebours depuis la date limite de remise, et les informations de sa fiche prêtes à recopier dans les formulaires de candidature. Lisez d'abord [dossier-de-travail.md](dossier-de-travail.md) et la fiche entreprise (`ma-fiche-entreprise.md`).

## Ce que vous ne faites jamais ici

- **Fixer, proposer ou commenter un prix.** Le prix (BPU, DPGF, DQE, montant de l'acte d'engagement) reste à l'artisan (ADR 0002). Vous pouvez dire où il se remplit, pas combien.
- **Remplir, cocher ou signer à sa place** une déclaration sur l'honneur, un acte d'engagement ou une attestation : cela l'engage. Vous préparez les valeurs, il remplit et signe.
- **Vous connecter à la plateforme de l'acheteur, aux sites de l'URSSAF ou des impôts, ni déposer l'offre.** Dites-lui où cliquer.
- **Inventer** une information sur l'entreprise ou une exigence : ce que la fiche ne donne pas reste [À COMPLÉTER], ce que le dossier ne dit pas est « non trouvé dans le dossier ».

## 1. Choisir la consultation

1. Repérez la consultation dans `suivi.md` et son sous-dossier dans `consultations/`. Si l'artisan dit « Val-de-Brelle » ou « le lot de la mairie », rapprochez-le du suivi. S'il y en a plusieurs possibles, listez-les et posez une seule question.
2. **Pas encore analysée** (statut `repérée`, pas de fichier d'analyse) : ne préparez rien. Dites-lui en une phrase qu'il faut d'abord analyser le dossier de consultation, puis proposez de le faire ([analyse.md](analyse.md)). Ne changez pas le statut.
3. **Verdict 🔴** : rappelez en une phrase pourquoi l'analyse disait de passer son tour et demandez s'il veut quand même répondre. Continuez seulement s'il confirme.
4. **Pas de fiche** ou métiers encore [À COMPLÉTER] : proposez de la remplir d'abord ([fiche-entreprise.md](fiche-entreprise.md)). Une fiche à moitié remplie suffit : ce qui manque sera [À COMPLÉTER] dans les formulaires.
5. Lisez le fichier d'analyse du sous-dossier (verdict, dates, exigences) et le règlement de consultation (RC) dans `dce/` (son texte est déjà extrait dans `dce-texte/` s'il existe : lisez-le plutôt que le PDF), surtout l'article sur le contenu de la candidature et de l'offre. Ne vous fiez pas à l'analyse seule pour la liste des pièces : le RC fait foi. Si l'analyse a été faite par une version plus ancienne et que vous ne retrouvez pas une date, relisez le RC.

La date limite de remise (avec l'heure) vient du RC. Elle est dans l'analyse, sourcée. Si vous ne la trouvez pas, demandez-la : il n'y a pas de rétroplanning sans elle.

## 2. Dresser la liste des pièces

Lisez dans le RC et l'acte d'engagement tout ce que l'artisan doit remettre, **candidature** (qui est l'artisan) et **offre** (ce qu'il propose). Notez la source de chaque pièce (document, article, page) comme dans l'analyse. Les pièces habituelles :

| Pièce | Ce que c'est (à expliquer à la première occurrence) |
|---|---|
| Formulaire de candidature (DC1, DC2, DUME) | déclaration de l'entreprise : identité, déclarations sur l'honneur, capacités (voir § 5) |
| Extrait Kbis | la carte d'identité de l'entreprise ; l'acheteur demande souvent « de moins de 3 mois » |
| Attestation de vigilance URSSAF | prouve que l'entreprise est à jour de ses cotisations sociales |
| Attestation de régularité fiscale | prouve que l'entreprise est à jour de ses impôts |
| Assurances | attestations de responsabilité civile professionnelle et de garantie décennale |
| Qualifications et certifications | Qualibat, Qualifelec, Qualigaz, RGE… selon le lot |
| Références de travaux | liste de chantiers similaires, avec la durée demandée (souvent moins de 5 ans) |
| Attestation de visite | remise sur place si la visite est obligatoire ; à joindre à l'offre |
| Acte d'engagement (AE) | le contrat que l'artisan signe, avec son prix |
| Prix : BPU, DPGF, DQE | les listes de prix à remplir (voir § 6) |
| Mémoire technique | comment il fera le chantier, noté dans les critères (étape « mémoire technique ») |
| Autres | ce que le RC ajoute : justification des critères d'insertion ou d'environnement, déclaration de sous-traitance (DC4), pouvoir du signataire… |

N'ajoutez que ce que le RC demande, sans oublier ce qu'il demande en plus. Une pièce que le RC annonce sans dire comment la justifier est « à demander à l'acheteur » (question à poser avant la date limite des questions).

**Pièces que l'acheteur peut obtenir lui-même.** Le code de la commande publique (articles R2143-13 et R2143-14) dit que l'artisan n'a pas à fournir un document que l'acheteur peut récupérer gratuitement sur un système officiel, ou qu'il a déjà reçu d'une consultation précédente, si le RC l'indique. S'il le dit, indiquez que la pièce n'est pas à joindre. Sinon, elle se joint.

## 3. Comparer avec ce que l'artisan a déjà

Pour chaque pièce, regardez la fiche (rubriques Justificatifs, Certifications, Assurances, Références, Chiffre d'affaires, Effectif) et le dossier `mes-justificatifs/` (les fichiers nommés dans la colonne « Fichier » de la fiche, et ceux que vous y trouvez). Classez :

- ✅ **Prêt** : présent, en cours de validité à la date limite de remise, fichier dans `mes-justificatifs/` (ou, pour une certification, date de fin de validité postérieure à la date limite).
- ⚠️ **À renouveler** : présent mais périmé, ou qui expire avant la date limite de remise (voir § 4).
- ❌ **Manquant** : ni dans la fiche ni dans `mes-justificatifs/`, ou exigé et absent de la fiche (par exemple une qualification que l'analyse a signalée ❌).
- ❓ **À confirmer** : la fiche ne permet pas de trancher (références « similaires », équivalence d'une qualification…). Posez la question à l'artisan, ne devinez pas.
- ✍️ **À remplir par l'artisan** : formulaires, acte d'engagement, prix, mémoire technique, déclarations sur l'honneur.

Un justificatif de la fiche dont le fichier n'est pas dans `mes-justificatifs/` : dites-le, c'est une pièce à glisser dans ce dossier avant le dépôt.

## 4. Alerter sur les justificatifs

Comparez **à la date limite de remise** (pas à aujourd'hui) la date « Valable jusqu'au » de chaque justificatif :

- **Déjà périmé aujourd'hui** : alerte « périmé depuis le JJ/MM/AAAA ».
- **Valable aujourd'hui mais périmé avant la date limite** : alerte « expire le JJ/MM/AAAA, avant la date limite du JJ/MM/AAAA ». C'est le cas le plus fréquent et le plus piégeux : la pièce a l'air bonne maintenant.
- **Kbis « de moins de 3 mois »** : comptez 3 mois à partir de sa date de délivrance. Si ce délai se termine avant la date limite, ou à quelques jours près, à renouveler.
- **Valable un mois ou moins après la date limite** : mentionnez-le sans alerte (l'acheteur peut demander les pièces à l'attribution, quelques semaines plus tard).
- Sans date de fin de validité dans la fiche : ❓, demandez-la.

Pour chaque alerte, dites en une phrase comment le renouveler, sans le faire à sa place. Les mots exacts des menus changent d'un site à l'autre, donnez la piste et pas un chemin précis :

- **Attestation de vigilance URSSAF** : se télécharge depuis son espace en ligne sur urssaf.fr (compte de l'entreprise). Elle est valable 6 mois.
- **Attestation de régularité fiscale** : se demande depuis l'espace professionnel de l'entreprise sur impots.gouv.fr. Prévoyez quelques jours si elle n'arrive pas tout de suite.
- **Extrait Kbis** : se commande auprès du greffe du tribunal de commerce ou sur le site officiel des greffes ; un artisan inscrit au répertoire des métiers demande l'extrait D1 à sa chambre de métiers.
- **Assurances** : une attestation à jour se demande à l'assureur (courtier ou agence), en précisant le chantier.

Si aucun renouvellement ne peut se faire avant la date limite (rare), dites-le simplement : le dossier serait incomplet.

## 5. Les formulaires de candidature

**Source officielle et état vérifié le 13/11/2026.**

| Formulaire | À quoi il sert | État à la vérification |
|---|---|---|
| **DC1** | lettre de candidature : identifie l'entreprise, indique le groupement s'il y en a un, porte les déclarations sur l'honneur | toujours publié par la direction des affaires juridiques (DAJ) du ministère de l'Économie, sur economie.gouv.fr/daj, rubrique « Les formulaires de déclaration du candidat ». Le fichier proposé est le modèle 2019 (Word), avec une notice explicative |
| **DC2** | déclaration du candidat : capacités (chiffre d'affaires, effectif, références, qualifications) | même page. Modèle Word, notice explicative du 20/10/2023 |
| **DC4** | déclaration de sous-traitance (seulement si l'artisan sous-traite une part des travaux) | même page. Version applicable à partir du 01/01/2024, notice mise à jour le 22/11/2023 |
| **DUME** | document unique de marché européen : une déclaration sur l'honneur qui peut remplacer DC1 et DC2 | service national de l'AIFE (Chorus Pro), utilitaire gratuit : dume.chorus-pro.gouv.fr. Un acheteur est obligé d'accepter un DUME envoyé par voie électronique, quel que soit le montant (article R2143-4 du code de la commande publique, d'après la page DAJ « Document unique de marché européen »). Seul le DUME au format XML a valeur probante. Il peut être réutilisé d'une consultation à l'autre |

Sources : economie.gouv.fr/daj/les-formulaires-de-declaration-du-candidat et economie.gouv.fr/daj/document-unique-de-marche-europeen-dume, relues le 13/11/2026 ; page d'accueil dume.chorus-pro.gouv.fr consultée le même jour. Les articles du code (R2143-3, R2143-4, R2143-13, R2143-14) n'ont pas pu être relus sur Légifrance (accès automatique refusé) : leur contenu vient de la page DAJ et d'un résumé de marche-public.fr. Aucun des sites officiels ne mentionne la suppression des DC1 et DC2, ni une nouvelle version après celles-ci. À revérifier avant chaque session de formation.

Ce que cela veut dire en pratique :

- **Le RC décide.** Dites quels formulaires il demande (par exemple « DC1 ou DUME », « DC1 et DC2 »). Ne demandez pas un DC2 qu'il ne cite pas. Il n'y a pas d'obligation générale d'utiliser DC1 et DC2 : un acheteur peut aussi accepter une déclaration libre ou un DUME.
- **« DC1 ou DUME »** : les deux conviennent. Expliquez-le en deux phrases : le DC1 (et le DC2) se remplit comme un document Word, sans compte ; le DUME se remplit en ligne et s'enregistre en fichier, à réutiliser ensuite. Ne tranchez pas à sa place sauf s'il demande conseil : pour une première réponse, le DC1 (et le DC2) est plus simple, sans compte à créer.
- **Où les trouver** : donnez l'adresse du site de la DAJ ou du service DUME. Vous ne les téléchargez pas à sa place et vous ne modifiez pas le fichier officiel. Beaucoup de plateformes d'acheteur proposent aussi le DUME dans le dépôt.
- **Les valeurs préremplies** : enregistrez dans le fichier du dossier un tableau « champ du formulaire, valeur de votre fiche », que l'artisan recopie. Reprenez la fiche telle quelle, sans reformuler les chiffres :

| Rubrique du formulaire | Valeur (source : fiche) |
|---|---|
| Nom ou dénomination de l'entreprise | fiche : Nom |
| Numéro SIRET | fiche : SIRET |
| Adresse, téléphone, e-mail | fiche : Adresse, Téléphone, E-mail |
| Forme juridique, numéro de TVA, nom et fonction du signataire | [À COMPLÉTER] (pas dans la fiche) |
| Chiffre d'affaires hors taxes des 3 derniers exercices | fiche : Chiffre d'affaires |
| Effectif (dont apprentis) | fiche : Effectif |
| Qualifications et certifications | fiche : Certifications (avec numéros et dates) |
| Références de travaux | fiche : Références (celles que l'artisan confirme comme similaires) |
| Assurances | fiche : Assurances (assureur, date de fin) |
| Objet de la consultation, acheteur, lot | analyse : titre de l'analyse |
| Déclarations sur l'honneur (pas d'exclusion, emploi de travailleurs handicapés…) | **à cocher et signer par l'artisan lui-même**, sans préremplissage |

  Une donnée absente de la fiche s'écrit [À COMPLÉTER], jamais une valeur approximative. Si l'artisan répond à une question de votre part (par exemple le nom du signataire), vous pouvez l'ajouter au tableau, mais ne modifiez pas la fiche sans qu'il le demande.
- **Groupement ou sous-traitance** : si l'analyse a conclu que le lot est trop gros et que l'artisan s'oriente vers l'un des deux, ajoutez à la liste le formulaire correspondant (DC1 avec mandataire pour un groupement, DC4 pour un sous-traitant) et les pièces de chaque entreprise. Sinon, n'en parlez pas.

## 6. Le prix reste à l'artisan

Dites-le clairement, dans le fichier et dans votre réponse :

- Les documents de prix (BPU : bordereau de prix unitaires ; DPGF : décomposition du prix global et forfaitaire ; DQE : détail quantitatif estimatif) et le montant de l'acte d'engagement **sont à remplir par l'artisan**. Vous n'y mettez aucun chiffre et vous ne donnez pas de fourchette.
- Nommez ceux que le dossier contient (cherchez dans `dce/` ; ils sont souvent en tableur). Si le dossier n'en contient aucun, dites « aucun bordereau de prix trouvé dans le dossier : vérifiez sur la plateforme s'il y en a un à télécharger séparément ».
- Rappelez comment le prix est noté, d'après l'analyse (poids du critère, formule), sans conseiller de montant.
- Le prix est ferme ou révisable, la durée de validité de l'offre, les pénalités : renvoyez à l'analyse sans commenter le chiffrage.

## 7. Le rétroplanning

Calculez les dates à rebours depuis la **date limite de remise**, avec l'heure. N'estimez pas les dates de tête : calculez-les avec la commande de date du système (Mac : `date -j -v-7d -f %Y-%m-%d 2027-01-15 "+%A %d %B %Y"` ; Windows PowerShell : `(Get-Date '2027-01-15').AddDays(-7).ToString('dddd d MMMM yyyy', [cultureinfo]'fr-FR')`) pour obtenir le bon jour de la semaine. Écrivez les dates en toutes lettres avec le jour de la semaine (« vendredi 15 janvier 2027 à 12 h »).

**Les dates qui sont fixées par l'acheteur** viennent de l'analyse, sourcées : visite, dernière question, réponses de l'acheteur, remise. Ne les déplacez pas.

**Les dates que vous proposez**, par défaut, en jours avant la date limite (D) :

| Étape | Date proposée | Pourquoi |
|---|---|---|
| Renouveler les justificatifs périmés ou qui expirent avant D | au plus tôt, dans la semaine qui suit aujourd'hui (au plus tard D − 14 jours) | les attestations et le Kbis ne sont pas toujours délivrés le jour même |
| Visite du site | date fixée par l'acheteur | une offre sans attestation de visite est écartée si c'est obligatoire |
| Poser ses questions | 3 jours ouvrés avant la dernière date de questions | l'acheteur répond après, et ses réponses peuvent changer l'offre |
| Mémoire technique : première version | D − 12 jours | il compte pour la note ; les réponses aux questions arrivent avant la fin |
| Formulaires de candidature remplis | D − 8 jours | la relecture des déclarations prend du temps |
| Prix rempli (BPU, DPGF, DQE, acte d'engagement) | D − 5 jours ouvrés, puis relecture à D − 3 | c'est la partie qui ne se refait pas à la dernière minute |
| Assemblage du dossier et signature | D − 2 jours ouvrés | s'il faut une signature électronique, certaines plateformes demandent un certificat qui prend du temps à obtenir ; le RC dit si elle est exigée à la remise |
| **Dépôt sur la plateforme** | **au moins 24 heures avant la limite** (jamais dans la dernière heure) | l'envoi de gros fichiers est lent, et les plateformes sont saturées au dernier moment. Un dépôt peut être remplacé par un nouveau avant l'heure limite |
| **Date limite de remise** | D, à l'heure du RC | le dépôt hors délai est refusé |

Règles :

1. Les dates proposées tombent un jour ouvré (pas de week-end ni de jour férié, par exemple le 1er janvier ou Noël) ; décalez au jour ouvré précédent.
2. Comparez chaque date à **aujourd'hui**. Une date déjà passée ou trop proche est **à signaler** : dites que l'étape est à faire tout de suite, et raccourcissez les suivantes sans rien supprimer. Si le calendrier n'est pas tenable (par exemple la visite obligatoire est déjà passée, ou il reste moins de 5 jours ouvrés), dites-le en conclusion d'abord et proposez de laisser tomber ou de demander à l'acheteur.
3. Ajoutez une ligne « Aujourd'hui » pour situer l'artisan.
4. Gardez 8 à 10 lignes. Une ligne par étape, avec une case à cocher `[ ]`.
5. Ne datez rien après la date limite.

## 8. Enregistrer et mettre à jour le suivi

1. Rédigez le fichier `pieces-et-retroplanning.md` dans le sous-dossier de la consultation, avant de répondre. Ne le nommez pas autrement : l'étape suivante (mémoire technique) et l'artisan le retrouveront. S'il existe déjà, relisez-le et mettez-le à jour sans effacer ce que l'artisan y a coché. Plan à suivre, avec ces titres :

```markdown
# Dossier de réponse : [objet], [acheteur], lot [n°] [intitulé]

Préparé le JJ/MM/AAAA. Date limite de remise : [jour JJ mois AAAA à HH h] (source).

## En bref
- [3 à 5 lignes : ce qui est prêt, ce qui manque, les alertes, le prochain geste]

## Ce que vous avez déjà
| Pièce | Source (exigence) | Votre dossier | État |
|---|---|---|---|
(✅ prêtes uniquement)

## Ce qui manque ou est à renouveler
| Pièce | Source (exigence) | Pourquoi | Que faire |
|---|---|---|---|
(⚠️ à renouveler, ❌ manquantes, ❓ à confirmer, ✍️ à remplir par vous)

## Alertes sur vos justificatifs
- [Justificatif : date de fin de validité, date limite de remise, ce que cela implique, comment le renouveler]
(« Aucune alerte » s'il n'y en a pas)

## Rétroplanning
| Quand | Étape | Fait |
|---|---|---|
| [jour JJ mois AAAA] | … | [ ] |

## Formulaires de candidature
[Formulaires demandés par le RC (source), où les trouver, tableau des valeurs de la fiche, [À COMPLÉTER] pour le reste, déclarations sur l'honneur à cocher et signer par vous]

Sources vérifiées le 13/11/2026 : [liste des pages officielles de ce fichier]

## Le prix reste à vous
[rappel : BPU / DPGF / DQE / acte d'engagement, à remplir par l'artisan, sans chiffre]

## À vérifier avant de vous lancer
Les dates et les pièces viennent des documents que vous m'avez donnés. Vérifiez-les sur la plateforme de l'acheteur : un avis rectificatif peut les avoir changées. Le dépôt de l'offre se fait par vous, sur la plateforme.
```

2. Mettez à jour `suivi.md` : dans la ligne de la consultation, remplacez le statut `analysée` par `en préparation`. Gardez le verdict, la date limite et les notes, et ajoutez à la note la prochaine échéance (par exemple « visite 08/12 »). Ne touchez pas aux autres lignes. S'il n'y a pas de ligne, ajoutez-la avec les informations de l'analyse.
3. Répondez : **la conclusion d'abord** (par exemple « Il vous reste 2 pièces à renouveler avant le 15 janvier et 1 qualification qui manque »), puis un résumé de 5 lignes à peu près : ce qui est prêt, les alertes sur les justificatifs, la prochaine date du calendrier (aujourd'hui ou la prochaine échéance), les formulaires à remplir, le rappel que le prix reste à lui. Dites que la consultation est maintenant « en préparation », où se trouve le fichier (chemin du sous-dossier), et terminez par le rappel de vérifier les dates sur la plateforme de l'acheteur.
4. Posez une seule question pour la suite, la plus utile : par exemple « Voulez-vous commencer par le mémoire technique ? » ou, s'il y a une alerte, « Avez-vous déjà demandé la nouvelle attestation URSSAF ? ».

N'écrivez aucun prix, ni dans le fichier ni dans votre réponse, sauf pour citer ceux du dossier (estimation de l'acheteur, montants de pénalités).
