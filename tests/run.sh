#!/bin/bash
# Lance les scénarios de conversation sans interface et vérifie leur résultat.
#
# Usage : tests/run.sh [scénario ...]   (tous les scénarios par défaut)
# Variables : CLAUDE_BIN  binaire Claude Code (défaut : claude)
#             GARDER=1    conserve les dossiers temporaires pour inspection
set -uo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
CLAUDE_BIN=${CLAUDE_BIN:-claude}
SCENARIOS_DIR="$ROOT/tests/scenarios"

if [ $# -gt 0 ]; then
  scenarios=("$@")
else
  scenarios=()
  for d in "$SCENARIOS_DIR"/*/; do scenarios+=("$(basename "$d")"); done
fi

verif=$("$CLAUDE_BIN" -p "réponds juste : ok" 2>&1)
if [ $? -ne 0 ] || grep -q 'Not logged in' <<< "$verif"; then
  echo "Claude Code ($CLAUDE_BIN) n'est pas utilisable ou pas connecté."
  echo "Lancez-le une fois dans un terminal et tapez /login, puis relancez les tests."
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

  # Skill préinstallé au niveau du projet temporaire, sauf pour les scénarios d'installation.
  if [ ! -f "$dir/sans-preinstallation" ]; then
    mkdir -p "$W/.claude/skills"
    cp -R "$ROOT/skill/marches-publics" "$W/.claude/skills/"
  fi

  # Un message de l'artisan par tour ; les tours sont séparés par une ligne « --- ».
  sed "s|{{ROOT}}|$ROOT|g" "$dir/prompt.txt" |
    awk -v base="$W/tour-" 'BEGIN { n = 1 } /^---$/ { n++; next } { print > (base n ".txt") }'
  tours=$(ls "$W"/tour-*.txt | wc -l | tr -d ' ')

  echo "▶ $s"
  : > "$W/sortie.txt"
  for i in $(seq 1 "$tours"); do
    suite=()
    [ "$i" -gt 1 ] && suite=(--continue)
    (
      cd "$W" &&
      MARCHES_PUBLICS_DOSSIER="$D" \
      MARCHES_PUBLICS_SKILLS_DIR="$S" \
      MARCHES_PUBLICS_SOURCE="$ROOT" \
      "$CLAUDE_BIN" -p "$(cat "$W/tour-$i.txt")" ${suite[@]+"${suite[@]}"} --permission-mode bypassPermissions
    ) > "$W/sortie-$i.txt" 2>&1
    { echo "=== tour $i"; cat "$W/sortie-$i.txt"; echo; } >> "$W/sortie.txt"
  done

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
