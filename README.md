# Marchés publics pour artisans

Un outil d'IA qui aide les artisans du bâtiment à trouver des consultations publiques et à y répondre. Il fonctionne dans Claude Code ou dans Codex, sur Mac et sur Windows.

## Installer

Il vous faut Claude ou ChatGPT (application pour ordinateur) avec un compte actif. Les prérequis complets sont dans [formation/prerequis.md](formation/prerequis.md).

Ouvrez une conversation dans Claude Code (ou dans Codex) et collez ce message :

```text
Installe l'outil Marchés publics : lis https://raw.githubusercontent.com/julienvedebe/public-AO/main/INSTALL.md et suis-le étape par étape. Ne modifie rien sur mon ordinateur en dehors de ce qu'il demande, et explique-moi chaque étape simplement.
```

Ensuite, ouvrez une nouvelle conversation et écrivez « bonjour marchés publics ».

Si une fenêtre vous demande une autorisation, lisez la fiche [formation/autorisations.md](formation/autorisations.md).

## Mettre à jour

Écrivez « mettez à jour l'outil marchés publics ». Vos fichiers ne sont jamais modifiés par une mise à jour.

## Formation

Les supports remis aux artisans sont dans [formation/](formation/README.md) : prérequis, prompt d'installation et QR code, test de contrôle, autorisations à accepter, ce qui transite chez le fournisseur d'IA. La checklist du mainteneur est dans [formation/checklist-mainteneur.md](formation/checklist-mainteneur.md).

## Pour les contributeurs

- Le skill est dans `skill/marches-publics/`.
- L'installation est décrite pour l'agent dans `INSTALL.md`.
- Les tests de scénarios sont dans `tests/` (voir `tests/README.md`).
- Vocabulaire : `GLOSSARY.md`. Décisions : `docs/adr/`.

## Licence

Ce dépôt est publié sous licence MIT : voir [LICENSE](LICENSE).
