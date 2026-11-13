# Se faire connaître

Cette étape sert à ne pas attendre les annonces : sous un certain montant, un acheteur n'est pas obligé de publier son marché, donc l'artisan doit être connu de lui avant. L'agent explique, propose des acheteurs proches et rédige une lettre. **L'artisan envoie lui-même la lettre** : vous n'envoyez ni courrier ni e-mail et vous ne remplissez aucun formulaire de contact (voir ADR 0002).

## Avant de commencer

Lisez la fiche entreprise (`ma-fiche-entreprise.md`). Sans fiche, ou si les **métiers** ou les **départements** sont [À COMPLÉTER], proposez d'abord de la remplir (étape 1) : la liste d'acheteurs et la lettre en dépendent.

## 1. Expliquer le seuil

Lisez [seuils.md](seuils.md) : n'écrivez jamais un montant de mémoire. En quelques phrases courtes, dites :

- Un marché de travaux de moins de 100 000 € HT (hors taxes) peut être confié **sans annonce publique** : l'acheteur (mairie, bailleur social…) peut demander un devis directement aux artisans qu'il connaît. C'est pourquoi tous les marchés ne sont pas sur le BOAMP (le site officiel des annonces).
- Pour les fournitures et services, le seuil est de 60 000 € HT.
- Conclusion pour lui : il faut que les acheteurs proches le connaissent avant d'avoir besoin de lui. Le rapprocher de ses lots habituels (rubrique « Lots qui m'intéressent » de la fiche) si elle est remplie.
- Ajoutez que l'acheteur n'a aucune obligation de répondre, et qu'envoyer la lettre ne garantit rien.

Puis proposez : « Voulez-vous une liste d'acheteurs proches de chez vous ? » (une seule question).

## 2. Lister des acheteurs proches

Appuyez-vous sur des **données réelles**, pas sur votre mémoire : les acheteurs qui ont publié des avis de travaux au BOAMP dans les départements de la fiche. Cela ne dit pas qu'ils consultent directement, mais ils achètent des travaux et connaissent la procédure.

Requête (API sans clé, entre apostrophes simples dans la condition). Sur Windows, utilisez `curl.exe` au lieu de `curl`. Remplacez le département et la date (il y a environ 12 mois) :

```
curl -s -G "https://boamp-datadila.opendatasoft.com/api/explore/v2.1/catalog/datasets/boamp/records" \
  --data-urlencode "select=nomacheteur, count(*) as n" \
  --data-urlencode "where=type_marche='TRAVAUX' and code_departement='69' and dateparution>=date'2025-11-13'" \
  --data-urlencode "group_by=nomacheteur" \
  --data-urlencode "order_by=n desc" \
  --data-urlencode "limit=40"
```

Pièges connus :

- **Le code département perd son zéro** : pour l'Ain, c'est `code_departement='1'`, pas `'01'` (`'01'` renvoie 0 résultat). Pour la Corse : `'20A'` (Corse-du-Sud) et `'20B'` (Haute-Corse), pas `'2A'` ni `'2B'`.
- Une même annonce peut porter plusieurs départements : la liste contient parfois des acheteurs d'ailleurs (CHU d'une autre région…). Écartez ce qui n'est manifestement pas du département.
- Un même acheteur peut apparaître sous deux écritures (« Région Auvergne-Rhône-Alpes » et « REGION AUVERGNE RHONE ALPES ») : regroupez-les.
- Pour compléter avec les bailleurs sociaux, ajoutez à la condition `and (search(nomacheteur,'habitat') or search(nomacheteur,'OPAC') or search(nomacheteur,'OPH'))` et retirez `type_marche`. Vérifiez le département de chaque résultat.
- Si la requête échoue ou ne renvoie rien d'utile, dites-le à l'artisan et proposez de chercher ensemble les mairies et intercommunalités de sa zone. N'inventez jamais un nom d'acheteur.

Triez la liste pour l'artisan :

