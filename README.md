# free-the-claw

A self-hosted AI chat setup using [openclaw](https://github.com/openclaw/openclaw) with free NVIDIA NIM models via [claude-code-free](https://github.com/Alishahryar1/claude-code-free).

## Before You Begin

Get a free NVIDIA NIM API key from https://build.nvidia.com/settings/api-keys

## Quick Start with Codespaces

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/polats/free-the-claw?quickstart=1)


The fastest way to try free-the-claw — no local install needed.

1. Click the `Open in GitHub Codespaces badge` above
2. When prompted, add your `NVIDIA_NIM_API_KEY` as a Codespaces secret
3. Wait for the containers to build and start
4. The gateway port (18789) auto-opens in your browser — log in with `?token=changeme`

Codespaces is ephemeral and will reset after a while. To persist your data, follow the [Deploy on Railway](#deploy-on-railway) section instead.

## Running Locally Via Docker

1. Clone the repo:
   ```
   git clone --recurse-submodules https://github.com/polats/free-the-claw.git
   cd free-the-claw
   ```

2. Copy the example env file and add your API key:
   ```
   cp .env.example .env
   ```
   Edit `.env` and set your API key and model:
   ```
   NVIDIA_NIM_API_KEY=your-key-here
   MODEL=stepfun-ai/step-3.5-flash
   ```

3. Start the services:
   ```
   docker compose up -d
   ```

4. Open http://localhost:18789/?token=changeme in your browser.

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

## Deploy on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/free-the-claw)

For persistent hosting, deploy on [Railway](https://railway.com) with two services from this repo. You will probably need the Hobby Plan ($5/month) as the free tier may not have enough memory for openclaw.

1. Click the **Deploy on Railway** badge above
2. Add your NVIDIA NIM API key from https://build.nvidia.com/settings/api-keys in the openclaw service's variables
3. Once deployed, you should see the gateway URL on the service (similar to `https://openclaw-railway-1234567890.up.railway.app`) 
4. Visit the URL via the browser appended with `?token=changeme` (you can change this OPENCLAW_GATEWAY_TOKEN in the openclaw service's environment variables)

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
