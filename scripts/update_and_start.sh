#!/bin/bash

# --- 1. Smart Update Section ---
echo "Checking for Hytale updates..."

# Attempt download.
if hytale-downloader -download-path /hytale/data/update.zip; then
    if [ -f "/hytale/data/update.zip" ]; then
        echo "Update found! Applying Smart Patch..."
        
        # CHANGED: 'unzip -u' (Update) instead of '-o' (Overwrite).
        # This prevents it from deleting your configs and auth tokens.
        unzip -u /hytale/data/update.zip -d /hytale/data/
        
        # Cleanup
        rm /hytale/data/update.zip
    fi
else
    echo "No update found or check skipped."
fi

# Ensure log directory exists for the watchdog
mkdir -p logs
touch logs/hytale.log

# --- 2. Startup & Watchdog Section ---
if [ -f "Server/HytaleServer.jar" ]; then
    echo "Starting Hytale Server..."

    # Start the server in the background
    java -Xmx${RAM_MAX} -Xms${RAM_MIN} -XX:AOTCache=Server/HytaleServer.aot -jar Server/HytaleServer.jar --assets Assets.zip --bind 0.0.0.0:5520 &
    SERVER_PID=$!
    
    # Watchdog: Kills server if it sees a crash in the logs
    ( tail -f -n0 logs/hytale.log | grep -q -E "java.lang.NullPointerException|Exception in thread" && echo "WATCHDOG: Crash detected! Restarting..." && kill -9 $SERVER_PID ) &
    WATCHDOG_PID=$!
    
    # Keep the container running as long as the server is alive
    wait $SERVER_PID
    
    # Cleanup watchdog when server stops normally
    kill $WATCHDOG_PID
else
    echo "ERROR: HytaleServer.jar not found. The download may have failed."
    sleep 300
fi