# Mémoire technique : production du fichier sur Mac

Cette fiche est la seule partie du mémoire qui dépend du système. Elle transforme le `memoire.html` écrit à l'étape 4 de [memoire-technique.md](memoire-technique.md) en `.docx`, avec les outils fournis avec le Mac. Rien à installer.

## Commande

Le script est `scripts/memoire-vers-docx-mac.sh`, dans le dossier de l'outil, à côté de `SKILL.md`. Lancez-le avec `bash`, en donnant le HTML et le chemin du `.docx` à créer (dans le sous-dossier de la consultation) :

```
bash "<dossier de l'outil>/scripts/memoire-vers-docx-mac.sh" "<dossier temporaire>/memoire.html" "<dossier de la consultation>/memoire-technique.docx"
```

Les chemins contiennent des accents et des espaces (`Marchés publics`) : gardez les guillemets. Le script :

1. convertit le HTML en `.docx` avec `textutil` ;
2. **ajoute le surlignage jaune** sur chaque [À COMPLÉTER] (voir plus bas pourquoi) ;
3. contrôle le résultat : archive valide, XML lisible, tous les [À COMPLÉTER] présents et surlignés, texte relu par `textutil` ;
4. n'écrase jamais un fichier existant.

La dernière ligne affichée dit ce qui a été produit : `DOCX <chemin> <n>` (n passages surlignés) ou `RTF <chemin> <n>`.

| Code de sortie | Sens | Que faire |
|---|---|---|
| 0 | `.docx` produit et contrôlé | Rendez compte (étape 7 de memoire-technique.md). |
| 10 | La conversion en `.docx` a échoué ; un `.rtf` de secours est produit, avec le même nom | Donnez le `.rtf` à l'artisan, en disant en une phrase que c'est une version plus simple du même document, que Word et LibreOffice ouvrent. Ne cachez pas l'échec. |
| 4 | Le fichier existe déjà | Choisissez un autre nom (`memoire-technique-2.docx`) et relancez. Ne supprimez rien. |
| 2, 3 | HTML introuvable, ou `textutil` absent : aucun fichier produit | Dites-le simplement ; gardez le HTML (copiez-le dans le sous-dossier de la consultation sous le nom `memoire-technique.html`) et expliquez qu'il s'ouvre avec Word. |

Si l'artisan demande lui-même un `.rtf` plutôt qu'un `.docx` (son ordinateur ou ses logiciels ne lisent pas le Word), faites la même chose avec `MEMOIRE_FORCER_ECHEC_DOCX=1` devant la commande : le script produit directement le `.rtf` surligné.

## Ce que l'expérience a montré sur `textutil` (macOS)

Ces constats viennent d'essais réels sur le Mac de développement ; ils expliquent le script.

| Ce qu'on a essayé | Résultat dans le `.docx` |
|---|---|
| `<mark>`, `<span style="background-color:#FFFF00">`, `background:yellow`, classe CSS, fond sur `<p>`, `<b>`, `<font>`, `<td>` | **Perdu** : aucun `w:highlight` ni `w:shd`. Le `.rtf` garde bien le fond (`\cb`), le `.docx` non. |
| Couleur du texte (`color:#C00000`), gras | Conservés (`w:color`, `w:b`). La couleur est légèrement décalée (`C00000` devient `B00004`). |
| Tableaux HTML (`<table>`) | **Perdus** : chaque cellule devient un paragraphe. Le mémoire n'en contient donc pas. |
| Titres `h1`-`h3` | Du texte gras en gros caractères, pas de vrais styles « Titre 1 » de Word. |
| Tailles en `pt` | Lues comme des pixels puis agrandies (11pt devient 14,5 pt) : le gabarit écrit des `px`. |

Méthode retenue : le passage à compléter est écrit en gras rouge (qui survit à la conversion et le garde repérable même sans surlignage), `textutil` le met dans un passage de texte à part, et le script insère `<w:highlight w:val="yellow"/>` dans le formatage de chaque passage qui contient `[À COMPLÉTER`. Le résultat se vérifie dans `word/document.xml` du `.docx` (un `.docx` est un ZIP) :

```
unzip -p memoire-technique.docx word/document.xml | grep -o '<w:highlight[^>]*>' | wc -l
```

Ce nombre doit être égal au nombre de [À COMPLÉTER] (le script le contrôle lui-même).

Le `.rtf` de secours est produit par `textutil -convert rtf` (qui garde le fond jaune en `\cb`), puis le script ajoute `\highlight` à côté, que Word et LibreOffice lisent.

## Ce qui n'est pas vérifié

Ni Word ni LibreOffice n'ont pu être essayés pendant le développement : le script contrôle la structure du `.docx` (archive, XML, surlignage, relecture par `textutil`), pas son affichage dans ces logiciels.
