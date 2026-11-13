# Dossier de travail

Le dossier de travail est la seule mémoire de l'outil d'une conversation à l'autre. L'artisan doit pouvoir l'ouvrir lui-même dans le Finder ou l'Explorateur.

## Où il se trouve

1. Si la variable d'environnement `MARCHES_PUBLICS_DOSSIER` est définie, utilisez ce chemin tel quel. Elle sert aux tests ; ne la mentionnez jamais à l'artisan.
2. Sinon, c'est le dossier `Marchés publics` dans les Documents de l'artisan :
   - Mac : `~/Documents/Marchés publics`
   - Windows : le dossier Documents réel peut être déplacé dans OneDrive. Obtenez-le avec PowerShell `[Environment]::GetFolderPath('MyDocuments')`, puis ajoutez `Marchés publics`.

## Contenu

```
Marchés publics/
├── ma-fiche-entreprise.md     ← créée à l'étape « fiche entreprise », absente au départ
├── mes-justificatifs/         ← Kbis, attestations URSSAF et fiscale, assurances
├── consultations/             ← un sous-dossier par consultation
├── se-faire-connaitre/        ← créé à l'étape « se faire connaître » (acheteurs.md, lettre-de-presentation.md)
└── suivi.md                   ← tableau de suivi des consultations, puis leçons des bilans
```

Un sous-dossier de consultation contient, selon l'avancement :

```
2026-12_mairie-de-villeurbanne_lot-05-plomberie/
├── dce/                           ← le DCE décompressé (étape analyse)
├── dce-texte/                     ← le texte extrait des pièces utiles, relu par les étapes suivantes (étape analyse)
├── analyse.md                     ← l'analyse et le verdict (étape analyse)
├── pieces-et-retroplanning.md     ← les pièces à fournir et le rétroplanning (étape pièces)
├── memoire-reponses.md           ← les réponses de l'artisan pour le mémoire, enregistrées au fur et à mesure (étape mémoire technique)
├── memoire-technique.docx        ← le mémoire, ou memoire-technique.rtf de secours ; jamais écrasé : -2, -3… (étape mémoire technique)
├── l'accusé de réception du dépôt ← que l'artisan y range lui-même (étape suivi)
└── courrier-demande-motifs.md     ← après un rejet (étape bilan)
```

Un sous-dossier de consultation se nomme `AAAA-MM_acheteur_lot`, en minuscules, sans accents ni espaces. Exemple : `2026-12_mairie-de-villeurbanne_lot-05-plomberie`.

## Création

Créez les éléments manquants, et uniquement eux. **N'écrasez, ne déplacez et ne supprimez jamais** un fichier existant de ce dossier.

Contenu initial de `suivi.md` :

```markdown
# Suivi de mes consultations

| Consultation | Acheteur | Date limite | Statut | Verdict | Notes |
|---|---|---|---|---|---|
```

## Statuts

Une consultation passe par ces statuts, dans la colonne « Statut » du suivi : `repérée`, `analysée`, puis `déclinée` (l'artisan a choisi de ne pas répondre, après l'analyse) ou `en préparation`, `déposée`, `gagnée` ou `perdue`, `bilan fait`. Ils s'écrivent en minuscules, avec accents. Une consultation `déclinée` reste dans le suivi : la veille ne la repropose pas, et l'artisan peut changer d'avis tant que la date limite n'est pas passée.

## Le suivi après le tableau

- **Colonne Notes** : texte libre, à compléter à la suite sans rien effacer : lien de l'avis (`Avis : …`), lien du DCE, dates des événements (`déposée le 12/01/2027`, `perdue le 25/01/2027`), titulaire retenu et montant trouvés au bilan (`Titulaire : … (commune), … € HT, notifié le …`) ou `Attribution non trouvée dans les DECP au …`.
- **Section `## Leçons`**, après le tableau, créée au premier bilan : une entrée `### Titre de la consultation (perdue le JJ/MM/AAAA)` par bilan, avec le titulaire retenu et les leçons de l'artisan (voir [bilan.md](bilan.md)). Les nouvelles lignes de consultation se placent à la suite de la dernière ligne du tableau, **avant** cette section.
