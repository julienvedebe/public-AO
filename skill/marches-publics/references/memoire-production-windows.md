# Mémoire technique : production du fichier sur Windows

Cette fiche est la seule partie du mémoire qui dépend du système. Elle transforme le `memoire.html` écrit à l'étape 4 de [memoire-technique.md](memoire-technique.md) en `.docx`, avec PowerShell, qui est livré avec Windows. Rien à installer : ni Word, ni LibreOffice, ni Python.

## Commande

Le script est `scripts\memoire-vers-docx-windows.ps1`, dans le dossier de l'outil, à côté de `SKILL.md`. Lancez-le dans PowerShell, en donnant le HTML et le chemin du `.docx` à créer (dans le sous-dossier de la consultation) :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<dossier de l'outil>\scripts\memoire-vers-docx-windows.ps1" "<dossier temporaire>\memoire.html" "<dossier de la consultation>\memoire-technique.docx"
```

Les chemins contiennent des accents et des espaces (`Marchés publics`) : gardez les guillemets. Écrivez toujours les chemins en clair : les variables ne sont pas conservées d'une commande à l'autre.

Pourquoi cette forme :

- **`powershell`** lance Windows PowerShell 5.1, présent sur tous les Windows 10 et 11. Le script marche aussi avec PowerShell 7 (`pwsh`), mais il n'est pas nécessaire.
- **`-ExecutionPolicy Bypass`** vaut **pour cette seule commande**. Par défaut, Windows refuse de lancer un fichier de script (`.ps1`) ; sans cette option, la commande échouerait avant même de commencer. Elle ne change rien aux réglages de l'ordinateur. **Ne modifiez jamais la politique d'exécution de l'ordinateur** (`Set-ExecutionPolicy`) : c'est un réglage de sécurité qui n'est pas à vous. Si l'ordinateur de l'artisan l'interdit quand même (réglage de son entreprise), le script ne se lance pas : voir le tableau ci-dessous.
- **`-NoProfile`** n'exécute pas le profil PowerShell de l'artisan : le résultat est le même sur tous les ordinateurs.
- **`-File`** passe les deux chemins au script tels quels.

Le dossier temporaire se crée avant (étape 4 de memoire-technique.md) et se supprime après :

```powershell
$Tmp = Join-Path $env:TEMP ("memoire-" + [guid]::NewGuid().ToString("N")); New-Item -ItemType Directory -Path $Tmp | Out-Null; $Tmp
```

Écrivez `memoire.html` dans ce dossier en UTF-8 (avec l'outil d'écriture de fichiers de l'agent, pas avec `Set-Content` ni `Out-File`, qui peuvent abîmer les accents sous Windows PowerShell 5.1).

Le script :

1. lit le HTML (titres, paragraphes, listes, gras, italique, et tableaux simples s'il y en a) ;
2. assemble lui-même un `.docx` minimal (une archive ZIP de fichiers XML) avec l'API .NET de compression, et **non** avec `Compress-Archive` ;
3. **surligne en jaune** chaque [À COMPLÉTER], en plus de le garder en gras rouge ;
4. contrôle le résultat : il relit l'archive, vérifie que le XML est valide et compte les [À COMPLÉTER] surlignés ;
5. n'écrase jamais un fichier existant.

La dernière ligne affichée dit ce qui a été produit : `DOCX <chemin> <n>` (n passages surlignés) ou `RTF <chemin> <n>`.

| Code de sortie | Sens | Que faire |
|---|---|---|
| 0 | `.docx` produit et contrôlé | Rendez compte (étape 7 de memoire-technique.md). |
| 10 | La production du `.docx` a échoué ; un `.rtf` de secours est produit, avec le même nom | Donnez le `.rtf` à l'artisan, en disant en une phrase que c'est une version plus simple du même document, que Word et LibreOffice ouvrent. Ne cachez pas l'échec. |
| 4 | Le fichier existe déjà | Choisissez un autre nom (`memoire-technique-2.docx`) et relancez. Ne supprimez rien. |
| 2, 3 | HTML introuvable, dossier de sortie absent, ou rien n'a pu être écrit : aucun fichier produit | Dites-le simplement ; gardez le HTML (copiez-le dans le sous-dossier de la consultation sous le nom `memoire-technique.html`) et expliquez qu'il s'ouvre avec Word : le surlignage y est conservé. |
| autre (1, par exemple) ou message disant que l'exécution de scripts est désactivée | Le script n'a pas pu démarrer (réglage de l'ordinateur, antivirus) : aucun fichier produit | Même chose que 2 et 3. N'essayez pas de contourner le réglage. |

Si l'artisan demande lui-même un `.rtf` plutôt qu'un `.docx` (son ordinateur ou ses logiciels ne lisent pas le Word), ajoutez `MEMOIRE_FORCER_ECHEC_DOCX` dans la même commande : le script produit directement le `.rtf` surligné (code 10).

```powershell
$env:MEMOIRE_FORCER_ECHEC_DOCX = "1"; powershell -NoProfile -ExecutionPolicy Bypass -File "<...>\memoire-vers-docx-windows.ps1" "<...>\memoire.html" "<...>\memoire-technique.docx"; Remove-Item Env:MEMOIRE_FORCER_ECHEC_DOCX
```

## Ce que contient le `.docx`

Un `.docx` est une archive ZIP. Celui-ci contient `[Content_Types].xml`, `_rels\.rels`, `word\document.xml`, `word\styles.xml` (styles « Titre 1 » à « Titre 3 », paragraphe de liste, tableau), `word\numbering.xml` (puces et numérotation) et `word\_rels\document.xml.rels`.

- Titres `h1` à `h3` : vrais styles « Titre 1 » à « Titre 3 » de Word.
- Passage à compléter : texte en gras rouge avec `<w:highlight w:val="yellow"/>`. Un [À COMPLÉTER] écrit sans le balisage prévu est quand même surligné.
- Accents : XML en UTF-8 sans BOM. Le script ne contient lui-même que de l'ASCII, car Windows PowerShell 5.1 lit un script sans BOM en cp1252.
- Tableaux (`table`, `tr`, `th`, `td`) : rendus en vrais tableaux Word. Le gabarit n'en contient pas (comme sur Mac), donc le mémoire n'en a pas en pratique.

Le `.rtf` de secours est écrit à la main par le script (en-tête `\rtf1\ansi\ansicpg1252`, accents en `\'e9` ou `\uNNNN?`, surlignage `\highlight1` avec une table de couleurs), à partir du même HTML.

