#!/bin/bash
set -e

SDK_DIR="/home/seg/Android/Sdk"
TOOLS_ZIP="/home/seg/Downloads/commandlinetools-linux.zip"
LOG_FILE="/home/seg/Downloads/emulator_setup.log"

export JAVA_HOME="/home/seg/development/android-studio/jbr"
export PATH="$JAVA_HOME/bin:$PATH"
export ANDROID_HOME="$SDK_DIR"
export ANDROID_SDK_ROOT="$SDK_DIR"

echo "=== Android Emulator Setup Starting: $(date) ===" | tee -a "$LOG_FILE"

# 1. Wait for commandlinetools download if still running
while ps aux | grep -v grep | grep -q "commandlinetools-linux.*zip"; do
    echo "Waiting for commandlinetools download..." | tee -a "$LOG_FILE"
    sleep 3
done

# 2. Extract cmdline-tools
echo "Extracting command line tools to $SDK_DIR/cmdline-tools/latest..." | tee -a "$LOG_FILE"
mkdir -p "$SDK_DIR/cmdline-tools"
rm -rf /tmp/cmdline-tools-extract
mkdir -p /tmp/cmdline-tools-extract
unzip -q -o "$TOOLS_ZIP" -d /tmp/cmdline-tools-extract
rm -rf "$SDK_DIR/cmdline-tools/latest"
mv /tmp/cmdline-tools-extract/cmdline-tools "$SDK_DIR/cmdline-tools/latest"
rm -rf /tmp/cmdline-tools-extract

CMDLINE_BIN="$SDK_DIR/cmdline-tools/latest/bin"
export PATH="$CMDLINE_BIN:$SDK_DIR/platform-tools:$SDK_DIR/emulator:$PATH"

# 3. Accept all licenses
echo "Accepting licenses..." | tee -a "$LOG_FILE"
yes | "$CMDLINE_BIN/sdkmanager" --licenses > /dev/null 2>&1 || true

# 4. Install required packages
echo "Installing platform-tools, emulator, and system-image (this may take a few minutes)..." | tee -a "$LOG_FILE"
"$CMDLINE_BIN/sdkmanager" "platform-tools" "emulator" "platforms;android-34" "system-images;android-34;google_apis;x86_64" | tee -a "$LOG_FILE"

# 5. Create AVD
echo "Creating Android Virtual Device (Pixel_7_API_34)..." | tee -a "$LOG_FILE"
echo "no" | "$CMDLINE_BIN/avdmanager" create avd -n "Pixel_7_API_34" -k "system-images;android-34;google_apis;x86_64" --device "pixel_7" --force | tee -a "$LOG_FILE"

echo "=== Setup complete! Starting Emulator... $(date) ===" | tee -a "$LOG_FILE"

# 6. Launch Emulator
"$SDK_DIR/emulator/emulator" -avd "Pixel_7_API_34" -netdelay none -netspeed full &

echo "Emulator launched in background PID: $!" | tee -a "$LOG_FILE"
