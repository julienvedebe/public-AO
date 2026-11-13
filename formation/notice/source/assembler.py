"""Assemble la notice : CSS et sprite du modèle Picant3 + corps rédigé + schémas SVG.

Usage (normalement via construire.sh) :
    python3 -I assembler.py modele-picant3.html corps.html ../notice-utilisation.html

Les jetons de corps.html remplacés ici :
    __ENTETE__  en-tête courant (titre + référence + version), une fois par feuille sauf la garde
    __PIED__    pied de page légal + compteur « n / total », calculé automatiquement
    __VERSION__ numéro de version (page de garde)
    __SCHEMA_INSTALLATION__, __SCHEMA_PARCOURS__  schémas SVG dessinés ci-dessous
"""
import re
import sys

modele_path, corps_path, sortie_path = sys.argv[1:4]
modele = open(modele_path, encoding="utf-8").read()
corps = open(corps_path, encoding="utf-8").read()

# Identité du document. Valeurs de la notice complète (corps.html) ; un autre corps peut les
# remplacer par un commentaire en tête de fichier :
#   <!-- document: titre="…" ref="2026-D-002" version="0.9" -->
# À changer à chaque nouvelle version (et ajouter une ligne à l'historique du document s'il en a un).
VERSION = "0.9"
TITRE = "Marchés publics — Notice d'installation et d'utilisation"
NUMERO = "2026-D-001"
entete_doc = re.match(r"\s*<!--\s*document:(.*?)-->", corps, flags=re.S)
if entete_doc:
    champs = dict(re.findall(r'(\w+)="([^"]*)"', entete_doc.group(1)))
    TITRE = champs.get("titre", TITRE)
    NUMERO = champs.get("ref", NUMERO)
    VERSION = champs.get("version", VERSION)
    corps = corps[entete_doc.end():]
REF = f"Réf. {NUMERO} · v{VERSION}"

CSS_AJOUT = """
/* ============================================================
   AJOUTS DE LA NOTICE « MARCHÉS PUBLICS » (aucun nouveau token)
   - .uc : fiche d'une étape d'utilisation (Dites / Ce qui se passe / Vous obtenez)
   - svg.schema : schémas dessinés, à la place des emplacements de figure
   ============================================================ */
.uc{background:var(--sheet);border:1px solid var(--border);border-radius:var(--r-card);padding:1rem 1.15rem .6rem;break-inside:avoid}
.uc-head{display:flex;align-items:center;gap:.7rem;margin-bottom:.55rem}
.uc-num{width:32px;height:32px;border-radius:999px;border:2px solid var(--raspberry);background:var(--paper);
  display:grid;place-items:center;font-family:var(--font-display);font-weight:700;font-size:15px;color:var(--accent-ink);flex:none}
.uc h3{font-size:18px}
.uc .row{display:grid;grid-template-columns:30mm 1fr;gap:.9rem;padding:.45rem 0;border-top:1px solid var(--border)}
.uc .row .k{font-size:10.5px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:var(--ink-muted);padding-top:.2rem}
.uc .row .v{font-size:13.5px;line-height:1.55;color:var(--ink-soft)}
.uc .row .v b{color:var(--ink);font-weight:600}
svg.schema{display:block;width:100%;height:auto}
@media print{
  .uc{break-inside:avoid;page-break-inside:avoid}
  .uc-num,svg.schema{-webkit-print-color-adjust:exact;print-color-adjust:exact}
}
@media screen and (max-width:820px){ .uc .row{grid-template-columns:1fr;gap:.2rem} }
"""

POLICE = "Plus Jakarta Sans, ui-sans-serif, system-ui, Segoe UI, Roboto, Helvetica, Arial, sans-serif"
TITRES = "Outfit, ui-sans-serif, system-ui, Segoe UI, Roboto, Helvetica, Arial, sans-serif"


