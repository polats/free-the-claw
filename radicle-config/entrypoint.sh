#!/bin/sh
set -e

CONFIG="$RAD_HOME/config.json"

# Initialize identity if not already present
if [ ! -d "$RAD_HOME/keys" ]; then
  echo "Initializing Radicle identity..."
  RAD_PASSPHRASE="${RAD_PASSPHRASE:-}" rad auth --stdin --alias "${RAD_ALIAS:-seed}"
fi

# Patch config.json directly (no jq available in minimal image)
# Set listen address to bind all interfaces
sed -i 's/"listen": \[\]/"listen": ["0.0.0.0:8776"]/' "$CONFIG"

# Set seeding policy (default to "block" for selective seeding)
POLICY="${RAD_SEED_POLICY:-block}"
sed -i "s/\"default\": \"block\"/\"default\": \"$POLICY\"/" "$CONFIG"
sed -i "s/\"default\": \"allow\"/\"default\": \"$POLICY\"/" "$CONFIG"

# Add scope to seeding policy if requested (only for permissive mode)
if [ "$POLICY" = "allow" ] && [ "$RAD_SEED_SCOPE" = "all" ]; then
  sed -i 's/"seedingPolicy": {/"seedingPolicy": {\n      "scope": "all",/' "$CONFIG"
fi

# Set external address if provided
if [ -n "$RAD_EXTERNAL_ADDRESS" ]; then
  sed -i "s|\"externalAddresses\": \[\]|\"externalAddresses\": [\"$RAD_EXTERNAL_ADDRESS\"]|" "$CONFIG"
fi

# Print node info
echo "Node ID: $(rad self --nid)"
echo "Seeding Policy: $POLICY"
echo "Configuration applied."

# Function to apply seeding policies after node starts
apply_seeding_policies() {
  # Wait for node to be ready
  echo "Waiting for node to start..."
  sleep 5
  
  # Apply seed policies for specific repos (for selective/block mode)
  if [ -n "$RAD_SEED_REPOS" ]; then
    echo "Applying seed policies for specified repos..."
    echo "$RAD_SEED_REPOS" | tr ',' '\n' | while read -r repo; do
      repo=$(echo "$repo" | xargs)  # trim whitespace
      if [ -n "$repo" ]; then
        echo "  Seeding: $repo"
        rad seed "$repo" 2>&1 || echo "    Warning: Failed to seed $repo"
      fi
    done
  fi
  
  # Apply block policies for specific repos (for permissive/allow mode)
  if [ -n "$RAD_BLOCK_REPOS" ]; then
    echo "Applying block policies for specified repos..."
    echo "$RAD_BLOCK_REPOS" | tr ',' '\n' | while read -r repo; do
      repo=$(echo "$repo" | xargs)  # trim whitespace
      if [ -n "$repo" ]; then
        echo "  Blocking: $repo"
        rad block "$repo" 2>&1 || echo "    Warning: Failed to block $repo"
      fi
    done
  fi
  
  echo "Seeding policies applied."
}

# Start the policy application in background after node starts
if [ -n "$RAD_SEED_REPOS" ] || [ -n "$RAD_BLOCK_REPOS" ]; then
  apply_seeding_policies &
fi

exec "$@"
