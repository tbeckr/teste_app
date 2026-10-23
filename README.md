# HelloApp (iOS, SwiftUI)

Hello world nativo, desenvolvido no Linux. O build roda num Mac na nuvem (GitHub Actions) e gera um `.ipa` sem assinatura; a assinatura com Apple ID gratuito é feita na instalação.

## Estrutura

- `project.yml` – definição do projeto (XcodeGen gera o `.xcodeproj` no CI; não é versionado)
- `HelloApp/` – código Swift
- `.github/workflows/ios-build.yml` – build no macOS
- `scripts/build.sh` – push, dispara o workflow, baixa `build/HelloApp.ipa`
- `scripts/deploy.sh` – assina e instala no iPhone via USB

## Primeiro uso

```bash
# 1. Repositório no GitHub (público = minutos de macOS grátis)
git init -b main && git add -A && git commit -m "hello world"
gh auth login
gh repo create teste_app --public --source=. --remote=origin

# 2. Build
scripts/build.sh

# 3. Deploy
export APPLE_ID=seu@email APPLE_PASSWORD=...
export ALTSERVER=/caminho/para/AltServer
scripts/deploy.sh
```

## Dependências no Linux

- `gh`, `git`
- Para o deploy: `usbmuxd`, `libimobiledevice-utils` (`sudo apt install usbmuxd libimobiledevice-utils`) e o
  [AltServer-Linux](https://github.com/NyaMisty/AltServer-Linux) (binário das releases; requer também o `libstdc++`/`libssl` do sistema e um servidor anisette, veja o README dele).

## Limitações do Apple ID gratuito

- App expira em 7 dias (rode `deploy.sh` de novo)
- Máx. 3 apps ativos, sem push/iCloud, sem TestFlight
- Mude o `PRODUCT_BUNDLE_IDENTIFIER` em `project.yml` se der conflito de ID

## Observações

Os scripts não foram testados de ponta a ponta. O ponto mais sujeito a ajustes é o `deploy.sh`: as flags do AltServer-Linux e o anisette mudam entre versões. Se não funcionar, baixe `build/HelloApp.ipa` e instale com Sideloadly/AltStore em outra máquina.
