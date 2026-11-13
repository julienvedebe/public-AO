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
└── suivi.md                   ← tableau de suivi des consultations
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

Une consultation passe par ces statuts, dans la colonne « Statut » du suivi : `repérée`, `analysée`, `en préparation`, `déposée`, `gagnée` ou `perdue`, `bilan fait`.
