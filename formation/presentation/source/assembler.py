"""Assemble le support de formation : modèle de présentation Picant3 + diapositives rédigées.

Usage (normalement via construire.sh) :
    python3 -I assembler.py modele-presentation-picant3.html diapos.html marque.png ../support-formation.html

Ce que fait ce script :
- garde le moteur du modèle tel quel (premier <style>, navigation, impression) ;
- ajoute les styles propres au support (CSS_AJOUT, sans nouveau token de couleur) ;
- remplace les 11 gabarits d'exemple par les diapositives de diapos.html ;
- numérote les diapositives (data-screen-label, pied « n / total ») et rend la première active ;
- remplace les jetons __PIED__ et __SCHEMA_PARCOURS__ ;
- intègre le logo (marque.png) dans le fichier, qui reste autonome.
"""
import base64
import re
import sys

modele_path, diapos_path, logo_path, sortie_path = sys.argv[1:5]
modele = open(modele_path, encoding="utf-8").read()
diapos = open(diapos_path, encoding="utf-8").read()
logo = "data:image/png;base64," + base64.b64encode(open(logo_path, "rb").read()).decode()

TITRE = "Marchés publics — Support de formation des artisans"
MENTION = "Support de formation"  # remplace « Présentation commerciale » et « Confidentiel » du modèle

