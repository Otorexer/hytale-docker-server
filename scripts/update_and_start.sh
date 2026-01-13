#!/bin/bash

# --- 1. Definir archivos importantes (LISTA DE PROTECCIÓN) ---
# Estos son los archivos que NO queremos perder nunca.
# Protegemos tanto rutas en la raíz como dentro de Server/ por seguridad.
FILES_TO_SAVE=(
    "Server/configs.json"
    "Server/permissions.json"
    "Server/auth.enc"
    "configs.json"
    "permissions.json"
    "auth.enc"
)

echo "Checking for Hytale updates..."

if hytale-downloader -download-path /hytale/data/update.zip; then
    if [ -f "/hytale/data/update.zip" ]; then
        echo "Update found! Starting Smart Update process..."
        
        # PASO A: COPIA DE SEGURIDAD (Backup)
        echo "Backing up sensitive files..."
        mkdir -p /tmp/hytale_backup
        for file in "${FILES_TO_SAVE[@]}"; do
            if [ -f "$file" ]; then
                # Guardamos el archivo manteniendo su estructura de carpetas
                cp --parents "$file" /tmp/hytale_backup/
                echo "Saved: $file"
            fi
        done

        # PASO B: ACTUALIZAR (Sobrescribir todo con la nueva versión)
        echo "Extracting game files..."
        unzip -o /hytale/data/update.zip -d /hytale/data/
        
        # PASO C: RESTAURAR (Restore)
        echo "Restoring sensitive files..."
        if [ -d "/tmp/hytale_backup" ]; then
            cp -r /tmp/hytale_backup/* .
            rm -rf /tmp/hytale_backup
        fi
        
        # Limpieza del zip
        rm /hytale/data/update.zip
    fi
else
    echo "No update found or check skipped."
fi

# Crear directorio de logs
mkdir -p logs
touch logs/hytale.log

# --- Watchdog (Vigilante) ---
echo "Starting Watchdog..."
( tail -f -n0 logs/hytale.log | grep -q -E "java.lang.NullPointerException|Exception in thread" && echo "WATCHDOG: Crash detected! Killing server..." && kill 1 ) &

# --- Iniciar Servidor (Foreground + Pipe) ---
if [ -f "Server/HytaleServer.jar" ]; then
    echo "Starting Hytale Server..."
    
    # Arrancamos Java conectando la consola (exec) y guardando logs (tee)
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