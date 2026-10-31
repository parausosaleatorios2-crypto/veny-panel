#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  build_ipa.sh  —  AMZP iOS  →  AMZP.ipa
#
#  Requisitos:
#    • macOS + Xcode instalado (xcodebuild, xcrun)
#    • Apple Developer Account (free ou pago)
#    • Conecte um iPhone ou use simulador para teste
#
#  Uso:
#    chmod +x build_ipa.sh
#    ./build_ipa.sh
#
#  O .ipa gerado estará em ./build/AMZP.ipa
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_FILE="$PROJECT_DIR/AMZP.xcodeproj"
SCHEME="AMZP"
CONFIGURATION="Release"
BUILD_DIR="$PROJECT_DIR/build"
ARCHIVE_PATH="$BUILD_DIR/AMZP.xcarchive"
IPA_DIR="$BUILD_DIR/ipa"
IPA_PATH="$BUILD_DIR/AMZP.ipa"

BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
RESET="\033[0m"

info()  { echo -e "${BOLD}[AMZP]${RESET} $*"; }
ok()    { echo -e "${GREEN}[OK]${RESET} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${RESET} $*"; }
die()   { echo -e "${RED}[ERRO]${RESET} $*"; exit 1; }

# ── verificar dependências ────────────────────────────────────────────────────
command -v xcodebuild &>/dev/null || die "xcodebuild não encontrado. Instale o Xcode."
command -v xcrun      &>/dev/null || die "xcrun não encontrado. Instale o Xcode."

XCODE_VER=$(xcodebuild -version | head -1)
info "Usando $XCODE_VER"

# ── limpar build anterior ─────────────────────────────────────────────────────
info "Limpando build anterior..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR" "$IPA_DIR"

# ── resolver Team ID ──────────────────────────────────────────────────────────
TEAM_ID=""
if [ -z "$TEAM_ID" ]; then
    # tenta detectar automaticamente pelo primeiro team disponível
    TEAM_ID=$(security find-identity -v -p codesigning 2>/dev/null | \
        grep -oE '"[^"]*"\s+([A-Z0-9]{10})' | \
        awk '{print $NF}' | head -1 || true)
fi

if [ -z "$TEAM_ID" ]; then
    warn "TEAM_ID não detectado. Compilando sem assinatura (para simulador)."
    CODE_SIGN_FLAGS="CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO CODE_SIGN_IDENTITY= CODE_SIGN_ENTITLEMENTS="
    DESTINATION="generic/platform=iOS Simulator"
else
    info "Team ID detectado: $TEAM_ID"
    CODE_SIGN_FLAGS="DEVELOPMENT_TEAM=$TEAM_ID CODE_SIGN_STYLE=Automatic"
    DESTINATION="generic/platform=iOS"
fi

# ── etapa 1: archive ──────────────────────────────────────────────────────────
info "Compilando e criando archive..."
xcodebuild archive \
    -project "$PROJECT_FILE" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "$DESTINATION" \
    -archivePath "$ARCHIVE_PATH" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    $CODE_SIGN_FLAGS \
    | xcpretty 2>/dev/null || true

# xcpretty pode não estar instalado — tenta sem ele
if [ ! -d "$ARCHIVE_PATH" ]; then
    warn "Tentando sem xcpretty..."
    xcodebuild archive \
        -project "$PROJECT_FILE" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -destination "$DESTINATION" \
        -archivePath "$ARCHIVE_PATH" \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        $CODE_SIGN_FLAGS
fi

[ -d "$ARCHIVE_PATH" ] || die "Archive falhou. Verifique erros acima."
ok "Archive criado em $ARCHIVE_PATH"

# ── etapa 2: exportar .ipa ───────────────────────────────────────────────────
info "Exportando .ipa..."

if [ -n "$TEAM_ID" ]; then
    # Gera ExportOptions.plist para device real
    cat > "$BUILD_DIR/ExportOptions.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string>${TEAM_ID}</string>
    <key>compileBitcode</key>
    <false/>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
PLIST

    xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportPath "$IPA_DIR" \
        -exportOptionsPlist "$BUILD_DIR/ExportOptions.plist"

    # mover o ipa gerado
    find "$IPA_DIR" -name "*.ipa" -exec mv {} "$IPA_PATH" \;
else
    # sem assinatura: empacota manualmente (útil para AltStore / Sideloading)
    info "Empacotando .ipa sem assinatura (sideload / AltStore)..."
    APP_BUNDLE=$(find "$ARCHIVE_PATH/Products/Applications" -name "*.app" | head -1)
    [ -n "$APP_BUNDLE" ] || die "Nenhum .app encontrado no archive."

    PAYLOAD_DIR="$BUILD_DIR/Payload"
    mkdir -p "$PAYLOAD_DIR"
    cp -r "$APP_BUNDLE" "$PAYLOAD_DIR/"
    (cd "$BUILD_DIR" && zip -qr "AMZP.ipa" "Payload/")
    rm -rf "$PAYLOAD_DIR"
fi

[ -f "$IPA_PATH" ] || die ".ipa não foi gerado. Verifique erros acima."

IPA_SIZE=$(du -sh "$IPA_PATH" | cut -f1)
ok "AMZP.ipa gerado com sucesso! ($IPA_SIZE)"
echo ""
echo -e "  ${BOLD}📦 Arquivo:${RESET} $IPA_PATH"
echo ""
echo -e "  ${BOLD}Como instalar:${RESET}"
echo -e "   • AltStore / Sideloadly → arraste o AMZP.ipa"
echo -e "   • Xcode Organizer        → Window → Devices → instale o .ipa"
echo -e "   • xcrun simctl install   → (se gerado para simulador)"
echo ""
