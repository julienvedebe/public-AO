# Installation de l'outil « Marchés publics »

Ce fichier s'adresse à l'agent (Claude Code ou Codex) qui installe l'outil sur l'ordinateur d'un artisan. Suivez les étapes dans l'ordre.

## Règles pendant toute l'installation

- L'artisan n'est pas informaticien. **Avant chaque étape**, dites-lui en une phrase simple, en le vouvoyant, ce que vous allez faire et pourquoi. Pas de jargon : dites « je télécharge l'outil », pas « je récupère l'archive ».
- Ne modifiez **rien** en dehors de ce que décrit ce fichier : le dossier de l'outil dans vos skills, le dossier de travail de l'artisan et un dossier temporaire.
- Ne demandez jamais de mot de passe et n'installez aucun autre logiciel.
- Si une étape échoue, arrêtez-vous, expliquez simplement ce qui bloque et ce que l'artisan peut faire (par exemple : vérifier sa connexion internet), puis attendez sa réponse.
- Si l'artisan dit « mettez à jour l'outil marchés publics », suivez ce même fichier : l'étape 3 remplace l'outil, l'étape 4 ne touche à rien d'existant. Le dossier de travail doit rester identique, fichier pour fichier.

## Étape 1 : vérifier où vous tournez

Cette installation prend en charge **Claude Code** et **Codex**, sur **Mac** et sur **Windows**. Relevez deux choses :

- **L'agent** : vous savez si vous êtes Claude Code ou Codex.
- **Le système** : sur Mac ou Linux, `uname` répond `Darwin` (Mac) ; sous Windows, vous travaillez dans PowerShell (la variable `$env:OS` vaut `Windows_NT`).

Ces deux réponses fixent le dossier où installer l'outil (dossier personnel : `~` sur Mac, `%USERPROFILE%` sous Windows) :

| Agent | Mac | Windows |
|---|---|---|
| Claude Code | `~/.claude/skills/marches-publics` | `%USERPROFILE%\.claude\skills\marches-publics` |
| Codex | `~/.agents/skills/marches-publics` | `%USERPROFILE%\.agents\skills\marches-publics` |

Si vous êtes sur un autre système (Linux, par exemple), dites à l'artisan : « Cette installation n'est pas prête pour votre ordinateur. Prévenez votre formateur, il vous aidera. » et arrêtez-vous.

Sous Windows, les commandes ci-dessous sont à lancer dans PowerShell.

## Étape 2 : télécharger l'outil

Si la variable d'environnement `MARCHES_PUBLICS_SOURCE` est définie, elle désigne un dossier qui contient déjà le dépôt : utilisez-le comme `<source>` et passez à l'étape 3. Elle sert aux tests ; ne la mentionnez pas à l'artisan.

Sinon, choisissez la méthode : **git** s'il est présent et utilisable, sinon l'**archive ZIP**. Le dépôt est public : aucun identifiant n'est nécessaire.

**Attention, Mac** : sur un Mac sans outils de développement, la commande `git` existe mais ouvre une fenêtre d'installation qui perdrait l'artisan. Ne lancez donc jamais `git` avant d'avoir vérifié `xcode-select -p`. Si cette commande échoue, git n'est pas utilisable : prenez l'archive ZIP.

### Mac : git s'il est utilisable

```bash
TMP=$(mktemp -d)
if xcode-select -p >/dev/null 2>&1 && git --version >/dev/null 2>&1; then
  git clone --depth 1 https://github.com/julienvedebe/public-AO.git "$TMP/public-AO"
  SOURCE="$TMP/public-AO"
else
  curl -fsSL -o "$TMP/outil.zip" https://github.com/julienvedebe/public-AO/archive/refs/heads/main.zip
  unzip -q "$TMP/outil.zip" -d "$TMP"
  SOURCE="$TMP/public-AO-main"
fi
```

### Windows : git s'il est utilisable

```powershell
$Tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("marches-publics-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $Tmp | Out-Null
if (Get-Command git -ErrorAction SilentlyContinue) {
  git clone --depth 1 https://github.com/julienvedebe/public-AO.git "$Tmp\public-AO"
  $Source = "$Tmp\public-AO"
} else {
  curl.exe -fsSL -o "$Tmp\outil.zip" https://github.com/julienvedebe/public-AO/archive/refs/heads/main.zip
  Expand-Archive -Path "$Tmp\outil.zip" -DestinationPath $Tmp
  $Source = "$Tmp\public-AO-main"
}
```

Si le clonage échoue (réseau coupé, par exemple), essayez l'archive ZIP avant d'abandonner.

`<source>` désigne ensuite le dossier du dépôt (`$SOURCE` ou `$Source`). Vérifiez que `<source>/skill/marches-publics/SKILL.md` existe.

## Étape 3 : installer l'outil

Le dossier de destination est celui du tableau de l'étape 1, sauf si la variable d'environnement `MARCHES_PUBLICS_SKILLS_DIR` est définie : utilisez alors `$MARCHES_PUBLICS_SKILLS_DIR/marches-publics`, quel que soit l'agent.

Remplacez entièrement l'ancienne version s'il y en a une, puis copiez la nouvelle. Ne touchez à rien d'autre que ce dossier `marches-publics`.

Mac, Claude Code (pour Codex, remplacez `.claude` par `.agents`) :

```bash
DEST="${MARCHES_PUBLICS_SKILLS_DIR:-$HOME/.claude/skills}/marches-publics"
mkdir -p "$(dirname "$DEST")"
rm -rf "$DEST"
cp -R "$SOURCE/skill/marches-publics" "$DEST"
```

Windows, Claude Code (pour Codex, remplacez `.claude` par `.agents`) :

```powershell
$Base = if ($env:MARCHES_PUBLICS_SKILLS_DIR) { $env:MARCHES_PUBLICS_SKILLS_DIR } else { Join-Path $env:USERPROFILE ".claude\skills" }
$Dest = Join-Path $Base "marches-publics"
New-Item -ItemType Directory -Force -Path $Base | Out-Null
if (Test-Path $Dest) { Remove-Item -Recurse -Force $Dest }
Copy-Item -Recurse "$Source\skill\marches-publics" $Dest
```

Vérifiez que `SKILL.md` existe dans le dossier de destination.

## Étape 4 : préparer le dossier de travail

Lisez `<source>/skill/marches-publics/references/dossier-de-travail.md` et créez le dossier de travail comme il le décrit. Il honore aussi la variable `MARCHES_PUBLICS_DOSSIER`. Créez seulement ce qui manque : **ne touchez à aucun fichier existant**, c'est le travail de l'artisan.

## Étape 5 : nettoyer

Si vous avez créé un dossier temporaire à l'étape 2, supprimez-le (`rm -rf "$TMP"` sur Mac, `Remove-Item -Recurse -Force $Tmp` sous Windows).

## Étape 6 : passer la main à l'artisan

Dites-lui, en mots simples :

1. que l'outil est installé ;
2. où se trouve son dossier « Marchés publics » (dans ses Documents) et qu'il y retrouvera tout son travail ;
3. pour vérifier que tout marche : **ouvrir une nouvelle conversation** et écrire « bonjour marchés publics ». Il doit voir un message d'accueil avec un menu numéroté.
