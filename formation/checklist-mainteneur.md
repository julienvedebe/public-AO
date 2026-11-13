# Checklist du mainteneur : dépôt public et branche protégée

Ce document est pour le mainteneur, pas pour les artisans. Les gestes sur GitHub sont les siens : ni les agents ni les contributeurs ne les font. Pourquoi : `INSTALL.md` est exécuté par l'agent de chaque artisan, donc seul le mainteneur doit pouvoir modifier la branche principale (voir `docs/adr/0001-agents-locaux-installes-depuis-le-depot.md`).

## 1. Dépôt public

- [x] Le dépôt `julienvedebe/public-AO` est public (fait le 13/11/2026).
- [x] Aucun secret ni donnée d'artisan dans le dépôt ni dans son historique. À re-vérifier avant chaque diffusion : `git log -p | grep -iE "password|token|secret|iban"`.
- [ ] La licence MIT est présente (`LICENSE`) et le nom qui y figure (« jvdb ») est confirmé ou corrigé.

## 2. Protection de la branche `main`

Réglage : Settings, Branches, « Add branch protection rule » (ou Rulesets) sur `main`. À faire avant d'envoyer le QR code.

- [ ] Pas de push direct sur `main` : « Require a pull request before merging ».
- [ ] Au moins une approbation du mainteneur avant la fusion.
- [ ] Pas de force-push : « Allow force pushes » désactivé.
- [ ] Pas de suppression de la branche : « Allow deletions » désactivé.
- [ ] La règle s'applique aussi aux administrateurs (« Do not allow bypassing the above settings »). Si ce n'est pas souhaité, cocher la case en connaissance de cause : le mainteneur pourrait alors pousser sans PR.
- [ ] Vérification : tenter `git push origin main` avec un commit de test sur une copie locale. Le refus doit apparaître. Annuler ensuite le commit de test.

## 3. Qui peut écrire

- [ ] Settings, Collaborators and teams : la liste des personnes avec droit d'écriture est relue. Seul le mainteneur a le droit « Write » ou plus. Tout autre contributeur passe par un fork et une PR.
- [ ] Le droit de fusion d'une PR reste au mainteneur.
- [ ] Authentification à deux facteurs active sur le compte du mainteneur.

## 4. Avant d'envoyer le QR code aux artisans

- [ ] **Installation testée sur machine vierge dans les quatre combinaisons** (ticket #13) :
  - [ ] Claude Code sur Mac
  - [ ] Claude Code sur Windows
  - [ ] Codex sur Mac
  - [ ] Codex sur Windows

  Pour chacune : message d'installation collé, `bonjour marchés publics` dans une nouvelle conversation, accueil + menu de 1 à 7 + état de la fiche. Noter les demandes d'autorisation réelles et corriger [autorisations.md](autorisations.md) (les intitulés exacts n'ont pas été vérifiés).
- [ ] **Seuils revérifiés** : relire `skill/marches-publics/references/seuils.md` (dernière vérification : 13/11/2026) contre les sources officielles citées, et mettre la date à jour.
- [ ] **API du BOAMP revérifiée** : rejouer les requêtes de `skill/marches-publics/references/api-boamp.md` (requête de la veille, lecture d'un avis, pièges des départements) et vérifier que les champs existent toujours.
- [ ] Les liens du dépôt fonctionnent : `curl -sI https://raw.githubusercontent.com/julienvedebe/public-AO/main/INSTALL.md` et `curl -sI https://github.com/julienvedebe/public-AO` répondent 200.
- [ ] Le QR code est fabriqué et testé (voir [qr-code.md](qr-code.md)) : il s'ouvre sur un téléphone et le message d'installation s'y copie.
- [ ] Le test de contrôle [test-de-controle.md](test-de-controle.md) est envoyé aux artisans une semaine avant la formation.
- [ ] Les intitulés d'autorisation de [autorisations.md](autorisations.md) sont confirmés par le pilote.
