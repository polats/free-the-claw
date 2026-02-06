#!/bin/sh
set -e

CONFIG_FILE="/usr/share/nginx/html/config.json"

# On Railway, API requests are proxied through explorer's own nginx,
# so point the browser at explorer's own public domain (same origin)
if [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
  EXPLORER_PREFERRED_SEED="$RAILWAY_PUBLIC_DOMAIN"
  EXPLORER_PREFERRED_SEED_PORT=443
  EXPLORER_PREFERRED_SEED_SCHEME=https
fi

# Generate runtime config.json from environment variables
cat > "$CONFIG_FILE" <<EOF
{
  "nodes": {
    "fallbackPublicExplorer": "${EXPLORER_FALLBACK:-https://app.radicle.xyz/nodes/\$host/\$rid\$path}",
    "requiredApiVersion": "~0.18.0",
    "defaultHttpdPort": ${EXPLORER_HTTPD_PORT:-8080},
    "defaultLocalHttpdPort": ${EXPLORER_LOCAL_HTTPD_PORT:-8080},
    "defaultHttpdScheme": "${EXPLORER_HTTPD_SCHEME:-http}"
  },
  "source": {
    "commitsPerPage": 30
  },
  "supportWebsite": "https://radicle.zulipchat.com",
  "preferredSeeds": [
    {
      "hostname": "${EXPLORER_PREFERRED_SEED:-radicle-seed}",
      "port": ${EXPLORER_PREFERRED_SEED_PORT:-8080},
      "scheme": "${EXPLORER_PREFERRED_SEED_SCHEME:-http}"
    }
  ]
}
EOF

echo "Runtime config written to $CONFIG_FILE"
cat "$CONFIG_FILE"

exec "$@"
