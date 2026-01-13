#!/bin/bash

echo "Checking for Hytale updates..."
if hytale-downloader -download-path /hytale/data/update.zip; then
    if [ -f "/hytale/data/update.zip" ]; then
        echo "Update found! Extracting..."
        unzip -o /hytale/data/update.zip -d /hytale/data/
        rm /hytale/data/update.zip
    fi
else
    echo "Update check skipped or failed. Normal during first-time setup."
fi

# Ensure the logs directory exists so the tail command doesn't fail
mkdir -p logs
touch logs/hytale.log

if [ -f "Server/HytaleServer.jar" ]; then
    echo "Starting Hytale Server with Watchdog..."
    
    # 1. Start Hytale in the background (&)
    java -Xmx${RAM_MAX} -Xms${RAM_MIN} -XX:AOTCache=Server/HytaleServer.aot -jar Server/HytaleServer.jar --assets Assets.zip --bind 0.0.0.0:5520 &
    
    # Capture the Process ID (PID) of the server
    SERVER_PID=$!
    
    # 2. Start the Watchdog in the background
    # It reads the log file. If it sees "java.lang.NullPointerException" or "Exception", it kills the server.
    ( tail -f -n0 logs/hytale.log | grep -q -E "java.lang.NullPointerException|Exception in thread" && echo "WATCHDOG: Crash detected! Killing server..." && kill -9 $SERVER_PID ) &
    WATCHDOG_PID=$!
    
    # 3. Wait for the server to finish (or be killed)
    wait $SERVER_PID
    
    # Clean up the watchdog so it doesn't keep running
    kill $WATCHDOG_PID
    
else
    echo "HytaleServer.jar not found. Please finish the authentication step below."
    sleep 300
fi