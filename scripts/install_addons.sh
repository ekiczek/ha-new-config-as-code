#!/bin/bash

FLAG_FILE="/config/.addons_installed"

# Exit if already run
if [ -f "$FLAG_FILE" ]; then
  echo "Add-ons already installed, skipping."
  exit 0
fi

SUPERVISOR_TOKEN="${SUPERVISOR_TOKEN}"
BASE_URL="http://supervisor"

install_addon() {
  local addon_slug="$1"
  echo "Installing addon: $addon_slug"

  local response
  response=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
    -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
    -H "Content-Type: application/json" \
    "${BASE_URL}/addons/${addon_slug}/install")

  if [ "$response" -eq 200 ]; then
    echo "Successfully installed: $addon_slug"
  else
    echo "Failed to install: $addon_slug (HTTP $response)"
    exit 1
  fi
}

install_addon "a0d7b954_vscode"

# Write flag file so this doesn't run again
touch "$FLAG_FILE"
echo "All add-ons installed successfully."
