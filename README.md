# Hytale Dedicated Server on Docker

This repository provides a containerized environment for running a Hytale Dedicated Server.

The image is built on top of `eclipse-temurin:25-jdk` and is designed to automatically download the latest server files from Hypixel Studios upon startup. This ensures the server is always up-to-date and compliant with the EULA, as no game files are redistributed in the image itself.

**Docker Image:** `ghcr.io/otorexer/hytale-server:latest`

## Prerequisites

- Docker Engine
- Docker Compose (optional, but recommended)

## Quick Start (Docker Compose)

The most efficient way to run the server is using Docker Compose.

1. Create a file named `docker-compose.yml` in your desired directory:

```yaml
services:
  hytale:
    image: ghcr.io/otorexer/hytale-server:latest
    container_name: hytale-server
    restart: unless-stopped
    ports:
      # Hytale uses UDP port 5520 by default
      - "5520:5520/udp"
    volumes:
      # Persist game data to a local folder
      - ./hytale_data:/hytale/data
    environment:
      - RAM_MAX=4G
      - RAM_MIN=2G
    stdin_open: true
    tty: true
```

2. Start the container in detached mode:

```bash
docker compose up -d

```

3. **Important:** Proceed immediately to the "Authentication" section below.

## Authentication (First Run)

When you run the server for the first time, or if the data directory is cleared, the server will pause during startup and require device authorization.

1. View the server logs:

```bash
docker compose logs -f

```

2. Look for an authorization message similar to the following:

```text
===================================================================
DEVICE AUTHORIZATION
Visit: https://accounts.hytale.com/device
Enter code: ABCD-1234
===================================================================

```

3. Open the provided URL in your web browser and enter the code.
4. Once authorized, the server will automatically continue the boot process.

## Configuration

You can configure the server resource allocation using environment variables.

| Variable  | Default | Description                                     |
| --------- | ------- | ----------------------------------------------- |
| `RAM_MAX` | `4G`    | Maximum RAM allocated to the Java Heap (`-Xmx`) |
| `RAM_MIN` | `2G`    | Minimum RAM allocated to the Java Heap (`-Xms`) |

### Persistence

The server stores all game data (world files, configs, logs) in the `/hytale/data` directory inside the container. You must mount a volume to this path to ensure data persists across container restarts or updates.

## Server Console Access

To execute administrative commands (such as `/op`, `/gamemode`, or `/stop`), you need to attach to the container's standard input.

1. Attach to the container:

```bash
docker attach hytale-server

```

2. Type your command and press Enter.
3. **To detach without stopping the server:**
   Press `Ctrl + P`, followed immediately by `Ctrl + Q`.

## Manual Usage (docker run)

If you prefer not to use Docker Compose, you can run the server using the standard Docker CLI:

```bash
docker run -d \
  --name hytale-server \
  -p 5520:5520/udp \
  -v $(pwd)/hytale_data:/hytale/data \
  -e RAM_MAX=4G \
  -it \
  ghcr.io/otorexer/hytale-server:latest

```

## Disclaimer

This is a community-maintained Docker image. It is not officially affiliated with, endorsed by, or connected to Hypixel Studios. All game files are downloaded directly from official sources during the container runtime.
