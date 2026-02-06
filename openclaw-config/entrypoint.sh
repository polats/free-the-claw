#!/bin/sh
# Copy config files into the named volume, replacing __MODEL__ placeholder
sed -e "s|__MODEL__|${MODEL:-moonshotai/kimi-k2-thinking}|g" \
    -e "s|__PROXY_URL__|${PROXY_URL:-http://claude-code-free:8082}|g" \
    /openclaw-config/openclaw.json \
  > /home/node/.openclaw/openclaw.json 2>/dev/null || true

# Load SOUL.md from GitHub profile README or direct URL
SOUL_DIR=/home/node/.openclaw/workspace
if [ -n "$GITHUB_SOUL_USER" ]; then
  FETCH_URL="https://raw.githubusercontent.com/${GITHUB_SOUL_USER}/${GITHUB_SOUL_USER}/main/README.md"
  SOUL_LABEL="@${GITHUB_SOUL_USER}"
elif [ -n "$SOUL_URL" ]; then
  FETCH_URL="$SOUL_URL"
  SOUL_LABEL="$SOUL_URL"
fi
if [ -n "$FETCH_URL" ]; then
  mkdir -p "$SOUL_DIR"
  echo "Fetching SOUL.md from ${FETCH_URL}..."
  if wget -q -O "$SOUL_DIR/SOUL.md" "$FETCH_URL" 2>/dev/null || curl -sfL -o "$SOUL_DIR/SOUL.md" "$FETCH_URL" 2>/dev/null; then
    echo "SOUL.md loaded for ${SOUL_LABEL}"
  else
    echo "Warning: could not fetch SOUL.md from ${FETCH_URL}"
    rm -f "$SOUL_DIR/SOUL.md"
  fi
fi

chown -R node:node /home/node/.openclaw

exec "$@"
