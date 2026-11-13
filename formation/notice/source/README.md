# Fabriquer et mettre à jour la notice

Deux notices sont **générées** : on ne modifie jamais leurs `.html` et `.pdf` à la main. On modifie les sources de ce dossier, puis on reconstruit.

| Notice | Source | Sortie | Pour qui |
|---|---|---|---|
| Complète (16 pages, réf. 2026-D-001) | `corps.html` | `../notice-utilisation.html` et `.pdf` | formateur, artisans qui veulent le détail |
| L'essentiel (3 pages maximum, réf. 2026-D-002) | `corps-essentiel.html` | `../notice-essentielle.html` et `.pdf` | artisans |

**Les deux disent la même chose** : un changement de l'outil se reporte dans les deux corps.

| Fichier | Rôle |
|---|---|
| `corps.html`, `corps-essentiel.html` | **Le texte des notices** : les feuilles A4 (`<section class="sheet">`), rédigées avec les composants du modèle Picant3. Ce sont les fichiers à modifier. Un corps peut déclarer son titre, sa référence et sa version en première ligne : `<!-- document: titre="…" ref="2026-D-002" version="0.9" -->` (sinon, valeurs de la notice complète). |
| `assembler.py` | Colle la feuille de style et les icônes du modèle autour d'un corps, remplace les jetons, dessine les deux schémas SVG. Contient le **numéro de version** de la notice complète. |
| `modele-picant3.html` | Copie du modèle de document technique Picant3 (Open Design, projet « Picant3 — Marque », `documentation/document-technique-modele.html`), avec son mode d'emploi dans `documentation/MODE-EMPLOI.md` du même projet. |
| `construire.sh` | Reconstruit les deux notices (HTML et PDF), puis contrôle le résultat de chacune. |

## Mettre à jour la notice (correctif ou amélioration)

1. Créez une branche : `git switch -c notice-<sujet>`.
2. Modifiez `corps.html` et, si l'essentiel est concerné, `corps-essentiel.html` (3 pages maximum : tout ajout se paie ailleurs).
   - Une feuille contient environ **840 px de contenu** entre l'en-tête et le pied : au-delà, elle déborde sur la page suivante. Pour ajouter du contenu, raccourcissez ailleurs ou ajoutez une feuille.
   - Pour **ajouter une feuille** : dupliquez une `<section class="sheet">` avec un `data-od-id` unique, gardez `__ENTETE__` et `__PIED__`. Les compteurs « n / total » se calculent seuls ; **le sommaire (feuille 2) et les renvois « voir page N » sont à mettre à jour à la main**.
   - Le vocabulaire est celui de `GLOSSARY.md` ; le ton celui de `skill/marches-publics/references/ton.md` (vouvoiement, phrases courtes, pas de jargon).
   - Si l'outil a changé (`skill/`, `INSTALL.md`, `formation/*.md`), la notice doit dire la même chose : relisez les pages concernées.
3. Si la version change : notice complète, `VERSION` dans `assembler.py` et une ligne dans l'historique de `corps.html` (feuille 2), en déplaçant la classe `current` sur la nouvelle ligne ; l'essentiel, `version="…"` en première ligne de `corps-essentiel.html` (pas d'historique, faute de place). Version 0.x tant que la notice n'est pas visée ; 1.0 à la première validation (remplacer alors la pastille `Brouillon` par `Validé`, classe `pill done`).
4. Lancez :

   ```bash
   formation/notice/source/construire.sh
   ```

   Il doit afficher `✓ Notices prêtes`. Sinon : une feuille déborde (raccourcir), ou un emplacement du modèle reste à remplir.
5. Ouvrez `../notice-utilisation.pdf` et regardez chaque page (schémas compris).
6. Commitez les sources **et** les deux fichiers générés, ouvrez une PR.

## Si le modèle Picant3 change

`construire.sh --maj-modele` recopie le modèle depuis Open Design (serveur `192.168.0.33:7456`, réseau local) avant de reconstruire. Relisez ensuite tout le PDF : une modification du modèle peut faire déborder des feuilles.

## Pièges connus

- **Règle « écran étroit » du modèle** : une page A4 imprimée fait 794 px de large ; une règle `@media (max-width:820px)` s'applique donc aussi à l'impression et fait déborder les feuilles. Elle doit être `@media screen and (max-width:820px)` (corrigé dans le modèle Open Design le 13/11/2026 ; `assembler.py` le corrige si une ancienne copie revient).
- **Le contrôle par le nombre de pages est le bon** : la mesure à l'écran ne suffit pas, l'impression peut différer. `construire.sh` compare les pages du PDF au nombre de feuilles.
- **Pas de capture d'écran inventée** : le modèle n'accepte que de vraies captures ou de vrais schémas. Les schémas sont dessinés dans `assembler.py`.
