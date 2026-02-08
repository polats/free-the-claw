#!/bin/sh
# Copy config files into the named volume, replacing __MODEL__ placeholder
sed -e "s|__MODEL__|${MODEL:-moonshotai/kimi-k2-thinking}|g" \
    -e "s|__PROXY_URL__|${PROXY_URL:-http://claude-code-free:8082}|g" \
    /openclaw-config/openclaw.json \
  > /home/node/.openclaw/openclaw.json 2>/dev/null || true

# Load SOUL.md from GitHub profile README using PAT
if [ -n "$GITHUB_PAT_TOKEN" ]; then
  SOUL_DIR=/home/node/.openclaw/workspace
  GH_USER=$(curl -sfL -H "Authorization: token ${GITHUB_PAT_TOKEN}" \
    "https://api.github.com/user" 2>/dev/null \
    | sed -n 's/.*"login" *: *"\([^"]*\)".*/\1/p')
  if [ -n "$GH_USER" ]; then
    FETCH_URL="https://raw.githubusercontent.com/${GH_USER}/${GH_USER}/main/README.md"
    mkdir -p "$SOUL_DIR"
    echo "Fetching SOUL.md for @${GH_USER}..."
    if wget -q -O "$SOUL_DIR/SOUL.md" --header="Authorization: token ${GITHUB_PAT_TOKEN}" "$FETCH_URL" 2>/dev/null \
    || curl -sfL -H "Authorization: token ${GITHUB_PAT_TOKEN}" -o "$SOUL_DIR/SOUL.md" "$FETCH_URL" 2>/dev/null; then
      echo "SOUL.md loaded for @${GH_USER}"
    else
      echo "Warning: could not fetch SOUL.md from ${FETCH_URL}"
      rm -f "$SOUL_DIR/SOUL.md"
    fi
  else
    echo "Warning: could not determine GitHub username from PAT"
  fi
fi

# Configure GitHub credentials if PAT is available
if [ -n "$GITHUB_PAT_TOKEN" ]; then
  # Git credential store — authenticates git clone/push/pull to github.com
  git config --global credential.helper store
  echo "https://x-access-token:${GITHUB_PAT_TOKEN}@github.com" > /home/node/.git-credentials
  chmod 600 /home/node/.git-credentials
  chown node:node /home/node/.git-credentials
  # Standard env vars — used by gh CLI, GitHub Actions tools, and many CI integrations
  export GH_TOKEN="$GITHUB_PAT_TOKEN"
  export GITHUB_TOKEN="$GITHUB_PAT_TOKEN"
  echo "GitHub credentials configured (git + gh CLI)"
fi

chown -R node:node /home/node/.openclaw

exec "$@"
