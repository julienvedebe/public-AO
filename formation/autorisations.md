# Quelles autorisations accepter

Pendant l'installation et l'usage, votre ordinateur vous demande la permission avant chaque action de l'assistant. C'est normal et c'est une protection : c'est vous qui décidez.

**La règle simple** : acceptez ce qui concerne l'outil « Marchés publics » et votre dossier « Marchés publics ». Refusez tout le reste, et appelez votre formateur.

## Ce que l'assistant va demander

| Ce qu'il fait | Ce que vous verrez | Réponse |
|---|---|---|
| Lire le fichier d'installation sur GitHub (`raw.githubusercontent.com`) | une demande d'accès à un site internet | **Oui** |
| Vérifier votre ordinateur (Mac ou Windows) | une commande courte comme `uname` ou `xcode-select -p` | **Oui** |
| Télécharger l'outil depuis GitHub | une commande avec `git clone` ou `curl`, adresse `github.com/julienvedebe/public-AO` | **Oui** |
| Ouvrir le fichier téléchargé | une commande avec `unzip` (Mac) ou `Expand-Archive` (Windows) | **Oui** |
| Copier l'outil dans le dossier des « skills » (les compétences de l'assistant) | une commande avec `cp` ou `Copy-Item`, vers `.claude/skills/marches-publics` (Claude) ou `.agents/skills/marches-publics` (Codex) | **Oui** |
| Remplacer l'ancienne version lors d'une mise à jour | une commande avec `rm -rf` ou `Remove-Item` sur ce même dossier `marches-publics` | **Oui**, seulement si le chemin se termine par `marches-publics` |
| Créer votre dossier de travail | création de `Documents/Marchés publics` et de fichiers dedans | **Oui** |
| Ranger l'installation | suppression d'un dossier temporaire | **Oui**, si c'est le dossier temporaire créé par l'installation |
| Chercher des consultations | une commande `curl` vers `boamp-datadila.opendatasoft.com` | **Oui** |
| Lire un dossier de consultation (DCE) que vous avez déposé | lecture de fichiers dans `Documents/Marchés publics`, parfois `unzip`, `textutil` ou `osascript` (Mac, pour lire un PDF) ou une commande PowerShell pour lire un Word ou un PDF | **Oui** |
| Retrouver qui a gagné une consultation (bilan) | une commande `curl` vers `data.economie.gouv.fr` (données des marchés attribués) ou `recherche-entreprises.api.gouv.fr` (nom d'une entreprise) | **Oui** |
| Écrire vos fiches, analyses et lettres | écriture de fichiers dans `Documents/Marchés publics` | **Oui** |

## Ce qu'il faut refuser

Répondez **non** si l'assistant demande :

- un **mot de passe**, un code, un identifiant de plateforme ou un numéro de carte ;
- d'**installer un autre logiciel** (`brew`, `pip`, `winget`, `npm`, ou un téléchargement) ;
- de **supprimer** ou modifier des fichiers en dehors du dossier `marches-publics` des skills et de votre dossier « Marchés publics » ;
- de lire ou écrire dans **un autre dossier** (Photos, Mail, Bureau, Téléchargements en entier…). Seule exception : il vous demande un fichier précis que vous venez de lui indiquer ;
- d'aller sur **un autre site** que ceux de la liste ci-dessus ;
- d'**envoyer un e-mail** ou un message à votre place ;
- de lancer une commande avec `sudo` ou en administrateur ;
- de **changer un réglage** de votre ordinateur ou de l'application.

Refuser ne casse rien. L'assistant vous expliquera ce qu'il ne peut pas faire.

## Les options qui ne disent pas « oui » ou « non »

Ne choisissez pas les modes qui suppriment les demandes d'autorisation : « passer en mode automatique » (Claude), « accès complet » ou « sans approbation » (Codex). Ces modes ne sont pas faits pour vous : vous perdriez le contrôle.

L'option « Oui, et ne plus demander » est possible **uniquement** pour les recherches sur les sites publics de la liste (`curl` vers `boamp-datadila.opendatasoft.com`, `data.economie.gouv.fr` ou `recherche-entreprises.api.gouv.fr`), qui reviennent souvent. Pour tout le reste, choisissez « Oui » simple.

---

## Dans Claude Code

Les demandes ont cette forme (d'après la documentation officielle) : un titre (par exemple « Bash command »), ce que l'assistant veut faire, puis la question **« Do you want to proceed? »** avec ces choix :

- **Yes** : autoriser cette fois.
- **Yes, and don't ask again for…** : autoriser et ne plus demander pour cette commande.
- **Yes, and switch to auto mode** : (n'apparaît pas toujours) à ne **pas** choisir.
- **No** : refuser.

Vous pouvez refuser avec la touche Échap. Les lectures simples (voir le contenu d'un dossier de travail) ne demandent pas d'autorisation. Écrire un fichier et lancer une commande en demandent une.

**Selon la version de l'application, les textes peuvent être en français ou un peu différents.** Si la demande ne ressemble pas à ce tableau, appliquez la règle simple du début.

## Dans Codex

Codex travaille dans un « bac à sable » : par défaut, il peut lire et écrire dans votre dossier de travail sans demander, mais il demande avant de sortir de ce dossier et avant d'utiliser internet (désactivé par défaut). Le réglage standard s'appelle **Auto**. Les autres réglages possibles s'appellent **Read-only** (lecture seule) et **Full access** (aucune protection).

- Gardez le réglage **Auto**. N'allez jamais en « Full access ».
- Vous aurez donc des demandes pour : internet (télécharger l'outil, interroger le BOAMP), écrire dans le dossier des skills de l'outil (`.agents`, que Codex protège particulièrement) et écrire dans `Documents/Marchés publics` si ce dossier est hors de l'espace de travail.
- Les réponses se font par une fenêtre ou une question dans la conversation : acceptez ou refusez avec la même règle que ci-dessus.

## Sources et ce qui reste à vérifier

Cette fiche s'appuie sur la documentation officielle consultée le 13/11/2026 :

- Claude Code : https://code.claude.com/docs/en/permissions (types de demandes, choix « Yes / Yes, and don't ask again / No », modes).
- Codex : https://developers.openai.com/codex/agent-approvals-security (réglages Auto, Read-only, Full access, réseau coupé par défaut, dossiers protégés `.git`, `.agents`, `.codex`, `.aws`).

**Non vérifié**, à contrôler lors du pilote (ticket #13) sur de vraies machines :

- l'intitulé exact des fenêtres de demande dans l'application desktop de Claude et dans celle de Codex (la documentation de Codex ne cite pas les textes des demandes), et leur traduction éventuelle ;
- les demandes réelles à l'installation sous Windows (PowerShell) pour les deux agents ;
- si Codex demande bien une autorisation pour écrire dans `.agents/skills` et dans `Documents` ;
- l'ordre exact des demandes et leur nombre.
