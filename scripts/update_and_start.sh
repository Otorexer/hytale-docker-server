#!/bin/bash

# --- 1. Definir archivos importantes ---
# Estos son los archivos que NO queremos perder (Auth, Admins, etc.)
CONFIG_FILE="Server/configs.json"
PERM_FILE="Server/permissions.json"

echo "Checking for Hytale updates..."

if hytale-downloader -download-path /hytale/data/update.zip; then
    if [ -f "/hytale/data/update.zip" ]; then
        echo "Update found!"
        
        # PASO 1: COPIA DE SEGURIDAD (Backup)
        # Si ya tienes configuración, la guardamos en /tmp para que el zip no la borre
        if [ -f "$CONFIG_FILE" ]; then
            echo "Backing up configuration..."
            cp "$CONFIG_FILE" /tmp/configs.json.bak
        fi
        if [ -f "$PERM_FILE" ]; then
            cp "$PERM_FILE" /tmp/permissions.json.bak
        fi

        # PASO 2: ACTUALIZAR (Sobrescribir todo)
        # Usamos -o (Overwrite) para asegurar que el juego esté limpio y actualizado
        echo "Extracting update..."
        unzip -o /hytale/data/update.zip -d /hytale/data/
        
        # PASO 3: RESTAURAR (Restore)
        # Volvemos a poner tu configuración encima de la que traía el zip
        if [ -f "/tmp/configs.json.bak" ]; then
            echo "Restoring configuration (Auth preserved)..."
            cp /tmp/configs.json.bak "$CONFIG_FILE"
        fi
        if [ -f "/tmp/permissions.json.bak" ]; then
            cp /tmp/permissions.json.bak "$PERM_FILE"
        fi
        
        # Limpieza
        rm /hytale/data/update.zip
    fi
else
    echo "No update found or check skipped."
fi

# Crear directorio de logs
mkdir -p logs
touch logs/hytale.log

# --- Watchdog (Vigilante) ---
# Vigila si hay errores graves y reinicia el contenedor si el servidor muere
echo "Starting Watchdog..."
( tail -f -n0 logs/hytale.log | grep -q -E "java.lang.NullPointerException|Exception in thread" && echo "WATCHDOG: Crash detected! Killing server..." && kill 1 ) &

# --- Iniciar Servidor (Con soporte para comandos) ---
if [ -f "Server/HytaleServer.jar" ]; then
    echo "Starting Hytale Server..."
    
    # Usamos 'exec' y 'tee' para que puedas escribir comandos Y el watchdog pueda leer los logs
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