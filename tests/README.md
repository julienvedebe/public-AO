# Tests de scénarios

Chaque scénario lance une vraie conversation sans interface (`claude -p`) dans un dossier temporaire, puis vérifie ce que l'artisan verrait : les fichiers produits et le contenu de la réponse, jamais la formulation exacte.

```bash
CLAUDE_BIN=/chemin/vers/claude tests/run.sh                  # tous les scénarios
CLAUDE_BIN=/chemin/vers/claude tests/run.sh premier-lancement
GARDER=1 tests/run.sh installation                         # garde le dossier temporaire
```

Un scénario est un dossier de `tests/scenarios/` qui contient :

- `prompt.txt` : le message de l'artisan (`{{ROOT}}` est remplacé par la racine du dépôt) ;
- `check.sh` : les vérifications, écrites avec les fonctions de `tests/lib.sh` ;
- `dossier/` (facultatif) : le dossier de travail de départ ;
- `sans-preinstallation` (facultatif) : ne préinstalle pas le skill (scénarios d'installation).

Le harnais isole chaque scénario grâce à trois variables d'environnement, honorées par le skill et par `INSTALL.md` : `MARCHES_PUBLICS_DOSSIER` (dossier de travail), `MARCHES_PUBLICS_SKILLS_DIR` (destination de l'installation) et `MARCHES_PUBLICS_SOURCE` (dépôt local à installer au lieu de le télécharger).

Les scénarios tournent avec `--permission-mode bypassPermissions`, dans un dossier temporaire : ne les lancez qu'avec les prompts de ce dépôt.
