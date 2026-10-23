#!/usr/bin/env bash
# Assina o .ipa com seu Apple ID gratuito e instala no iPhone via USB (Linux).
# Usa AltServer-Linux: https://github.com/NyaMisty/AltServer-Linux
# Requisitos: usbmuxd, libimobiledevice (idevicepair), AltServer, anisette (veja README).
# Variáveis: APPLE_ID, APPLE_PASSWORD (use senha do Apple ID; 2FA será pedido), ALTSERVER (caminho do binário)
set -euo pipefail
cd "$(dirname "$0")/.."

IPA=${1:-build/HelloApp.ipa}
ALTSERVER=${ALTSERVER:-AltServer}
: "${APPLE_ID:?Defina APPLE_ID=seu@email}"
: "${APPLE_PASSWORD:?Defina APPLE_PASSWORD}"

[ -f "$IPA" ] || { echo "$IPA não existe. Rode scripts/build.sh antes."; exit 1; }
command -v "$ALTSERVER" >/dev/null || [ -x "$ALTSERVER" ] || { echo "AltServer não encontrado. Defina ALTSERVER=/caminho/AltServer"; exit 1; }
command -v idevice_id >/dev/null || { echo "Instale libimobiledevice-utils e usbmuxd."; exit 1; }

UDID=$(idevice_id -l | head -n1)
[ -n "$UDID" ] || { echo "Nenhum iPhone detectado. Conecte via USB, desbloqueie e confie no computador."; exit 1; }
echo ">> Dispositivo: $UDID"

idevicepair pair || true

echo ">> Instalando $IPA (expira em 7 dias)"
"$ALTSERVER" -u "$UDID" -a "$APPLE_ID" -p "$APPLE_PASSWORD" "$IPA"

echo ">> No iPhone: Ajustes > Geral > VPN e Gerenciamento de Dispositivo > confie no seu Apple ID."
echo ">> Se for iOS 16+, ative o Modo Desenvolvedor em Ajustes > Privacidade e Segurança."
