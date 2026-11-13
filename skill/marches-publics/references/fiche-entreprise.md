# Fiche entreprise

La fiche entreprise décrit l'artisan une fois pour toutes. Elle sert à toutes les autres étapes : veille, analyse, pièces, mémoire technique, lettre de présentation. C'est le fichier `ma-fiche-entreprise.md` du dossier de travail ([dossier-de-travail.md](dossier-de-travail.md)). L'artisan doit pouvoir l'ouvrir et la lire lui-même.

## Règles

- **Une question à la fois**, dans l'ordre du questionnaire ci-dessous. Si l'artisan donne plusieurs informations d'un coup (fréquent à la voix), enregistrez-les toutes et passez à la première question encore sans réponse.
- **Enregistrez au fur et à mesure.** Dès la première réponse, créez la fiche à partir du modèle, toutes les rubriques marquées [À COMPLÉTER], puis remplissez-la après chaque réponse. Si la conversation s'arrête, rien n'est perdu.
- **N'inventez rien.** Ce que l'artisan ne sait pas, ne veut pas dire ou veut remettre à plus tard reste [À COMPLÉTER]. Ne déduisez pas un chiffre d'un autre.
- **Ne montrez pas les codes.** Les descripteurs BOAMP et les codes CPV sont enregistrés dans la fiche, mais vous n'en parlez pas pendant le questionnaire.
- Si une fiche existe déjà, ne la recréez pas : reprenez à la première rubrique encore [À COMPLÉTER], ou faites la modification demandée (voir « Modifier la fiche »).

## Ce que la fiche ne contient jamais

Mot de passe, code d'accès, identifiant ou nom d'utilisateur d'une plateforme d'acheteur (PLACE, achatpublic, Maximilien, Mégalis…), IBAN, RIB, numéro de carte bancaire.

Si l'artisan vous demande d'en noter un, même dans une autre rubrique ou « juste pour cette fois » :

1. Refusez en une phrase, sans le recopier ni dans la fiche ni dans votre réponse.
2. Expliquez pourquoi en une phrase : la fiche est un simple fichier, lisible par toute personne qui utilise l'ordinateur, et ce que vous lisez passe par le fournisseur de l'intelligence artificielle.
3. Conseillez-lui de le garder là où il le range d'habitude (carnet, gestionnaire de mots de passe de son ordinateur).
4. Reprenez là où vous en étiez.

Le SIRET, le numéro de TVA et les numéros de certification ou de contrat d'assurance ne sont pas des secrets : ils figurent sur les documents publics de l'entreprise et peuvent être enregistrés.

## Questionnaire

Annoncez-le en une phrase (« Je vais vous poser une dizaine de questions, une à la fois. Vous pouvez répondre "je ne sais pas" et compléter plus tard. »), puis posez :

1. **Le nom de l'entreprise** et la commune où elle se trouve.
2. **Le ou les métiers.** Traduisez chaque métier avec [metiers.md](metiers.md) et enregistrez ses descripteurs BOAMP et ses codes CPV. Si un métier n'est pas dans la table, suivez la partie « Métier absent de la table » de ce fichier.
3. **Les départements** où il accepte de travailler. Enregistrez les numéros (69, 01…). S'il cite des villes, traduisez-les en départements et faites confirmer.
4. **La taille des lots qui l'intéressent**, en euros hors taxes. Proposez des choix numérotés : 1. moins de 20 000 €, 2. de 20 000 à 100 000 €, 3. de 100 000 à 300 000 €, 4. plus de 300 000 €. Il peut en choisir plusieurs : enregistrez le minimum et le maximum.
5. **Ses certifications et qualifications** (Qualibat, Qualifelec, RGE, Qualigaz, QualiPAC…), avec leur numéro et leur date de fin de validité s'il les a sous la main. « Aucune » est une réponse valable.
6. **L'effectif** : nombre de personnes, dirigeant compris, et parmi elles le nombre d'apprentis.
7. **Le chiffre d'affaires hors taxes** des trois dernières années. Expliquez qu'il est demandé dans les dossiers de candidature. S'il ne l'a pas en tête, il est sur le bilan ou la liasse fiscale : laissez [À COMPLÉTER].
8. **Les assurances** : responsabilité civile professionnelle et garantie décennale, avec le nom de l'assureur et la date de fin de validité de l'attestation.
9. **Les références** : 3 à 5 chantiers récents, de préférence publics. Demandez-les une par une : pour qui (acheteur ou client), quels travaux, dans quelle commune, quelle année, pour quel montant hors taxes. Après la troisième, demandez s'il en a une autre ou s'il s'arrête là.
10. **Les justificatifs** (les documents administratifs à durée de validité limitée) : extrait Kbis, attestation de vigilance URSSAF, attestation de régularité fiscale, attestations d'assurance. Pour chacun, demandez la date qui figure dessus.
    - S'il y a déjà des fichiers dans `mes-justificatifs/`, lisez-les pour proposer les dates, et faites confirmer.
    - S'il a le document sous forme de fichier, proposez-lui de le glisser dans `mes-justificatifs/` et notez son nom.
    - Si le document indique une date de fin de validité, enregistrez-la. Sinon, enregistrez la date de délivrance et laissez la fin de validité [À COMPLÉTER].
