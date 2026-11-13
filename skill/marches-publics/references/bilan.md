# Suivi, dépôt et bilan

Cette étape couvre la fin du parcours : expliquer comment déposer l'offre, tenir le suivi à jour (`déposée`, `gagnée`, `perdue`, `bilan fait`), montrer où en sont toutes les consultations, et faire le bilan d'une consultation perdue. Elle sert pour : « comment je dépose ? », « j'ai déposé », « j'ai gagné », « j'ai perdu », « où j'en suis ? », « faisons le bilan ».

Le suivi est le fichier `suivi.md` du dossier de travail ([dossier-de-travail.md](dossier-de-travail.md)). Relisez-le au début de l'étape. S'il n'existe pas, créez-le comme indiqué dans ce fichier.

## Règles

- **L'artisan dépose lui-même** (ADR 0002). Vous ne vous connectez à aucune plateforme, vous ne déposez rien, vous n'envoyez aucun courrier ou mail à sa place : vous expliquez et vous préparez. Il n'enregistre ici ni mot de passe ni identifiant de plateforme.
- **Une consultation change de statut quand l'artisan le dit**, pas avant. Ne devinez pas qu'il a déposé, gagné ou perdu.
- **N'inventez rien.** Un titulaire, un montant, une date, un motif de rejet : seulement ce que vous avez lu dans les données ou ce que l'artisan vous a dit. Sinon : « je ne l'ai pas trouvé ».
- Ton : [ton.md](ton.md). Une seule question à la fin de chaque réponse, au plus. Pas de code, de nom de champ ni de requête dans vos réponses.

## 1. Trouver la consultation concernée

Quand l'artisan nomme une consultation (« l'école de Val-de-Brelle », « celle de Bron »), retrouvez sa ligne dans `suivi.md` par l'acheteur ou le titre. S'il y a un doute (deux consultations du même acheteur, ou aucune qui corresponde), posez une seule question pour savoir laquelle, en proposant les consultations possibles comme choix (voir [ton.md](ton.md)). S'il n'en cite aucune et qu'il n'y en a qu'une qui puisse correspondre (une seule `en préparation` quand il dit « j'ai déposé »), reformulez-la et demandez confirmation en une phrase.

S'il n'y a aucune ligne pour cette consultation, ajoutez-la avec le statut demandé et dites-le : le suivi doit refléter ce qu'il vit.

## 2. Expliquer le dépôt

À la demande (« comment je dépose ? ») ou quand la date limite d'une consultation `en préparation` approche. En mots simples, **brièvement et en quelques points**, adaptés à la consultation (son règlement et sa plateforme si vous les connaissez par l'analyse) :

