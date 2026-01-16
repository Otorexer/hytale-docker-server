# Hytale Dedicated Server on Docker

This repository provides a production-ready, containerized environment for running a Hytale Dedicated Server.

It includes:

- **Auto-Updates:** Downloads the latest game files on startup.
- **Auto-Restart:** Watchdog system detects crashes and restarts the server.
- **Persistence:** Smart logic preserves your authentication and config files.

**Docker Image:** `ghcr.io/otorexer/hytale-server:latest`

## Prerequisites

- Docker Engine
- Docker Compose

## Quick Start

1. Create a `docker-compose.yml` file:

```yaml
services:
  hytale:
    image: ghcr.io/otorexer/hytale-server:latest
    container_name: hytale-server
    restart: unless-stopped
    ports:
      - "5520:5520/udp"
    volumes:
      - ./hytale_data:/hytale/data
    environment:
      - RAM_MAX=6G
      - RAM_MIN=4G
    stdin_open: true
    tty: true
```

2. Start the server:

```bash
docker compose up -d

```

## Important: First Time Setup

You must authenticate the server **and save the credentials** manually the first time.

1. **Attach to the console:**

```bash
docker attach hytale-server

```

_(If you don't see anything, press Enter)_. 2. **Login:**
Run the command:

```text
/auth login device

```

Follow the link provided to authenticate. 3. **Enable Persistence:**
By default, Hytale deletes your login when it restarts. To fix this, run:

```text
/auth persistence Encrypted

```

**You must see the message "Credentials saved to..." before proceeding.** 4. **Detach:**
Press `Ctrl + P` then `Ctrl + Q` to leave the console running.

## Features

### Smart Updates

The server checks for updates on every restart. It creates a temporary backup of your critical files (`configs.json`, `permissions.json`, `auth.enc`), updates the game, and then restores your files.

### Crash Watchdog

If the server freezes or throws a `NullPointerException` (common in Beta), the built-in watchdog detects the error log and restarts the container automatically.

## Console Access

To run commands like `/op` or `/gamemode`:

```bash
docker attach hytale-server

```

## Disclaimer

This is a community-maintained Docker image. It is not officially affiliated with, endorsed by, or connected to Hypixel Studios. All game files are downloaded directly from official sources during the container runtime.