11. **Les coordonnées** : SIRET, adresse, téléphone et e-mail de l'entreprise. Le SIRET figure sur le Kbis et sur ses factures.

À la fin, résumez en trois lignes ce qui est enregistré, dites combien d'informations restent [À COMPLÉTER] et proposez la suite : « Voulez-vous que je cherche des consultations pour vous ? ».

## Modèle

Remplacez chaque [À COMPLÉTER] par la réponse de l'artisan. Écrivez les dates en JJ/MM/AAAA et les montants en euros hors taxes.

```markdown
# Ma fiche entreprise

Mise à jour le : JJ/MM/AAAA

## Entreprise
- Nom : [À COMPLÉTER]
- Commune : [À COMPLÉTER]
- SIRET : [À COMPLÉTER]
- Adresse : [À COMPLÉTER]
- Téléphone : [À COMPLÉTER]
- E-mail : [À COMPLÉTER]

## Métiers
- Métiers : [À COMPLÉTER]
- Descripteurs BOAMP : [À COMPLÉTER]
- Codes CPV : [À COMPLÉTER]

## Zone d'intervention
- Départements : [À COMPLÉTER]

## Lots qui m'intéressent
- Montant d'un lot : de [À COMPLÉTER] € HT à [À COMPLÉTER] € HT

## Certifications
- [À COMPLÉTER]

## Effectif
- Personnes, dirigeant compris : [À COMPLÉTER]
- Dont apprentis : [À COMPLÉTER]

## Chiffre d'affaires
| Année | Montant HT |
|---|---|
| [À COMPLÉTER] | [À COMPLÉTER] |

## Assurances
| Assurance | Assureur | Valable jusqu'au |
|---|---|---|
| Responsabilité civile professionnelle | [À COMPLÉTER] | [À COMPLÉTER] |
| Garantie décennale | [À COMPLÉTER] | [À COMPLÉTER] |

## Références
| Année | Acheteur ou client | Travaux | Commune | Montant HT |
|---|---|---|---|---|
| [À COMPLÉTER] | [À COMPLÉTER] | [À COMPLÉTER] | [À COMPLÉTER] | [À COMPLÉTER] |

## Justificatifs
| Justificatif | Délivré le | Valable jusqu'au | Fichier |
|---|---|---|---|
| Extrait Kbis | [À COMPLÉTER] | [À COMPLÉTER] | [À COMPLÉTER] |
| Attestation de vigilance URSSAF | [À COMPLÉTER] | [À COMPLÉTER] | [À COMPLÉTER] |
| Attestation de régularité fiscale | [À COMPLÉTER] | [À COMPLÉTER] | [À COMPLÉTER] |
| Attestation d'assurance responsabilité civile | [À COMPLÉTER] | [À COMPLÉTER] | [À COMPLÉTER] |
| Attestation d'assurance décennale | [À COMPLÉTER] | [À COMPLÉTER] | [À COMPLÉTER] |
```

Les certifications s'écrivent une par ligne : `- Qualibat 5211, n° 12345, valable jusqu'au 30/06/2027`. Une rubrique sans objet (aucune certification, aucun apprenti) s'écrit « Aucune » ou « 0 », pas [À COMPLÉTER].

## Modifier la fiche

Quand l'artisan dit « modifiez ma fiche… », « changez mon effectif… », « j'ai une nouvelle référence… » :

1. Relisez la fiche.
2. Changez uniquement la rubrique concernée, et la date « Mise à jour le ». Ne touchez à aucune autre ligne.
3. Si les métiers changent, mettez aussi à jour leurs descripteurs BOAMP et leurs codes CPV.
4. Confirmez en une phrase ce qui a changé (« C'est noté : votre effectif passe à 6 personnes. »).

Si la demande est ambiguë (« changez mon assurance »), demandez laquelle avant de modifier.
