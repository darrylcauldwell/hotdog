#!/bin/bash
set -euo pipefail

# Screenshot automation for HotDog app
# Captures empty, hotdog, and not-hotdog states on iPhone and iPad simulators

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/screenshots"
BUILD_DIR="$SCRIPT_DIR/.build/screenshots"
APP_BUNDLE_ID="dev.dreamfold.HotDog"

RUNTIME="com.apple.CoreSimulator.SimRuntime.iOS-26-2"

declare -A DEVICES
DEVICES["iPhone_17_Pro_Max"]="com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro-Max"
DEVICES["iPad_Pro_13_inch_M5"]="com.apple.CoreSimulator.SimDeviceType.iPad-Pro-13-inch-M5-12GB"

STATES=("demo-empty" "demo-hotdog" "demo-nothotdog")

cleanup() {
    echo "Cleaning up simulators..."
    for name in "${!DEVICES[@]}"; do
        local udid
        udid=$(xcrun simctl list devices | grep "HotDog-$name" | grep -oE '[0-9A-F-]{36}' | head -1 || true)
        if [ -n "$udid" ]; then
            xcrun simctl shutdown "$udid" 2>/dev/null || true
            xcrun simctl delete "$udid" 2>/dev/null || true
        fi
    done
}

trap cleanup EXIT

echo "==> Building HotDog for simulator..."
xcodebuild build \
    -project "$SCRIPT_DIR/HotDog.xcodeproj" \
    -scheme HotDog \
    -destination "generic/platform=iOS Simulator" \
    -derivedDataPath "$BUILD_DIR" \
    -quiet

APP_PATH=$(find "$BUILD_DIR" -name "HotDog.app" -path "*/Debug-iphonesimulator/*" | head -1)
if [ -z "$APP_PATH" ]; then
    echo "ERROR: Could not find built HotDog.app"
    exit 1
fi
echo "    App: $APP_PATH"

for DEVICE_NAME in "${!DEVICES[@]}"; do
    DEVICE_TYPE="${DEVICES[$DEVICE_NAME]}"
    SIM_NAME="HotDog-$DEVICE_NAME"

    echo ""
    echo "==> Setting up $DEVICE_NAME..."

    # Delete any existing simulator with this name
    EXISTING=$(xcrun simctl list devices | grep "$SIM_NAME" | grep -oE '[0-9A-F-]{36}' | head -1 || true)
    if [ -n "$EXISTING" ]; then
        xcrun simctl shutdown "$EXISTING" 2>/dev/null || true
        xcrun simctl delete "$EXISTING" 2>/dev/null || true
    fi

    # Create fresh simulator
    UDID=$(xcrun simctl create "$SIM_NAME" "$DEVICE_TYPE" "$RUNTIME")
    echo "    Created simulator: $UDID"

    # Boot
    xcrun simctl boot "$UDID"
    echo "    Booted"

    # Wait for boot to complete
    xcrun simctl bootstatus "$UDID" -b

    # Set clean status bar (9:41, full battery, full signal)
    xcrun simctl status_bar "$UDID" override \
        --time "9:41" \
        --batteryState charged \
        --batteryLevel 100 \
        --cellularMode active \
        --cellularBars 4 \
        --wifiBars 3 \
        --operatorName ""

    # Install app
    xcrun simctl install "$UDID" "$APP_PATH"
    echo "    Installed app"

    # Create output directory
    DEVICE_OUTPUT="$OUTPUT_DIR/$DEVICE_NAME"
    mkdir -p "$DEVICE_OUTPUT"

    for STATE in "${STATES[@]}"; do
        echo "    Capturing $STATE..."

        # Terminate any existing instance
        xcrun simctl terminate "$UDID" "$APP_BUNDLE_ID" 2>/dev/null || true
        sleep 0.5

        # Launch with demo argument
        xcrun simctl launch "$UDID" "$APP_BUNDLE_ID" "-$STATE"

        # Wait for app to settle (animations, image loading)
        sleep 3

        # Take screenshot
        xcrun simctl io "$UDID" screenshot "$DEVICE_OUTPUT/$STATE.png"
        echo "      Saved: $DEVICE_OUTPUT/$STATE.png"
    done

    # Shutdown this simulator
    xcrun simctl shutdown "$UDID"
    echo "    Shutdown $DEVICE_NAME"
done

echo ""
echo "==> Screenshots complete!"
echo "    Output: $OUTPUT_DIR/"
ls -la "$OUTPUT_DIR"/*/*.png 2>/dev/null || echo "    (no screenshots found)"