CSS_AJOUT = """
    /* ==========================================================
       AJOUTS DU SUPPORT DE FORMATION « MARCHÉS PUBLICS »
       Aucun nouveau token : corail = texte accentué, framboise = remplissage.
       ========================================================== */
    .a-completer { color: var(--accent); border: 2px dashed rgba(255,179,182,.55); border-radius: var(--r-sm); padding: 0 12px; }
    b.a-completer { display: inline-block; margin-bottom: 12px; }
    .say {
      font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; font-size: .86em;
      color: var(--fg); background: var(--well); border: 1px solid var(--border-strong);
      border-radius: var(--r-sm); padding: 0 10px; -webkit-box-decoration-break: clone; box-decoration-break: clone;
    }
    .lead em { font-style: normal; color: var(--accent); }
    .note { font-size: 23px; line-height: 1.5; color: var(--muted); margin-top: 34px; max-width: 80ch; padding-left: 22px; border-left: 3px solid var(--raspberry); }
    .menu-note { font-size: 21px; line-height: 1.5; color: var(--muted); margin-top: 22px; }

    .grid2 { display: grid; grid-template-columns: 1fr 1fr; gap: 32px; }
    .grid3 { display: grid; grid-template-columns: repeat(3, 1fr); gap: 28px; }
    .grid4 { display: grid; grid-template-columns: repeat(4, 1fr); gap: 24px; }
    .grid5 { display: grid; grid-template-columns: repeat(5, 1fr); gap: 22px; }
    .card--mot { padding: 32px 34px 34px; }
    .card--mot .card-desc { font-size: 23px; }
    .grid5 .card { padding: 34px 28px; }
    .grid5 .h3 { font-size: 30px; }
    .grid5 .card-desc { font-size: 23px; }
    .grid2 .card--main .idx { font-family: var(--font-body); font-size: 22px; font-weight: 600; letter-spacing: .1em; text-transform: uppercase; }
    .grid2 .card--main .h3 { font-size: 42px; line-height: 1.15; }
    .grid2 .card--main .card-desc { font-size: 26px; margin-top: 20px; }
    .grid4 .fact { padding: 30px 28px; }
    .grid4 .fact .n { font-size: 38px; line-height: 1.1; }
    .grid4 .fact .l { font-size: 22px; line-height: 1.45; }
    .inutile { display: flex; flex-wrap: wrap; align-items: center; gap: 14px; margin-top: 36px; }
    .inutile span:not(.microlabel) { font-size: 22px; color: var(--fg-soft); background: rgba(255,255,255,.04); border: 1px solid var(--border); border-radius: var(--r-sm); padding: 8px 16px; }
    .inutile .microlabel { margin-right: 8px; }

    /* Couverture, programme, citation */
    .pad--cover .lead { max-width: 52ch; }
    .toc--agenda .toc-item { grid-template-columns: 150px 1fr; padding: 18px 0; }
    .toc--agenda .toc-item .n { font-size: 28px; }
    .toc--agenda .toc-item .t { font-size: 34px; }
    .bignum--euros { font-size: 250px; }
    .lead--centre { max-width: 40ch; margin-top: 44px; text-align: center; color: var(--fg-soft); }
    .source { font-size: 20px; color: var(--muted); margin-top: 30px; }
    [data-od-id="slide-pourquoi"] .quote { font-size: 74px; max-width: 28ch; }

    /* Étapes : texte à gauche, « À vous » à droite */
    .pad--etape { display: grid; grid-template-columns: 1.12fr .88fr; column-gap: 72px; align-items: center; }
    .pad--etape .h2 { font-size: 60px; }
    .rows { margin-top: 30px; }
    .row { display: grid; grid-template-columns: 210px 1fr; gap: 28px; padding: 18px 0; border-top: 1px solid var(--border); }
    .row .k { font-size: 19px; font-weight: 600; letter-spacing: .1em; text-transform: uppercase; color: var(--muted); padding-top: 7px; }
    .row .v { font-size: 26px; line-height: 1.45; color: var(--fg-soft); }
    .avous { background: var(--surface-1); border: 1px solid var(--border-strong); border-radius: var(--r-card); padding: 40px 40px 44px; box-shadow: var(--shadow-card); }
    .chip-avous {
      display: inline-flex; align-items: center; gap: 12px;
      font-size: 22px; font-weight: 700; letter-spacing: .12em; text-transform: uppercase; color: var(--accent);
      background: var(--surface); border: 1px solid var(--border-hover); border-radius: var(--r-pill); padding: 10px 22px;
    }
    .chip-avous::before { content: ""; width: 12px; height: 12px; border-radius: 999px; background: var(--grad-spicy); }
    ol.pas { list-style: none; counter-reset: pas; margin-top: 28px; display: flex; flex-direction: column; gap: 20px; }
    /* li en bloc (pas en grille) : un <b> ou un .say dans la phrase ne doit pas devenir une cellule */
    ol.pas li { counter-increment: pas; position: relative; padding-left: 64px; min-height: 42px; font-size: 25px; line-height: 1.45; color: var(--fg-soft); }
    ol.pas li::before {
      content: counter(pas); position: absolute; left: 0; top: -2px; width: 42px; height: 42px; border-radius: 999px; border: 3px solid var(--raspberry);
      display: grid; place-items: center; font-family: var(--font-display); font-weight: 700; font-size: 21px; color: var(--accent);
    }
    ol.pas b { color: var(--fg); font-weight: 600; }
    .phrases { list-style: none; margin-top: 24px; display: flex; flex-direction: column; gap: 20px; }
    .phrases li { display: flex; flex-direction: column; gap: 6px; font-size: 22px; color: var(--muted); }
    .phrases .say { align-self: flex-start; font-size: 25px; }
    ol.menu { list-style: none; counter-reset: menu; margin-top: 22px; display: flex; flex-direction: column; gap: 10px; }
    ol.menu li { counter-increment: menu; display: grid; grid-template-columns: 40px 1fr; font-size: 24px; color: var(--fg-soft); }
    ol.menu li::before { content: counter(menu); font-family: var(--font-display); font-weight: 700; color: var(--accent); }

    /* Installer */
    .pad--loop .loop-step { padding-bottom: 30px; }
    .pad--loop .loop-step:last-child { padding-bottom: 0; }
    .pad--loop .st-title { font-size: 32px; }
    .install-side { display: flex; flex-direction: column; gap: 28px; }
    .message { background: var(--well); border: 1px solid var(--border-strong); border-radius: var(--r-card); padding: 30px 36px; }
    .message p { font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; font-size: 23px; line-height: 1.55; color: var(--fg); margin-top: 14px; overflow-wrap: anywhere; }
    .qr-row { display: grid; grid-template-columns: 240px 1fr; gap: 32px; align-items: center; }
    .visual-slot--qr { min-height: 240px; height: 240px; padding: 18px; }
    .visual-slot--qr .vs-txt { font-size: 17px; overflow-wrap: anywhere; }
    .visual-slot--qr .vs-txt b { font-size: 24px; }

    /* Analyse : les trois avis */
    .verdicts { display: flex; flex-direction: column; gap: 24px; margin-top: 24px; }
    .vd { display: grid; grid-template-columns: 56px 1fr; gap: 16px; align-items: start; }
    .vd .pastille { font-size: 38px; line-height: 1.1; }
    .vd b { display: block; font-family: var(--font-display); font-size: 30px; color: var(--fg); }
    .vd div span { display: block; font-size: 22px; line-height: 1.4; color: var(--muted); margin-top: 4px; }

    /* Consultation du jour */
    .fiche-consult { background: var(--surface-1); border: 1px solid var(--border-strong); border-radius: var(--r-card); padding: 14px 40px; box-shadow: var(--shadow-card); }
    .fc-row { display: grid; grid-template-columns: 170px 1fr; gap: 24px; align-items: baseline; padding: 24px 0; border-top: 1px solid var(--border); font-size: 25px; }
    .fc-row:first-child { border-top: 0; }
    .fc-row .k { font-size: 19px; font-weight: 600; letter-spacing: .1em; text-transform: uppercase; color: var(--muted); }

    /* Suivi : les statuts */
    .statuts { display: flex; flex-wrap: wrap; align-items: center; gap: 10px; margin-top: 26px; }
    .statuts span { font-size: 20px; font-weight: 600; color: var(--fg-soft); background: rgba(255,255,255,.04); border: 1px solid var(--border); border-radius: var(--r-sm); padding: 6px 12px; }
    .statuts i { font-style: normal; font-size: 20px; color: var(--muted); }
    .statuts .statut-autre { border-style: dashed; color: var(--accent); margin-left: 10px; }

    [data-od-id="slide-apres"] .tl-item .desc { max-width: 30ch; }

    /* Parcours */
    .schema-wrap { margin-top: 44px; }
    svg.schema { display: block; width: 100%; height: auto; }

    /* Données */
    .poles--col { grid-template-columns: 1fr; margin-top: 0; gap: 24px; }
    .poles--col .pole { padding: 34px 40px; }
    .poles--col .pdesc { font-size: 24px; margin-top: 14px; }
    .pole li { font-size: 25px; }
    pre.arbo {
      font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; font-size: 22px; line-height: 1.5;
      color: var(--fg-soft); background: var(--well); border: 1px solid var(--border); border-radius: var(--r-ctrl);
      padding: 26px 30px; margin-top: 30px; white-space: pre;
    }

    /* Dépannage */
    table.tab { width: 100%; border-collapse: collapse; margin-top: 40px; }
    .tab th { text-align: left; font-size: 19px; font-weight: 600; letter-spacing: .1em; text-transform: uppercase; color: var(--muted); padding: 0 32px 14px 0; border-bottom: 1px solid var(--border-strong); }
    .tab td { font-size: 24px; line-height: 1.4; color: var(--fg-soft); padding: 16px 32px 16px 0; border-bottom: 1px solid var(--border); vertical-align: top; }
    .tab td:first-child { width: 42%; color: var(--fg); font-weight: 600; }

    /* Mémo des phrases */
    .memo { display: flex; flex-direction: column; }
    .memo .m { display: grid; grid-template-columns: 64px 1fr; align-items: center; padding: 16px 0; border-bottom: 1px solid var(--border); }
    .memo .m:first-child { border-top: 1px solid var(--border); }
    .memo .n { font-family: var(--font-display); font-weight: 700; font-size: 32px; color: var(--accent); }
    .memo .say { justify-self: start; font-size: 26px; }

    /* Impression (contrôle de référence : une page de PDF par diapositive).
       Dans le moteur, « .slide:not(.active) { display:none !important } » est plus précis que
       « .slide { display:flex !important } » de son @media print : imprimé tel quel, le modèle ne
       donne qu'UNE page (constaté le 13/11/2026 avec Chrome). Même sélecteur, placé après : il l'emporte.
       Les fonds sombres sont imprimés (sinon Chrome les retire et le texte clair devient illisible). */
    @media print {
      .slide:not(.active) { display: flex !important; }
      .slide { background: var(--bg); }
      .deck-stage, .deck-stage * { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
      /* Chrome imprime les grandes ombres floues en rectangle noir opaque : pas d'ombre sur papier. */
      .deck-stage * { box-shadow: none !important; }
    }
"""

