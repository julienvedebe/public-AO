# Fabriquer et mettre à jour le support de formation

Le support projeté (`../support-formation.html` et `.pdf`) est **généré** : on ne modifie jamais ces deux fichiers à la main. On modifie les sources de ce dossier, puis on reconstruit. Même principe que les notices (`formation/notice/source/`).

| Fichier | Rôle |
|---|---|
| `diapos.html` | **Le texte des diapositives** (`<section class="slide">`), rédigé avec les gabarits du modèle Picant3. C'est le fichier à modifier. |
| `assembler.py` | Colle les diapositives dans le modèle, ajoute les styles propres au support, numérote les pieds de page, dessine le schéma du parcours (diapositive 13), intègre le logo. |
| `modele-presentation-picant3.html` | Copie du modèle de présentation Picant3 (Open Design, projet « Picant3 — Marque », `deck/modele-presentation-picant3.html`), avec son mode d'emploi dans `deck/MODE-EMPLOI.md` du même projet. |
| `marque.png` | Le logo transparent du modèle (`logos/marque.png`), réduit à 96 px de haut pour le pied de page. |
| `construire.sh` | Reconstruit le HTML et le PDF, puis contrôle le résultat. |

Les notes du formateur sont à côté du support : `../notes-formateur.md`. Si vous ajoutez, retirez ou déplacez une diapositive, renumérotez-les.

## Mettre à jour le support

1. Créez une branche : `git switch -c presentation-<sujet>`.
2. Modifiez `diapos.html`.
   - Chaque diapositive se termine par `__PIED__` : le numéro « n / total » et le titre numéroté (`data-screen-label`) se calculent seuls. Le titre de la diapositive (`data-screen-label`) s'écrit sans numéro.
   - Une diapositive fait 1920 × 1080 px ; le contenu doit s'arrêter au-dessus du pied (environ 840 px de haut). Au-delà, il est coupé à l'écran.
   - Gabarits disponibles : ceux du modèle (`pad--cover`, `pad--toc`, `pad--contenu`, `pad--loop`, `pad--citation`, `pad--contact`, `poles`, `timeline`…) et ceux du support (`pad--etape` avec `.rows` et la carte `.avous`, `.grid2` à `.grid5`, `table.tab`, `.memo`). Voir `CSS_AJOUT` dans `assembler.py`.
   - Un emplacement à remplir par le formateur s'écrit `<span class="a-completer">…</span>` : il apparaît en pointillés corail, et `construire.sh` le liste.
   - Ce que vous écrivez à l'outil : `<span class="say">…</span>`.
   - Le vocabulaire est celui de `GLOSSARY.md`, le ton celui de `skill/marches-publics/references/ton.md`. Si l'outil change (`skill/`, `formation/*.md`), le support doit dire la même chose que la notice.
   - Règles du modèle à respecter (`deck/MODE-EMPLOI.md`) : la framboise `#e11d48` n'est jamais une couleur de texte (corail `#ffb3b6` pour le texte accentué) ; texte blanc sur le dégradé seulement à 34 px gras ou plus ; deux accents au plus par écran ; pas de chiffre d'effectif.
3. Lancez :

   ```bash
   formation/presentation/source/construire.sh
   ```

   Il doit afficher `✓ Support prêt`, après la liste des emplacements encore à compléter.
4. Relisez à l'écran : ouvrez `../support-formation.html` dans un navigateur, flèches ← → pour changer de diapositive. Regardez chaque diapositive : un texte trop long est coupé sans erreur.
5. Commitez les sources **et** les deux fichiers générés, ouvrez une PR.

## Avant chaque session

Remplissez les emplacements listés par `construire.sh` (lieu, jour, formateur, QR code, consultation du jour, capture), puis reconstruisez. Pour une image (QR code, capture) : remplacez le contenu du `.visual-slot` par `<img src="…" alt="…">` et placez l'image à côté de `support-formation.html` (le HTML n'est alors plus autonome : gardez l'image avec lui), ou intégrez-la en `data:` comme le logo dans `assembler.py`.

## Si le modèle Picant3 change

`construire.sh --maj-modele` recopie le modèle depuis Open Design (serveur `192.168.0.33:7456`, réseau local) avant de reconstruire. Relisez ensuite tout le support : le script suppose que le modèle a toujours `<div class="deck-stage" id="deck-stage">`, un second bloc `<style>` et le commentaire `<!-- Framework chrome`.

## Pièges connus

- **Le modèle n'imprime qu'une page.** Dans son moteur, `.slide:not(.active) { display:none !important }` est plus précis que la règle d'impression `.slide { display:flex !important }` : imprimé avec Chrome, le modèle seul donne 1 page pour 11 diapositives (constaté le 13/11/2026). `assembler.py` ajoute, dans les styles propres au support, la même règle en `display:flex` à l'impression. À corriger aussi dans le modèle Open Design.
- **Ombres à l'impression** : Chrome imprime les grandes ombres floues (`--shadow-card`) en rectangle noir. Elles sont retirées à l'impression.
- **Fonds sombres** : sans `print-color-adjust: exact`, Chrome n'imprime pas les fonds et le texte clair devient illisible. C'est réglé dans `assembler.py`.
- **Règle « écran étroit »** : une règle `@media (max-width:…)` sans `screen` s'applique aussi à l'impression. Le modèle de présentation n'en a pas aujourd'hui ; `assembler.py` les limite à l'écran si elles apparaissent.
- **Le contrôle par le nombre de pages est le bon** : une page de PDF par diapositive. Il ne voit pas un texte coupé à l'intérieur d'une diapositive : seule la relecture le voit.
- **Pas de capture d'écran inventée** : de vrais schémas (dessinés dans `assembler.py`) ou des emplacements marqués, que le formateur remplit avec ses propres captures.
- **Polices** : Outfit et Plus Jakarta Sans ne sont pas embarquées (modèle sans CDN) ; le support s'affiche avec la police système de repli, comme prévu par le modèle.