1. Gardez de préférence les **mairies, intercommunalités (communautés de communes ou d'agglomération, métropole), le département, les bailleurs sociaux** et les syndicats locaux. Laissez de côté les acheteurs qui n'achètent pas ce que fait l'artisan (hôpitaux, transports, universités, État) sauf s'il le demande.
2. Privilégiez ceux qui publient souvent et qui sont proches de sa commune.
3. Présentez 8 à 12 acheteurs, groupés par département, avec le nombre d'avis de travaux publiés sur les 12 derniers mois (« 33 avis »). Dites que la liste vient du BOAMP, qu'elle n'est pas complète, et qu'elle ne contient ni adresse ni contact.
4. Les contacts (adresse postale, e-mail du service technique) ne viennent pas du BOAMP : dites à l'artisan de les chercher sur le site de la mairie ou de l'organisme, ou proposez-lui de les chercher avec lui ; ne les devinez pas.

Enregistrez la liste dans le dossier de travail : `se-faire-connaitre/acheteurs.md`, avec la date de la recherche et la requête utilisée (départements, période). Créez le sous-dossier `se-faire-connaitre/` s'il manque, sans toucher aux autres fichiers.

Puis proposez : « Voulez-vous que je rédige une lettre de présentation à leur envoyer ? ».

## 3. Rédiger la lettre

La lettre se fonde **uniquement** sur la fiche entreprise. Elle est adressée « aux services techniques » (de la mairie, de l'intercommunalité, du bailleur…), sans nom de personne. Une seule lettre type : l'artisan met le nom de l'acheteur à chaque envoi (`[Nom de l'acheteur]`).

Règles :

- **Factuelle, sobre, une page.** Pas de superlatifs (« leader », « reconnu », « irréprochable »), pas de promesse de prix, de délai ou de qualité.
- **Que des faits de la fiche** : nom, commune, métiers, départements, certifications (avec numéro et validité), références (acheteur, travaux, commune, année, montant), effectif, coordonnées. N'ajoutez aucun chantier, chiffre, nombre d'années d'expérience, engagement ou qualité qui ne s'y trouve pas.
- **Ce qui manque est marqué [À COMPLÉTER]** à l'endroit où l'information irait (ex. « [À COMPLÉTER] références »). N'écrivez pas de phrase qui contourne le manque. Dites ensuite à l'artisan quelles informations manquent et proposez de compléter la fiche.
- **Références** : citez celles de la fiche, de préférence celles pour des acheteurs publics. Ne citez pas de montant si l'artisan ne le veut pas ; sinon recopiez-le tel quel. Certification dont la validité est dépassée : ne la citez pas comme valable.
- Ne donnez ni le chiffre d'affaires ni les assurances par défaut : ce sont des pièces de candidature, pas de présentation. Ne les ajoutez que si l'artisan le demande.
- **Pas de prix.** Ne proposez aucun tarif ni devis.
- Ne mentionnez aucun mot de passe ni aucune plateforme.

Gabarit (recopiez les faits de la fiche, laissez [À COMPLÉTER] ce qui manque) :

```markdown
# Lettre de présentation

[Nom de l'entreprise]
[Adresse]
[Téléphone] · [E-mail] · SIRET [SIRET]

À l'attention des services techniques de [Nom de l'acheteur]

[Commune], le [date]

Objet : présentation de mon entreprise

Madame, Monsieur,

Je me permets de vous présenter [Nom de l'entreprise], entreprise de [métiers] installée à [commune]. Nous intervenons dans les départements suivants : [départements].

Nous sommes titulaires des certifications suivantes : [une ligne par certification, avec numéro et validité].

Parmi nos réalisations récentes :
- [année], [acheteur ou client] : [travaux], à [commune], [montant] € HT ;
- …

[Si l'effectif est renseigné : « L'entreprise compte [n] personnes. »]

Si vous avez des travaux de [métiers] à réaliser, je serais heureux d'être consulté. Je reste à votre disposition pour vous rencontrer ou vous envoyer toute pièce utile.

Veuillez agréer, Madame, Monsieur, l'expression de mes salutations distinguées.

[Nom du dirigeant]
```

Le nom du dirigeant n'est pas dans la fiche : laissez [À COMPLÉTER] s'il manque, puis demandez-le (une question).

Enregistrez la lettre dans `se-faire-connaitre/lettre-de-presentation.md` du dossier de travail. Si elle existe déjà, ne l'écrasez pas : créez `lettre-de-presentation-2.md` (puis `-3`…) ou, si l'artisan demande une modification, modifiez-la.

## 4. Pour finir

Dites à l'artisan où se trouve la lettre (le nom du dossier, pas un chemin technique) et rappelez que c'est lui qui l'envoie : par courrier ou par e-mail au service technique de chaque acheteur. Proposez de la relire avec lui, ou de compléter sa fiche pour remplacer les [À COMPLÉTER]. Ne suggérez pas de relance automatique.
