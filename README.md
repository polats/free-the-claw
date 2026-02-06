# free-the-claw

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/polats/free-the-claw?quickstart=1)
[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/template/TEMPLATE_ID)

A self-hosted AI chat setup using [openclaw](https://github.com/openclaw/openclaw) with free NVIDIA NIM models via [claude-code-free](https://github.com/Alishahryar1/claude-code-free).

## Quick Start

1. Get a free NVIDIA NIM API key from https://build.nvidia.com/settings/api-keys

2. Clone the repo:
   ```
   git clone --recurse-submodules https://github.com/polats/free-the-claw.git
   cd free-the-claw
   ```

3. Copy the example env file and add your API key:
   ```
   cp .env.example .env
   ```
   Edit `.env` and set your API key and model:
   ```
   NVIDIA_NIM_API_KEY=your-key-here
   MODEL=stepfun-ai/step-3.5-flash
   ```

4. Start the services:
   ```
   docker compose up -d
   ```

5. Open http://localhost:18789/?token=changeme in your browser.

## Configuration

- **Model**: Change `MODEL` in `.env` (default: `stepfun-ai/step-3.5-flash`)

Popular choices:

- `stepfun-ai/step-3.5-flash`
- `moonshotai/kimi-k2.5`
- `z-ai/glm4.7`
- `minimaxai/minimax-m2.1`
- `mistralai/devstral-2-123b-instruct-2512`

See [`Claude Code Free`](claude-code-free/README.md) to add more models.

- **Gateway token**: Change `OPENCLAW_GATEWAY_TOKEN` in `docker-compose.yml` (default: `changeme`)

- **Ports**: claude-code-free runs on `8082`, openclaw on `18789`

## Agent Persona (optional)

Give your agent a personality by loading a [SOUL.md](https://github.com/urtimus-prime/soul.md) file at startup. Add one of the following to your `.env`:

**From a GitHub profile README** (the `username/username` repo):
```
GITHUB_SOUL_USER=voxxelle
```

**From any URL** (raw markdown file):
```
SOUL_URL=https://raw.githubusercontent.com/your-org/your-repo/main/SOUL.md
```

If both are set, `GITHUB_SOUL_USER` takes priority. The file is fetched on every container start and written to the agent's workspace as `SOUL.md`, which openclaw automatically injects into the agent's system prompt.

## Deploy with GitHub Codespaces (free)

The fastest way to try free-the-claw — no local install needed.

1. Click the **Open in GitHub Codespaces** badge above (or go to [codespaces.new/polats/free-the-claw](https://codespaces.new/polats/free-the-claw?quickstart=1))
2. When prompted, add your `NVIDIA_NIM_API_KEY` as a Codespaces secret
3. Wait for the containers to build and start
4. The gateway port (18789) auto-opens in your browser — log in with `?token=changeme`

The Codespace uses the same `docker-compose.yml` as local development with a thin overlay for workspace mounting and secrets.

## Deploy on Railway (~$5/month)

For persistent hosting, deploy on [Railway](https://railway.com) with two services from this repo.

1. Click the **Deploy on Railway** badge above, or create a new project manually
2. Add two services, both pointing to this repo:

   **claude-code-free**
   - Dockerfile path: `Dockerfile.claude-code-free.railway`
   - Port: `8082` (private networking only)
   - Add your env vars: `NVIDIA_NIM_API_KEY`, `MODEL`

   **openclaw**
   - Dockerfile path: `Dockerfile.openclaw.railway`
   - Port: `18789` (public networking)
   - Env vars: `PROXY_URL=http://claude-code-free.railway.internal:8082`, `ANTHROPIC_API_KEY=sk-placeholder`, `OPENCLAW_GATEWAY_TOKEN=<your-token>`, `MODEL`
   - Add a persistent volume mounted at `/home/node/.openclaw`

3. Enable public networking on the openclaw service
4. Open `https://<your-domain>.up.railway.app/?token=<your-token>`
