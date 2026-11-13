# Notes du formateur — support de formation « Marchés publics »

À lire avec [le support](support-formation.pdf) (29 diapositives). Les numéros ci-dessous sont ceux du pied de page. Le détail de chaque étape est dans la [notice complète](../notice/notice-utilisation.pdf) ; les artisans ont la notice de 3 pages.

Les horaires sont une **proposition** pour une journée de 9 h à 17 h : ajustez la diapositive 02 et ces notes si le déroulé change.

## Avant la formation

- [ ] **Chaque artisan a fait le test de contrôle** une semaine avant ([test-de-controle.md](../test-de-controle.md)) et vous a envoyé son résultat. Notez qui a eu un problème : vous commencerez par eux à 10 h.
- [ ] **Les seuils** de [seuils.md](../../skill/marches-publics/references/seuils.md) sont revérifiés (100 000 € HT pour les travaux, 60 000 € HT pour les fournitures et services). Si un montant change, corrigez les diapositives 02, 04, 05 et le schéma de la 13 (dans `source/assembler.py`).
- [ ] **La consultation du jour** est choisie : un lot de travaux courant (plomberie, électricité, menuiserie…), avec un DCE téléchargeable et, si possible, un cadre de mémoire de l'acheteur (pour montrer la diapositive 21). Remplissez la diapositive 16 (acheteur, objet, lot, date limite, où récupérer le DCE).
- [ ] **Le DCE est aussi sur une clé USB** : certaines plateformes demandent de créer un compte avant de télécharger ; ne perdez pas l'après-midi là-dessus.
- [ ] **Le QR code** d'installation est fabriqué ([qr-code.md](../qr-code.md)) et placé sur la diapositive 10.
- [ ] **Les emplacements à compléter** sont remplis : lieu, jour et formateur (01), QR code (10), consultation du jour (16), capture du cadre rempli (21). `source/construire.sh` les liste.
- [ ] Un ordinateur de démonstration avec l'outil installé, une fiche entreprise d'exemple et la consultation du jour déjà analysée (au cas où le réseau tombe).

## Le matin

**01 · Couverture (9 h 00).** Présentez-vous, faites un tour de table : métier, département, déjà répondu à un marché public ou non.

**02 · Programme.** Annoncez le principe : le matin on comprend et on installe, l'après-midi chacun travaille sur la même vraie consultation.

**03 · Six mots.** Ne lisez pas tout : demandez qui connaît « DCE » ou « lot ». L'outil les réexplique lui-même la première fois qu'il les emploie.

**04 · Le seuil.** Le message clé de la matinée : sous 100 000 € HT de travaux, l'acheteur *peut* consulter sans annonce. Il n'y est pas obligé, et il ne doit pas toujours s'adresser au même artisan. Les consultations lancées avant le 01/01/2026 relevaient de l'ancien seuil (40 000 € HT) : n'en parlez que si on vous pose la question.

**05 · Deux façons.** Faites le lien avec la suite : la veille (étapes 2 à 6) et se faire connaître (étape 7).

**06 · L'outil et vous (9 h 40).** Insistez sur la colonne de droite : le prix, la décision, le dépôt. C'est la règle de l'outil (ADR 0002), pas une limite provisoire.

**07 · Citation.** Une phrase, puis passez.

**08 · Comment lui parler.** « Je ne sais pas » est une bonne réponse : l'outil note [À COMPLÉTER] au lieu d'inventer. Dans Claude, le menu arrive en général en choix à cliquer ; dans Codex, en liste numérotée. Dans les deux cas, on peut écrire avec ses mots ou parler.

**09 · Ce qu'il vous faut (10 h 00).** Normalement réglé par le test de contrôle. Vérifiez à main levée : abonnement actif, application installée (pas le site).

**10 · Installer en 4 étapes.** Pour ceux dont le test de contrôle a échoué ou qui ne l'ont pas fait : ils installent maintenant, les autres passent directement à la vérification (12).

**11 · Les autorisations.** La règle simple : oui pour l'outil et le dossier « Marchés publics », non pour le reste. Le détail des commandes est dans [autorisations.md](../autorisations.md) et la notice complète (page 8). Personne ne choisit un mode automatique.

**12 · À vous : vérifier (20 min).** Tout le monde doit voir le menu avant la pause. Si ce n'est pas le cas : nouvelle conversation ; sinon recoller le message d'installation ; sinon photo de l'écran et on regarde pendant la pause. **Pause à 10 h 30.**

