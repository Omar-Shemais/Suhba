#!/bin/bash
set -e

DOWNLOAD_DIR="/home/seg/Downloads"
DEV_DIR="/home/seg/development"
LOG_FILE="$DOWNLOAD_DIR/install_tools.log"

mkdir -p "$DEV_DIR"
mkdir -p "$DOWNLOAD_DIR"

echo "=== Starting Flutter & Android Studio setup: $(date) ===" | tee -a "$LOG_FILE"

# 1. Download Flutter SDK
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.47.7-stable.tar.xz"
FLUTTER_ARCHIVE="$DOWNLOAD_DIR/flutter_linux_3.47.7-stable.tar.xz"

echo "[1/4] Downloading Flutter SDK..." | tee -a "$LOG_FILE"
wget -c --progress=dot:giga "$FLUTTER_URL" -O "$FLUTTER_ARCHIVE" 2>&1 | tee -a "$LOG_FILE"

echo "[2/4] Extracting Flutter SDK to $DEV_DIR..." | tee -a "$LOG_FILE"
tar -xf "$FLUTTER_ARCHIVE" -C "$DEV_DIR" 2>&1 | tee -a "$LOG_FILE"

# 2. Download Android Studio
STUDIO_URL="https://edgedl.me.gvt1.com/android/studio/ide-zips/2026.2.1.8/android-studio-rabbit1-linux.tar.gz"
STUDIO_ARCHIVE="$DOWNLOAD_DIR/android-studio-rabbit1-linux.tar.gz"

echo "[3/4] Downloading Android Studio..." | tee -a "$LOG_FILE"
wget -c --progress=dot:giga "$STUDIO_URL" -O "$STUDIO_ARCHIVE" 2>&1 | tee -a "$LOG_FILE"

echo "[4/4] Extracting Android Studio to $DEV_DIR..." | tee -a "$LOG_FILE"
tar -xzf "$STUDIO_ARCHIVE" -C "$DEV_DIR" 2>&1 | tee -a "$LOG_FILE"

# 3. Setup PATH in .bashrc if not present
if ! grep -q "flutter/bin" "$HOME/.bashrc" 2>/dev/null; then
    echo '' >> "$HOME/.bashrc"
    echo '# Flutter SDK Path' >> "$HOME/.bashrc"
    echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> "$HOME/.bashrc"
    echo "Added Flutter to ~/.bashrc" | tee -a "$LOG_FILE"
fi

if ! grep -q "flutter/bin" "$HOME/.profile" 2>/dev/null; then
    echo '' >> "$HOME/.profile"
    echo '# Flutter SDK Path' >> "$HOME/.profile"
    echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> "$HOME/.profile"
    echo "Added Flutter to ~/.profile" | tee -a "$LOG_FILE"
fi

# 4. Create Desktop Shortcut for Android Studio
mkdir -p "$HOME/.local/share/applications"
cat << 'DESKTOP_EOF' > "$HOME/.local/share/applications/android-studio.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Android Studio
Comment=Android Studio IDE
Exec=/home/seg/development/android-studio/bin/studio.sh
Icon=/home/seg/development/android-studio/bin/studio.svg
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-studio
DESKTOP_EOF
chmod +x "$HOME/.local/share/applications/android-studio.desktop"

echo "=== All downloads and extractions completed successfully! $(date) ===" | tee -a "$LOG_FILE"