# ---------- Schéma du parcours (déclinaison sombre, canevas 1664 px de large) ----------
TITRES = "Outfit, ui-sans-serif, system-ui, Segoe UI, Roboto, Helvetica, Arial, sans-serif"
POLICE = "Plus Jakarta Sans, ui-sans-serif, system-ui, Segoe UI, Roboto, Helvetica, Arial, sans-serif"
CORAIL, FRAMBOISE, TEXTE, GRIS = "#ffb3b6", "#e11d48", "#FAFAFA", "#A1A1AA"


def boite(x, y, w, h, num, titre, sous_titre, accent=False):
    bord = FRAMBOISE if accent else "rgba(255,255,255,.14)"
    s = [f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="20" fill="#1c1b1d" stroke="{bord}" stroke-width="2"/>']
    cx, cy = x + 48, y + h / 2
    s.append(f'<circle cx="{cx}" cy="{cy}" r="27" fill="#131315" stroke="{FRAMBOISE}" stroke-width="3"/>')
    s.append(f'<text x="{cx}" y="{cy + 10}" text-anchor="middle" font-family="{TITRES}" font-weight="700" '
             f'font-size="28" fill="{CORAIL}">{num}</text>')
    s.append(f'<text x="{x + 96}" y="{cy - 6}" font-family="{TITRES}" font-weight="700" font-size="34" fill="{TEXTE}">{titre}</text>')
    s.append(f'<text x="{x + 96}" y="{cy + 30}" font-family="{POLICE}" font-size="23" fill="{GRIS}">{sous_titre}</text>')
    return "".join(s)


def fleche(x1, y1, x2, y2):
    return f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{FRAMBOISE}" stroke-width="3" marker-end="url(#pointe)"/>'


W, H = 470, 120
X = [0, 597, 1194]
Y1, Y2 = 10, 250
p = ['<svg class="schema" viewBox="0 0 1664 560" role="img" aria-label="Parcours : 1 votre fiche, 2 veille, '
     '3 analyse, puis si vous répondez 4 pièces, 5 mémoire, 6 dépôt et bilan ; 7 se faire connaître, en parallèle">',
     f'<defs><marker id="pointe" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="5" markerHeight="5" '
     f'orient="auto-start-reverse"><path d="M0 0L10 5L0 10z" fill="{FRAMBOISE}"/></marker></defs>']
p.append(boite(X[0], Y1, W, H, 1, "Votre fiche", "remplie une fois pour toutes"))
p.append(boite(X[1], Y1, W, H, 2, "Veille", "les consultations du BOAMP"))
p.append(boite(X[2], Y1, W, H, 3, "Analyse", "un avis 🟢 🟠 🔴, vous choisissez", accent=True))
p.append(boite(X[2], Y2, W, H, 4, "Pièces", "ce qui manque, le calendrier"))
p.append(boite(X[1], Y2, W, H, 5, "Mémoire", "en Word, sans invention"))
p.append(boite(X[0], Y2, W, H, 6, "Dépôt et bilan", "vous déposez vous-même"))
p.append(fleche(X[0] + W + 6, Y1 + H / 2, X[1] - 8, Y1 + H / 2))
p.append(fleche(X[1] + W + 6, Y1 + H / 2, X[2] - 8, Y1 + H / 2))
p.append(fleche(X[2] + W / 2, Y1 + H + 6, X[2] + W / 2, Y2 - 8))
p.append(f'<text x="{X[2] + W / 2 + 18}" y="{(Y1 + H + Y2) / 2 + 8}" font-family="{POLICE}" font-size="23" fill="{CORAIL}">si vous répondez</text>')
p.append(f'<text x="{X[2] + W / 2 - 18}" y="{(Y1 + H + Y2) / 2 + 8}" text-anchor="end" font-family="{POLICE}" font-size="23" fill="{GRIS}">sinon&#160;: déclinée</text>')
p.append(fleche(X[2] - 6, Y2 + H / 2, X[1] + W + 8, Y2 + H / 2))
p.append(fleche(X[1] - 6, Y2 + H / 2, X[0] + W + 8, Y2 + H / 2))
# Bande de l'étape 7, en parallèle
yb = 440
p.append(f'<rect x="0" y="{yb}" width="1664" height="110" rx="20" fill="#18181B" stroke="rgba(255,255,255,.22)" '
         f'stroke-width="2" stroke-dasharray="10 8"/>')
p.append(f'<circle cx="48" cy="{yb + 55}" r="27" fill="#131315" stroke="{FRAMBOISE}" stroke-width="3"/>'
         f'<text x="48" y="{yb + 65}" text-anchor="middle" font-family="{TITRES}" font-weight="700" font-size="28" fill="{CORAIL}">7</text>')
p.append(f'<text x="96" y="{yb + 49}" font-family="{TITRES}" font-weight="700" font-size="34" fill="{TEXTE}">Se faire connaître des acheteurs proches</text>')
p.append(f'<text x="96" y="{yb + 85}" font-family="{POLICE}" font-size="23" fill="{GRIS}">En parallèle&#160;: '
         f'sous 100&#160;000&#160;€ HT de travaux, l\'acheteur peut vous consulter sans annonce.</text>')
p.append("</svg>")
SCHEMA_PARCOURS = "".join(p)

# ---------- Assemblage ----------
debut, reste = modele.split('<div class="deck-stage" id="deck-stage">', 1)
fin = reste[reste.index("  <!-- Framework chrome"):]

# Le moteur (premier <style>) n'est pas touché ; les ajouts vont à la fin du second <style>.
i = debut.rindex("</style>")
debut = debut[:i] + CSS_AJOUT + "  " + debut[i:]
debut = re.sub(r"<title>.*?</title>", f"<title>{TITRE}</title>", debut, flags=re.S)
# Piège connu des modèles Picant3 : une règle « écran étroit » sans « screen » s'applique aussi à l'impression.
debut = re.sub(r"@media \(max-width", "@media screen and (max-width", debut)
assert not re.search(r"@media \((max|min)-width", debut)

diapos = re.sub(r"[ \t]*<!--.*?-->\n?", "", diapos, flags=re.S)  # commentaires de rédaction : pas dans le support
total = diapos.count('<section class="slide"')
numeros = iter(range(1, total + 1))
labels = iter(range(1, total + 1))
pied = ('<footer class="sfoot">\n      <span class="brand"><img src="' + logo + '" alt="Picant3" />'
        '<span class="wm">Picant<span class="three">3</span></span></span>\n'
        '      <span class="meta"><b>' + MENTION + '</b> · Marchés publics · {n:02d} / {total:02d}</span>\n    </footer>')
diapos = re.sub("__PIED__", lambda m: pied.format(n=next(numeros), total=total), diapos)
diapos = re.sub(r'data-screen-label="', lambda m: f'data-screen-label="{next(labels):02d} ', diapos)
diapos = diapos.replace('<section class="slide"', '<section class="slide active"', 1)
diapos = diapos.replace("__SCHEMA_PARCOURS__", SCHEMA_PARCOURS)
assert "__" not in re.sub(r"<!--.*?-->", "", diapos, flags=re.S), "jeton non remplacé"
assert diapos.count("<footer") == total, "une diapositive n'a pas de __PIED__"

html = f'{debut}<div class="deck-stage" id="deck-stage">\n\n{diapos}\n    </div>\n  </div>\n\n{fin}'
assert "commercial" not in html.lower(), "mention « commerciale » restante"
open(sortie_path, "w", encoding="utf-8").write(html)
print(f"{sortie_path} : {total} diapositives, {len(html)} octets")
