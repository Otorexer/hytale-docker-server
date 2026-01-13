#!/bin/bash

# --- 1. Smart Update Section ---
echo "Checking for Hytale updates..."

# Download the update
if hytale-downloader -download-path /hytale/data/update.zip; then
    if [ -f "/hytale/data/update.zip" ]; then
        echo "Update found! Applying Smart Patch..."
        
        # EXCLUDE sensitive files from being overwritten (Config, Auth, Permissions)
        # We unzip everything EXCEPT (-x) the config files that might contain your auth token.
        unzip -o /hytale/data/update.zip -d /hytale/data/ -x "configs.json" "permissions.json" "server.properties"
        
        # Clean up
        rm /hytale/data/update.zip
    fi
else
    echo "No update found or check skipped."
fi

# Create logs directory if it doesn't exist
mkdir -p logs
touch logs/hytale.log

# --- 2. Advanced Startup (Watchdog + Input Support) ---
if [ -f "Server/HytaleServer.jar" ]; then
    echo "Starting Hytale Server..."
    
    # Run the server directly in the foreground, but use 'tee' to split the logs
    # pipe: process substitution allows us to view logs AND run the watchdog
    
    # We trap the PID of the java process to allow the watchdog to kill it
    (
        java -Xmx${RAM_MAX} -Xms${RAM_MIN} \
             -XX:AOTCache=Server/HytaleServer.aot \
             -jar Server/HytaleServer.jar \
             --assets Assets.zip \
             --bind 0.0.0.0:5520
    ) & 
    SERVER_PID=$!

    # Watchdog Logic: Monitors the log file for crash signatures
    # If found, it kills the server process, causing the container to exit (and Docker to restart it)
    ( tail -f -n0 logs/hytale.log | grep -q -E "java.lang.NullPointerException|Exception in thread" && echo "WATCHDOG: Crash detected! Killing server..." && kill -9 $SERVER_PID ) &
    WATCHDOG_PID=$!

    # Wait for the server to exit naturally
    wait $SERVER_PID
    
    # Cleanup watchdog
    kill $WATCHDOG_PID
    
else
    echo "ERROR: HytaleServer.jar not found. The download may have failed."
    sleep 300
fi