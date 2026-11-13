# Installation de l'outil « Marchés publics »

Ce fichier s'adresse à l'agent (Claude Code ou Codex) qui installe l'outil sur l'ordinateur d'un artisan. Suivez les étapes dans l'ordre.

## Règles pendant toute l'installation

- L'artisan n'est pas informaticien. **Avant chaque étape**, dites-lui en une phrase simple, en le vouvoyant, ce que vous allez faire et pourquoi. Pas de jargon : dites « je télécharge l'outil », pas « je récupère l'archive ».
- Ne modifiez **rien** en dehors de ce que décrit ce fichier : le dossier de l'outil dans vos skills, le dossier de travail de l'artisan et un dossier temporaire.
- Ne demandez jamais de mot de passe et n'installez aucun autre logiciel.
- Si une étape échoue, arrêtez-vous, expliquez simplement ce qui bloque et ce que l'artisan peut faire (par exemple : vérifier sa connexion internet), puis attendez sa réponse.
- Si l'artisan dit « mettez à jour l'outil marchés publics », suivez ce même fichier : l'étape 3 remplace l'outil, l'étape 4 ne touche à rien d'existant.

## Étape 1 : vérifier où vous tournez

Cette version de l'installation prend en charge **Claude Code sur Mac**.

- Si vous êtes Claude Code sur Mac, continuez.
- Sinon (Codex, ou Windows), dites à l'artisan : « Cette installation n'est pas encore prête pour votre ordinateur. Prévenez votre formateur, il vous aidera. » et arrêtez-vous.

## Étape 2 : télécharger l'outil

Si la variable d'environnement `MARCHES_PUBLICS_SOURCE` est définie, elle désigne un dossier qui contient déjà le dépôt : utilisez-le comme `<source>` et passez à l'étape 3. Elle sert aux tests ; ne la mentionnez pas à l'artisan.

Sinon, téléchargez l'archive du dépôt dans un dossier temporaire, sans utiliser git : sur un Mac sans outils de développement, git ouvrirait une fenêtre d'installation qui perdrait l'artisan.

```bash
TMP=$(mktemp -d)
curl -fsSL -o "$TMP/outil.zip" https://github.com/julienvedebe/public-AO/archive/refs/heads/main.zip
unzip -q "$TMP/outil.zip" -d "$TMP"
```

`<source>` est le seul dossier créé dans `$TMP` par la décompression (il se nomme `public-AO-main`).

## Étape 3 : installer l'outil

Le dossier de destination est `~/.claude/skills/marches-publics`, sauf si la variable d'environnement `MARCHES_PUBLICS_SKILLS_DIR` est définie : utilisez alors `$MARCHES_PUBLICS_SKILLS_DIR/marches-publics`.

Remplacez entièrement l'ancienne version s'il y en a une, puis copiez la nouvelle :

```bash
DEST="${MARCHES_PUBLICS_SKILLS_DIR:-$HOME/.claude/skills}/marches-publics"
mkdir -p "$(dirname "$DEST")"
rm -rf "$DEST"
cp -R "<source>/skill/marches-publics" "$DEST"
```

Vérifiez que `$DEST/SKILL.md` existe.

## Étape 4 : préparer le dossier de travail

Lisez `<source>/skill/marches-publics/references/dossier-de-travail.md` et créez le dossier de travail comme il le décrit. Il honore aussi la variable `MARCHES_PUBLICS_DOSSIER`. Créez seulement ce qui manque : **ne touchez à aucun fichier existant**, c'est le travail de l'artisan.

## Étape 5 : nettoyer

Si vous avez créé un dossier temporaire à l'étape 2, supprimez-le.

## Étape 6 : passer la main à l'artisan

Dites-lui, en mots simples :

1. que l'outil est installé ;
2. où se trouve son dossier « Marchés publics » (dans ses Documents) et qu'il y retrouvera tout son travail ;
3. pour vérifier que tout marche : **ouvrir une nouvelle conversation** et écrire « bonjour marchés publics ». Il doit voir un message d'accueil avec un menu numéroté.