## Remplir le cadre de l'acheteur

Seulement si le DCE contient un cadre de mémoire de l'acheteur ([memoire-cadre-acheteur.md](memoire-cadre-acheteur.md)). Le script est `scripts\cadre-acheteur-windows.ps1`, à côté du premier. Il lit et recompose le `.docx` lui-même (une archive ZIP de fichiers XML) avec l'API .NET de compression : **Word n'est jamais ouvert**. Le pilotage de Word par un script peut se bloquer sans rendre la main (constaté en test sous Windows) ; n'essayez pas de le faire vous-même.

D'abord, lister les paragraphes du cadre (pour écrire `reponses-cadre.txt`) :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<dossier de l'outil>\scripts\cadre-acheteur-windows.ps1" lister "<dossier de la consultation>\dce\<…>\<cadre>.docx"
```

Puis remplir une copie, à côté de notre mémoire :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<dossier de l'outil>\scripts\cadre-acheteur-windows.ps1" remplir "<dossier de la consultation>\dce\<…>\<cadre>.docx" "<dossier temporaire>\reponses-cadre.txt" "<dossier de la consultation>\memoire-technique-cadre-acheteur.docx"
```

Écrivez `reponses-cadre.txt` en UTF-8 avec l'outil d'écriture de fichiers de l'agent (pas avec `Set-Content` ni `Out-File`). Le script fait les mêmes contrôles que sur Mac (bon paragraphe, limite de caractères, XML lisible, texte de l'acheteur intact, autres parties du `.docx` identiques, [À COMPLÉTER] surlignés) et n'écrase jamais rien. Différence avec le Mac : sans Word, seul le `.docx` est pris en charge ; un cadre en `.doc`, `.odt` ou `.rtf` donne le code 5, et c'est la solution de secours qui s'applique.

Codes de sortie et conduite à tenir : [memoire-cadre-acheteur.md](memoire-cadre-acheteur.md) § 5.

## Ce qui n'est pas vérifié

Au moment de l'écriture de cette fiche, le script n'a **pas** été exécuté sur un vrai Windows, et le `.docx` n'a été ouvert ni dans Word ni dans LibreOffice : la structure attendue a été validée sur Mac (`xmllint`, `unzip`, `textutil`) à partir de fichiers XML écrits à la main. Comme sur Mac, vous ne dites donc pas à l'artisan que le fichier « s'ouvre sans problème dans Word » : vous dites que vous l'avez contrôlé et qu'il vous prévienne si quelque chose s'affiche mal.

Le script `cadre-acheteur-windows.ps1` n'a pas non plus été exécuté sur un vrai Windows : c'est la transcription du script Mac, essayé, lui, sur le cadre fictif du scénario `memoire-cadre-acheteur`. Le scénario `memoire-windows` contient les essais à lancer sous Windows.
