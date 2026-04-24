````markdown
# Obsidian VNC Container

Run Obsidian inside a containerized XFCE desktop environment with browser access via noVNC.

This setup launches:
- XFCE desktop session
- VNC server (TigerVNC)
- noVNC web client (port 6080)
- Obsidian AppImage (downloaded at runtime)

---

## Features

- Web-based access to a full desktop environment
- Automatic download of latest Obsidian AppImage (or fallback version)
- XFCE lightweight desktop
- No local GUI required
- Runs fully in Docker

---

## Requirements

- Docker installed
- Port 6080 available

---

## Build

```bash
docker build -t obsidian-vnc .
````

---

## Run

```bash
docker run -p 6080:6080 obsidian-vnc
```

---

## Access

Open in browser:

```
http://localhost:6080
```

---

## Architecture

The container starts the following components:

1. VNC server on display `:1`
2. XFCE desktop session
3. Obsidian AppImage (downloaded at runtime)
4. noVNC websocket bridge on port `6080`

---

## Data Persistence

By default, no persistent volume is configured.

To persist Obsidian vault data, mount a volume:

```bash
docker run -p 6080:6080 \
  -v $PWD/vault:/app/vault \
  obsidian-vnc
```

You must then configure Obsidian inside the container to use `/app/vault` or what ever your vault dir should be.

---

## Notes

* This is not a native Obsidian server.
* Obsidian runs as a desktop application inside a virtual X session.
* Performance depends on container host and browser rendering.
* No multi-user synchronization is provided at container level.

---

## License

MIT
