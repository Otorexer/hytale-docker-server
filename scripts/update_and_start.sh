#!/bin/bash
# DO NOT use 'set -e' here so it doesn't crash on 403 errors
echo "Checking for Hytale updates..."
if hytale-downloader -download-path /hytale/data/update.zip; then
    if [ -f "/hytale/data/update.zip" ]; then
        echo "Update found! Extracting..."
        unzip -o /hytale/data/update.zip -d /hytale/data/
        rm /hytale/data/update.zip
    fi
else
    echo "Update check skipped or failed (403 Forbidden). This is normal during first-time setup."
fi

# FIX: Check inside the 'Server' directory
if [ -f "Server/HytaleServer.jar" ]; then
    echo "Starting Hytale Server..."
    # FIX: Point to Server/HytaleServer.jar and Server/HytaleServer.aot
    exec java -Xmx${RAM_MAX} -Xms${RAM_MIN} -XX:AOTCache=Server/HytaleServer.aot -jar Server/HytaleServer.jar --assets Assets.zip --bind 0.0.0.0:5520
else
    echo "HytaleServer.jar not found in ./Server/. Please check the download."
    # Prevent tight restart loop if files are missing
    sleep 300
fi