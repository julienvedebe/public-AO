# QR code d'installation (pour le mainteneur)

**L'image n'est pas dans le dépôt.** Aucun générateur de QR code n'était installé sur la machine où ce dossier a été préparé, et il n'a pas été fabriqué à la main. Le mainteneur la crée avec la commande ci-dessous.

## URL cible

```text
https://github.com/julienvedebe/public-AO#installer
```

Elle ouvre la page d'accueil du dépôt, à la section « Installer », où le message d'installation est dans un cadre avec un bouton « copier ». Ce qui justifie ce choix :

- la page existe déjà et ne changera pas de nom (contrairement à un fichier de `formation/`, qui peut être déplacé et que le QR code, une fois imprimé, ne suivrait pas) ;
- le message d'installation y est identique à celui de `formation/installation.md` : le dépôt n'a qu'une source à tenir à jour ;
- le dépôt est public : aucune connexion n'est demandée à l'artisan.

Si l'ancre `#installer` ne fait pas défiler la page sur un téléphone, l'artisan voit quand même la section « Installer » en haut de l'écran : le QR code reste valable.

## Fabrication

Avec Homebrew (Mac) :

```bash
brew install qrencode
qrencode -o formation/qr-installation.png -s 10 -m 4 -l M "https://github.com/julienvedebe/public-AO#installer"
```

Vérifier : ouvrir `formation/qr-installation.png`, le scanner avec un téléphone, contrôler qu'il ouvre la bonne page. Puis ajouter l'image au dépôt par une PR (`git add formation/qr-installation.png`).

À refaire seulement si le nom du dépôt ou son propriétaire change.
