#!/usr/bin/env bash
# Dispara o build no GitHub Actions (macOS) e baixa o .ipa para build/HelloApp.ipa
set -euo pipefail
cd "$(dirname "$0")/.."

command -v gh >/dev/null || { echo "Instale o GitHub CLI (gh) e rode 'gh auth login'."; exit 1; }
git rev-parse --git-dir >/dev/null 2>&1 || { echo "Rode 'git init' e crie o repositório no GitHub primeiro (veja README)."; exit 1; }
git remote get-url origin >/dev/null 2>&1 || { echo "Sem remote 'origin'. Veja README."; exit 1; }

BRANCH=$(git branch --show-current)
WORKFLOW=ios-build.yml

echo ">> Enviando $BRANCH"
git push -u origin "$BRANCH"

echo ">> Disparando workflow"
START=$(date -u +%Y-%m-%dT%H:%M:%SZ)
gh workflow run "$WORKFLOW" --ref "$BRANCH"

echo ">> Aguardando run iniciar"
RUN_ID=""
for _ in $(seq 1 30); do
  RUN_ID=$(gh run list --workflow "$WORKFLOW" --event workflow_dispatch --branch "$BRANCH" \
    --json databaseId,createdAt --jq "[.[] | select(.createdAt >= \"$START\")][0].databaseId // empty")
  [ -n "$RUN_ID" ] && break
  sleep 2
done
[ -n "$RUN_ID" ] || { echo "Run não encontrado."; exit 1; }

gh run watch "$RUN_ID" --exit-status

echo ">> Baixando artefato"
rm -rf build && mkdir -p build
gh run download "$RUN_ID" -n HelloApp-ipa -D build
echo ">> Pronto: build/HelloApp.ipa"
