#!/bin/bash

# --- 1. Smart Update Section ---
echo "Checking for Hytale updates..."

if hytale-downloader -download-path /hytale/data/update.zip; then
    if [ -f "/hytale/data/update.zip" ]; then
        echo "Update found! Extracting..."
        
        # CRITICAL FIX: 
        # -o: Overwrite game files (so you get the latest version)
        # -x: EXCLUDE config files (so your Auth Token is NEVER deleted)
        unzip -o /hytale/data/update.zip -d /hytale/data/ -x "configs.json" "permissions.json" "server.properties"
        
        rm /hytale/data/update.zip
    fi
else
    echo "No update found or check skipped."
fi

# Create logs directory
mkdir -p logs
touch logs/hytale.log

# --- 2. Start Watchdog (Background) ---
# It watches the log file. If it sees a crash, it kills the container (PID 1).
echo "Starting Watchdog..."
( tail -f -n0 logs/hytale.log | grep -q -E "java.lang.NullPointerException|Exception in thread" && echo "WATCHDOG: Crash detected! Killing server..." && kill 1 ) &

# --- 3. Start Server (Foreground) ---
if [ -f "Server/HytaleServer.jar" ]; then
    echo "Starting Hytale Server..."
    
    # MAGIC TRICK:
    # We use 'exec' to replace the shell with Java (keeping your keyboard connected).
    # We use '> >(tee ...)' to send logs to the file for the watchdog WITHOUT breaking the console.
    exec java -Xmx${RAM_MAX} -Xms${RAM_MIN} \
         -XX:AOTCache=Server/HytaleServer.aot \
         -jar Server/HytaleServer.jar \
         --assets Assets.zip \
         --bind 0.0.0.0:5520 \
         > >(tee -a logs/hytale.log) 2>&1

else
    echo "ERROR: HytaleServer.jar not found."
    sleep 300
fi