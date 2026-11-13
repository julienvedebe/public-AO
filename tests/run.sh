#!/bin/bash
# Lance les scénarios de conversation sans interface et vérifie leur résultat.
#
# Usage : tests/run.sh [scénario ...]   (tous les scénarios par défaut)
# Variables : AGENT       claude (défaut) ou codex
#             CLAUDE_BIN  binaire Claude Code (défaut : claude)
#             CODEX_BIN   binaire Codex (défaut : codex)
#             GARDER=1    conserve les dossiers temporaires pour inspection
set -uo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
CLAUDE_BIN=${CLAUDE_BIN:-claude}
CODEX_BIN=${CODEX_BIN:-codex}
AGENT=${AGENT:-claude}

# Agent choisi : lancer_agent "<prompt>" (sans interface) et dossier de skills du projet temporaire.
case "$AGENT" in
  claude) AGENT_BIN=$CLAUDE_BIN; SKILLS_REL=.claude/skills
          lancer_agent() { "$CLAUDE_BIN" -p "$1" --permission-mode bypassPermissions; } ;;
  codex)  AGENT_BIN=$CODEX_BIN; SKILLS_REL=.agents/skills
          lancer_agent() { "$CODEX_BIN" exec --dangerously-bypass-approvals-and-sandbox "$1"; } ;;
  *) echo "AGENT doit valoir claude ou codex (reçu : $AGENT)."; exit 2 ;;
esac
SCENARIOS_DIR="$ROOT/tests/scenarios"

if [ $# -gt 0 ]; then
  scenarios=("$@")
else
  scenarios=()
  for d in "$SCENARIOS_DIR"/*/; do scenarios+=("$(basename "$d")"); done
fi

verif=$(lancer_agent "réponds juste : ok" 2>&1)
if [ $? -ne 0 ] || grep -q 'Not logged in' <<< "$verif"; then
  echo "L'agent $AGENT ($AGENT_BIN) n'est pas utilisable ou pas connecté."
  echo "Lancez-le une fois dans un terminal et connectez-vous, puis relancez les tests."
  exit 2
fi

echecs=0
for s in "${scenarios[@]}"; do
  dir="$SCENARIOS_DIR/$s"
  [ -f "$dir/prompt.txt" ] || { echo "✗ $s : scénario introuvable"; echecs=$((echecs + 1)); continue; }

  W=$(mktemp -d)
  D="$W/Documents/Marchés publics"
  S="$W/skills-installes"

  # Dossier de travail de départ, si le scénario en fournit un.
  if [ -d "$dir/dossier" ]; then
    mkdir -p "$D"
    cp -R "$dir/dossier/." "$D/"
  fi

  # Ancienne version du skill déjà installée, si le scénario en fournit une.
  if [ -d "$dir/skill-installe" ]; then
    mkdir -p "$S/marches-publics"
    cp -R "$dir/skill-installe/." "$S/marches-publics/"
  fi

  # Skill préinstallé au niveau du projet temporaire, sauf pour les scénarios d'installation.
  if [ ! -f "$dir/sans-preinstallation" ]; then
    mkdir -p "$W/$SKILLS_REL"
    cp -R "$ROOT/skill/marches-publics" "$W/$SKILLS_REL/"
  fi

  prompt=$(sed "s|{{ROOT}}|$ROOT|g" "$dir/prompt.txt")

  echo "▶ $s"
  (
    cd "$W" &&
    MARCHES_PUBLICS_DOSSIER="$D" \
    MARCHES_PUBLICS_SKILLS_DIR="$S" \
    MARCHES_PUBLICS_SOURCE="$ROOT" \
    lancer_agent "$prompt"
  ) > "$W/sortie.txt" 2>&1

  if ROOT="$ROOT" W="$W" D="$D" S="$S" SORTIE="$W/sortie.txt" bash "$dir/check.sh"; then
    echo "✓ $s"
  else
    echo "✗ $s (sortie : $W/sortie.txt)"
    echecs=$((echecs + 1))
    GARDER=1
  fi

  [ "${GARDER:-0}" = 1 ] || rm -rf "$W"
done

echo
[ $echecs -eq 0 ] && echo "Tous les scénarios passent." || echo "$echecs scénario(s) en échec."
exit $echecs