def boite(x, y, w, h, titre, sous_titre, num=None, accent=False):
    bord = "#A31232" if accent else "rgba(31,26,22,.24)"
    fond = "#FCE9EA" if accent else "#FFFDFB"
    s = [f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="12" fill="{fond}" stroke="{bord}" stroke-width="1.2"/>']
    tx = x + 16
    if num is not None:
        cx, cy = x + 26, y + h / 2
        s.append(f'<circle cx="{cx}" cy="{cy}" r="14" fill="#F7F3EF" stroke="#e11d48" stroke-width="2"/>')
        s.append(f'<text x="{cx}" y="{cy + 5}" text-anchor="middle" font-family="{TITRES}" font-weight="700" font-size="14" fill="#A31232">{num}</text>')
        tx = x + 50
    s.append(f'<text x="{tx}" y="{y + h / 2 - 3}" font-family="{TITRES}" font-weight="700" font-size="14.5" fill="#201D1A">{titre}</text>')
    s.append(f'<text x="{tx}" y="{y + h / 2 + 14}" font-family="{POLICE}" font-size="11.5" fill="#675F57">{sous_titre}</text>')
    return "".join(s)


def fleche(x1, y1, x2, y2):
    return (f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="#A31232" stroke-width="1.6" '
            f'marker-end="url(#pointe)"/>')


DEFS = ('<defs><marker id="pointe" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" '
        'orient="auto-start-reverse"><path d="M0 0L10 5L0 10z" fill="#A31232"/></marker></defs>')

# Schéma 1 : ce que fait l'installation
w, h = 300, 54
installation = [f'<svg class="schema" viewBox="0 0 320 222" role="img" aria-label="Le site public de l\'outil est copié '
                f'dans le dossier des outils de l\'assistant, puis le dossier Marchés publics est créé dans Documents">', DEFS]
installation.append(boite(10, 6, w, h, "Site public de l'outil", "GitHub, sans compte ni mot de passe"))
installation.append(fleche(160, 60, 160, 82))
installation.append(boite(10, 84, w, h, "L'outil, dans votre assistant", "dossier des outils de Claude ou de Codex"))
installation.append(fleche(160, 138, 160, 160))
installation.append(boite(10, 162, w, h, "Votre dossier « Marchés publics »", "créé dans Documents, vide au départ", accent=True))
installation.append("</svg>")

# Schéma 2 : le parcours
W, H = 200, 58
X = [10, 245, 480]
parcours = [f'<svg class="schema" viewBox="0 0 690 300" role="img" aria-label="Parcours : 1 ma fiche, 2 veille, '
            f'3 analyse, 4 pièces, 5 mémoire, 6 dépôt et bilan ; 7 se faire connaître, en parallèle">', DEFS]
parcours.append(boite(X[0], 14, W, H, "Ma fiche", "remplie une fois pour toutes", 1))
parcours.append(boite(X[1], 14, W, H, "Veille", "consultations du BOAMP", 2))
parcours.append(boite(X[2], 14, W, H, "Analyse", "avis 🟢 🟠 🔴", 3))
parcours.append(boite(X[2], 132, W, H, "Pièces", "checklist et rétroplanning", 4))
parcours.append(boite(X[1], 132, W, H, "Mémoire", "en Word, sans invention", 5))
parcours.append(boite(X[0], 132, W, H, "Dépôt et bilan", "vous déposez vous-même", 6))
parcours.append(fleche(X[0] + W, 43, X[1] - 2, 43))
parcours.append(fleche(X[1] + W, 43, X[2] - 2, 43))
parcours.append(fleche(X[2] + W / 2, 72, X[2] + W / 2, 130))
parcours.append(f'<text x="{X[2] + W / 2 + 10}" y="106" font-family="{POLICE}" font-size="11.5" fill="#675F57">si vous répondez</text>')
parcours.append(fleche(X[2], 161, X[1] + W + 2, 161))
parcours.append(fleche(X[1], 161, X[0] + W + 2, 161))
# Retour des leçons du bilan (6) vers la veille (2) : passe entre les deux rangées, sans croiser de boîte.
parcours.append(f'<path d="M{X[0] + 170} 130 V 102 H {X[1] + 55} V 74" fill="none" '
                f'stroke="#675F57" stroke-width="1.2" stroke-dasharray="4 4" marker-end="url(#pointe)"/>')
parcours.append(f'<text x="{X[1] + 66}" y="106" font-family="{POLICE}" font-size="11.5" fill="#675F57">leçons pour la prochaine veille</text>')
parcours.append('<rect x="10" y="236" width="670" height="56" rx="12" fill="#FFFDFB" stroke="rgba(31,26,22,.24)" '
                'stroke-width="1.2" stroke-dasharray="6 5"/>')
parcours.append(f'<circle cx="36" cy="264" r="14" fill="#F7F3EF" stroke="#e11d48" stroke-width="2"/>'
                f'<text x="36" y="269" text-anchor="middle" font-family="{TITRES}" font-weight="700" font-size="14" fill="#A31232">7</text>')
parcours.append(f'<text x="60" y="261" font-family="{TITRES}" font-weight="700" font-size="14.5" fill="#201D1A">Se faire connaître des acheteurs proches</text>')
parcours.append(f'<text x="60" y="278" font-family="{POLICE}" font-size="11.5" fill="#675F57">En parallèle : '
                f'les marchés de moins de 100 000 € HT peuvent être confiés sans annonce.</text>')
parcours.append("</svg>")

# En-tête courant et pied de page
entete = ('<header class="run-head"><div class="brand"><span class="wordmark">Picant<b>3</b></span></div>'
          f'<div class="r">{TITRE}<br>{REF}</div></header>')
pied_html = ('<footer class="doc-foot">\n      <div class="sas"><b>Picant3</b> — SAS au capital de 2&#8239;000&#8239;€, '
             "en cours d'immatriculation au RCS d'Aix-en-Provence · Eguilles (13). contact@picant3.com</div>\n"
             '      <div class="pg">{n} / {total}</div>\n    </footer>')

total = corps.count('<section class="sheet')
# Les feuilles sans pied de page (page de garde) comptent dans le total mais ne portent pas de numéro.
compteur = iter(range(total - corps.count("__PIED__") + 1, total + 1))
corps = corps.replace("__ENTETE__", entete)
corps = corps.replace("__VERSION__", VERSION)
corps = re.sub("__PIED__", lambda m: pied_html.format(n=next(compteur), total=total), corps)
corps = corps.replace("__SCHEMA_INSTALLATION__", "".join(installation))
corps = corps.replace("__SCHEMA_PARCOURS__", "".join(parcours))
assert "__" not in corps, "jeton non remplacé"

tete = modele.split("</style>")[0]
# Correctif du gabarit : une page A4 fait 794 px de large, donc la règle « écran étroit »
# (max-width:820px) s'appliquait aussi à l'impression (grilles sur une colonne, marges réduites)
# et faisait déborder les feuilles : le modèle seul donne 11 pages pour 8 feuilles.
# Elle est réservée à l'écran. Le modèle a été corrigé dans Open Design le 13/11/2026 ;
# ce remplacement ne sert que si une ancienne copie du modèle revient.
tete = tete.replace("@media (max-width:820px){", "@media screen and (max-width:820px){")
assert "@media (max-width:820px)" not in tete
tete = re.sub(r"<title>.*?</title>", f"<title>{TITRE}</title>", tete, flags=re.S)
sprite = re.search(r"<!-- Sprite d'icônes.*?</svg>", modele, flags=re.S).group(0)

html = f"{tete}{CSS_AJOUT}</style>\n</head>\n<body>\n\n{sprite}\n\n{corps}\n</body>\n</html>\n"
open(sortie_path, "w", encoding="utf-8").write(html)
print(f"{sortie_path} : {total} pages, {len(html)} octets")
