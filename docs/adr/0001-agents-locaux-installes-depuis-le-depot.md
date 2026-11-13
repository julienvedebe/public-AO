# L'outil tourne dans Claude Code ou Codex, installé depuis le dépôt par un prompt

Les artisans utilisent surtout ChatGPT, mais les skills natifs de ChatGPT ne sont pas ouverts aux abonnements Plus, et un GPT public ne peut ni garder de fichiers locaux ni lire un DCE en ZIP de façon fiable. La formation exige donc Claude ou ChatGPT en version desktop, avec leur agent de code (Claude Code ou Codex). L'outil y est installé comme un skill unique, au format Agent Skills, par un prompt court qui demande à l'agent de suivre `INSTALL.md` dans le dépôt public. Ce mécanisme est le même pour les deux agents, plutôt que la marketplace de plugins de Claude et le `$skill-installer` de Codex.

## Conséquences

- L'agent tourne sur la machine de l'artisan : il peut interroger l'API du BOAMP, décompresser un DCE et tenir un dossier de travail local qui sert de mémoire d'une conversation à l'autre.
- `INSTALL.md` est exécuté par l'agent de chaque artisan : seul le mainteneur doit pouvoir écrire sur la branche principale.
- L'installation se fait avant la formation, avec un test de contrôle.