1. **Où** : sur la plateforme de dématérialisation de l'acheteur (le site où l'on a téléchargé le dossier). Le lien est dans l'avis ou dans les notes du suivi. L'offre ne se dépose généralement pas par e-mail ni par courrier : le règlement de consultation (RC, le document qui fixe les règles de la consultation) le précise.
2. **Un compte** : il se crée sur la plateforme, c'est le plus souvent gratuit. L'identifiant et le mot de passe restent à l'artisan : ne les lui demandez pas.
3. **Quand** : avant la date **et l'heure** limites du RC, qui sont celles de l'acheteur. Un dépôt en retard est refusé. Conseil : déposer la veille, car le dépôt de gros fichiers peut prendre du temps et la plateforme peut avoir un problème.
4. **Quoi** : les pièces de la checklist (étape 4 du menu) et le mémoire technique, au format demandé (souvent PDF), avec les noms de fichiers et la taille maximale que la plateforme indique. Le **prix** (BPU, DPGF, DQE) est rempli par l'artisan lui-même. Relire les pièces avant d'envoyer.
5. **La signature** : le RC dit si une signature électronique est demandée au dépôt ou seulement pour le marché si l'offre est retenue. À vérifier dans le RC : ne dites jamais « pas besoin » sans l'avoir lu.
6. **Après le dépôt** : la plateforme donne un accusé de réception (avec la date et l'heure). L'artisan le garde dans le dossier de la consultation : c'est sa preuve.
7. **Un problème technique** juste avant la date limite : le signaler tout de suite à l'acheteur par la messagerie de la plateforme, en gardant la trace.

Terminez par : « Quand vous avez déposé, dites-le-moi : je mets votre suivi à jour. »

## 3. Mettre à jour un statut

| L'artisan dit | Statut à inscrire |
|---|---|
| « j'ai déposé », « c'est parti », « l'offre est envoyée » | `déposée` |
| « j'ai gagné », « on a le marché » | `gagnée` |
| « j'ai perdu », « on n'est pas retenu », « j'ai reçu un refus » | `perdue` (puis le bilan, partie 5) |
| le bilan est terminé (partie 5 ou 6) | `bilan fait` |
| « je ne réponds pas à celle-là », « je décline » (avant de déposer) | `déclinée` |
| « finalement je réponds » (sur une consultation `déclinée`, avant la date limite) | `analysée`, puis proposez la préparation des pièces |

- Ne modifiez **que la ligne concernée**, dans la colonne Statut : écrit en minuscules, comme les autres. Gardez les autres colonnes et les autres lignes intactes.
- Ajoutez à la colonne Notes, **à la suite** du texte déjà présent, la date de l'événement : `déposée le JJ/MM/AAAA`, `perdue le JJ/MM/AAAA`… avec celle qu'il donne, ou celle d'aujourd'hui s'il dit « aujourd'hui » ou ne précise pas.
- Il peut sauter une étape (« j'ai perdu » pour une consultation encore `analysée`, parce qu'il n'avait rien dit) : acceptez, c'est ce qu'il vit.
- Si le statut est déjà celui qu'il annonce, dites-le simplement.
- Confirmez en une phrase : « C'est noté : l'école de Val-de-Brelle est déposée. »

## 4. Voir où j'en suis

À la demande (« où j'en suis ? », « mon suivi »), présentez **toutes** les consultations du suivi, lisiblement. Pas de tableau Markdown brut dans la réponse sur téléphone : une liste courte, une consultation par entrée.

1. Une phrase de conclusion (« Vous suivez 4 consultations : 1 est à déposer avant le 15 janvier, 1 attend une réponse, 2 sont terminées. »).
2. Les consultations **regroupées par étape**, dans cet ordre, en sautant les groupes vides : « À préparer ou à déposer » (`repérée`, `analysée`, `en préparation`, triées par date limite), « Déposées, en attente de réponse », « Gagnées », « Perdues, bilan à faire », « Bilan fait », « Déclinées » (sans prochaine chose à faire, sauf s'il veut y revenir avant la date limite).
3. Pour chacune : le titre court, l'acheteur, le statut en mots, le verdict (🟢🟠🔴) s'il y en a un, la date limite, et **la prochaine chose à faire** en quelques mots (« analyser le dossier », « vérifier les pièces », « attendre la réponse », « demander les motifs »).
4. **Alertes**, en tête, quand elles s'appliquent :
   - date limite dans moins de 7 jours et statut avant `déposée` ;
   - date limite **dépassée** sans statut `déposée` : demandez-lui s'il a déposé (c'est votre question unique de la réponse) ;
   - consultation `déposée` depuis plus de 2 mois, ou `perdue` sans bilan : proposez de s'en occuper.
5. Suivi vide : « Vous n'avez encore aucune consultation dans votre suivi. » et proposez la veille (étape 2 du menu).

Ne modifiez pas le suivi en répondant à cette demande.

## 5. Bilan d'une consultation perdue

Quand l'artisan dit qu'il a perdu, enchaînez ces étapes **dans la même réponse**, sans lui demander de confirmer chacune. Il n'y a qu'**une question à la fin**.

### a. Statut

Passez la ligne à `perdue` (partie 3).

### b. Le courrier de demande des motifs

Un acheteur doit expliquer à une entreprise évincée pourquoi son offre n'a pas été retenue. Pour une procédure adaptée, c'est sur demande et sous 15 jours (code de la commande publique, articles R. 2181-1 et suivants) ; pour une procédure formalisée, les motifs figurent déjà dans le courrier de rejet. Expliquez-le en une phrase et dites que **c'est à lui d'envoyer le courrier**.

Enregistrez le courrier dans le sous-dossier de la consultation sous le nom `courrier-demande-motifs.md` (créez le sous-dossier comme indiqué dans [dossier-de-travail.md](dossier-de-travail.md) s'il manque). Utilisez les informations de la fiche entreprise (nom, adresse, SIRET, coordonnées) et du suivi (acheteur, titre, lot). **N'inventez pas** l'adresse de l'acheteur, la référence du dossier ou la date du courrier de rejet : [À COMPLÉTER].

```markdown
[Nom de l'entreprise]
[Adresse] — SIRET [SIRET]
[Téléphone] — [E-mail]

[Nom de l'acheteur]
Service de la commande publique
[Adresse de l'acheteur : À COMPLÉTER]

[Commune], le [date du jour]

Objet : demande des motifs de rejet de notre offre
Consultation : [titre de la consultation, lot] (référence : [À COMPLÉTER])

Madame, Monsieur,

Nous avons remis une offre pour le lot cité en objet. Par courrier du [date de la lettre de rejet : À COMPLÉTER], vous nous avez informés que notre offre n'était pas retenue.

Conformément aux articles R. 2181-1 et suivants du code de la commande publique, nous vous demandons de bien vouloir nous communiquer :
- les motifs du rejet de notre offre ;
- le nom de l'entreprise attributaire ;
- les caractéristiques et les avantages de son offre, ainsi que le montant du marché ;
- les notes obtenues par notre offre et par l'offre retenue, pour chaque critère, et notre classement.

Ces informations nous permettront d'améliorer nos prochaines offres.

Nous vous remercions de votre réponse et vous prions d'agréer, Madame, Monsieur, nos salutations distinguées.

[Prénom Nom, fonction : À COMPLÉTER]
[Entreprise]
```

Dites où le courrier est enregistré, qu'il doit compléter les [À COMPLÉTER] et l'envoyer lui-même (par la messagerie de la plateforme, de préférence, sinon par e-mail), et qu'il garde la réponse dans le dossier de la consultation.

### c. Chercher qui a gagné

Lisez [api-decp.md](api-decp.md) avant la première requête. Suivez-la : trouvez l'acheteur, cherchez le marché dans les DECP (jeu `decp-2022-marches-valides`), puis le **nom** de chaque titulaire à partir de son SIRET dans Recherche d'entreprises.

Présentez ce que vous avez trouvé, **sans extrapoler** :

- **Marché trouvé** : le nom de l'entreprise retenue (et sa commune), le montant en euros hors taxes, la date de notification. Jamais le SIRET seul : s'il manque un nom, écrivez « nom introuvable (SIRET : …) ». Avec plusieurs titulaires : un groupement, nommez-les tous. Ajoutez le nombre d'offres reçues s'il est indiqué.
- **Précisez la fiabilité** : « c'est le marché de l'acheteur qui ressemble le plus à votre consultation (même chantier, notifié le …) ; je n'ai pas de lien officiel entre les deux ». S'il y a un doute (montant rond ou ressemblant à un plafond, objet un peu différent, plusieurs marchés plausibles), dites-le.
- **Aucun marché trouvé, ou acheteur non identifié** : dites-le clairement, sans en conclure que l'acheteur a mal fait. Expliquez : les acheteurs publient parfois plusieurs semaines ou mois après la notification, certains petits marchés ne sont jamais publiés ; l'artisan obtiendra le nom et le montant par la réponse à son courrier. Ne donnez **aucun nom, aucun montant, aucune date** inventés ou « probables », et ne devinez pas la raison de l'absence (retard de publication ou autre) : listez seulement ce qui est possible. L'artisan vous a dit que la consultation est perdue : ne le contredisez pas.
- **Site injoignable** (pas de réponse) : dites que vous n'avez pas pu consulter les données pour le moment, qu'il peut vous redemander plus tard, et passez à la suite.
- **Données incomplètes** (montant absent ou à 0, nom introuvable, date manquante) : dites précisément ce qui manque.

Le prix de l'artisan reste le sien : s'il vous donne son montant, vous pouvez le comparer au montant du titulaire en une phrase factuelle, sans juger ni conseiller un prix.

Notez dans la colonne Notes du suivi le résultat en quelques mots : `Titulaire : Entreprise Exemple (Lyon), 52 000 € HT, notifié le 12/03/2027 (DECP)` ou `Attribution non trouvée dans les DECP au JJ/MM/AAAA`. Gardez ce qui s'y trouve déjà.

### d. Les leçons

Terminez par **une seule question**, ouverte, sur ce qu'il en retient : « À votre avis, qu'est-ce qui a pu jouer, et que feriez-vous autrement la prochaine fois ? ». Vous pouvez l'aider avec un ou deux points tirés de l'analyse de cette consultation (`analyse.md` du sous-dossier : pièges, critères, pièces manquantes), mais le jugement vient de lui.

Quand il répond :

1. Rédigez **ses** leçons en 2 à 5 phrases courtes, avec ses mots. N'ajoutez pas de cause que ni lui, ni l'acheteur, ni l'analyse n'a donnée. Si les motifs de l'acheteur ne sont pas encore reçus, écrivez-le.
2. Notez-les dans `suivi.md`, dans la section `## Leçons` (voir ci-dessous).
3. Passez la ligne à `bilan fait`.
4. Dites-le en une phrase, et rappelez que s'il reçoit la réponse de l'acheteur, il peut vous la donner : vous complétez les leçons.

### Où noter les leçons

À la fin de `suivi.md`, **après** le tableau, une section `## Leçons` (créez-la à la première fois) avec une entrée par consultation :

```markdown
## Leçons

### Sanitaires école de Val-de-Brelle (perdue le 25/01/2027)
- Titulaire : Entreprise Exemple (Lyon), 52 000 € HT, notifié le 12/03/2027.
- Mon prix était trop haut ; j'avais oublié l'attestation d'assurance.
- Pour la prochaine fois : vérifier la checklist des pièces la veille du dépôt.
```

N'effacez ni ne réécrivez les leçons existantes. Les nouvelles lignes de consultation se placent toujours dans le tableau, avant cette section.

## 6. Consultation gagnée

Passez la ligne à `gagnée`. Félicitez sobrement, en une phrase. Expliquez en deux ou trois phrases la suite : l'acheteur envoie la notification du marché, puis l'artisan signe l'acte d'engagement et reçoit l'ordre de service. Ne lui promettez rien sur les délais. Proposez ensuite, en **une question**, de noter ce qui a bien marché pour la prochaine fois. Si oui : écrivez ses points dans `## Leçons` et passez à `bilan fait`.

## 7. Bilan sans statut clair

Si l'artisan dit « faisons le bilan » pour une consultation `déposée`, demandez-lui d'abord si elle est gagnée ou perdue. Pour une consultation déjà `perdue` sans bilan, reprenez à la partie 5, étape b si le courrier n'existe pas, sinon c ou d.