**13 · Le parcours (10 h 45).** Montrez les deux rangées : 1-2-3 pour trouver et analyser, 4-5-6 seulement si l'artisan décide de répondre. L'étape 7 se fait en parallèle.

**14 · Étape 1, la fiche (30 min).** La plus longue de la journée, et la plus utile : tout le reste en dépend. Une dizaine de questions, une à la fois. Les artisans qui n'ont pas leurs papiers répondent « je ne sais pas » et complètent plus tard. Rappelez : jamais de mot de passe, d'identifiant de plateforme ou d'IBAN dans la fiche (l'outil refuse de les enregistrer).

**15 · Étape 2, la veille (20 min).** Résultat : au plus 10 consultations, avec au moins 10 jours pour répondre. « Rien trouvé » arrive selon les métiers et les départements : ce n'est pas une panne, c'est l'argument pour l'étape 7. **Repas à 12 h 15.**

## L'après-midi

**16 · La consultation du jour (13 h 30).** Distribuez le DCE (plateforme ou clé USB). Chacun le dépose dans Documents → Marchés publics. Le téléchargement et le dépôt de l'offre ne sont jamais faits par l'outil.

**17 · Étape 3, l'analyse.** Expliquez les trois avis avant que les résultats arrivent. Les avis peuvent différer d'un artisan à l'autre : ils dépendent de la fiche de chacun (métier, montants, certifications). C'est un bon sujet de discussion.

**18 · Le choix (40 min avec la 17).** Montrez que l'outil ne décide pas : il propose Répondre, Décliner et, selon le cas, poser une question à l'acheteur ou chercher un partenaire. Pour l'exercice, tout le monde choisit **Répondre** afin de faire les étapes 4 et 5. Ceux qui voudraient décliner pour de vrai pourront revenir sur leur choix avant la date limite (« finalement je réponds »).

**19 · Étape 4, les pièces (20 min).** Faites repérer l'alerte la plus utile : un justificatif valable aujourd'hui mais périmé avant la date limite. Le prix (bordereau, décomposition) reste vide : c'est voulu. **Pause à 15 h 00.**

**20 · Étape 5, le mémoire (30 min, 15 h 15).** Les réponses à la voix ou en langage parlé suffisent. Faites ouvrir le fichier Word et chercher les [À COMPLÉTER] surlignés en jaune : relire et compléter, c'est le travail de l'artisan. Si un fichier .rtf arrive au lieu du Word, il s'ouvre aussi dans Word.

**21 · Le cadre de l'acheteur.** Seulement si le DCE du jour en contient un : montrez les deux fichiers produits (le mémoire et la copie remplie du cadre). Si l'usage du cadre est obligatoire, c'est la copie remplie qu'il faut déposer.

**22 · Étape 6, le suivi (10 min, 16 h 00).** Faites demander « où j'en suis ? ». Insistez : on ne dit « j'ai déposé » que le jour où c'est vrai, sinon le suivi est faux. Après un refus, l'outil rédige le courrier de demande des motifs ; l'artisan l'envoie lui-même.

**23 · Étape 7, se faire connaître (15 min).** La liste vient du BOAMP : elle n'est pas complète et ne contient pas d'adresse. L'artisan trouve le service technique et envoie la lettre lui-même.

**24 · Les règles d'or (16 h 35).** Faites-les répéter.

**25 · Données.** Le dossier n'existe que sur l'ordinateur : conseillez une sauvegarde (clé USB, disque). Ce qui part chez Anthropic ou OpenAI : ce qu'on écrit et ce que l'assistant lit. Pas de mot de passe, d'IBAN, ni le prix si on veut le garder pour soi. Détail : [donnees-et-confidentialite.md](../donnees-et-confidentialite.md).

**26 · Dépannage.** Les cas les plus fréquents ; le tableau complet est dans la notice (page 15).

**27 · Mémo des phrases.** Laissez cette diapositive affichée pendant les questions.

**28 · Après la formation.** Trois gestes : finir la fiche, relancer la veille chaque semaine, mettre à jour quand une version est annoncée.

**29 · Questions (fin à 17 h).** Pour un blocage après la formation : contact@picant3.com, avec une photo de l'écran, l'ordinateur (Mac ou Windows) et l'application utilisée.
