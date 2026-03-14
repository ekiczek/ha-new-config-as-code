#!/bin/bash

LOG="/config/scripts/install_addons.log"
FLAG_FILE="/config/.addons_installed"
BASE_URL="http://supervisor"

echo "=== Worker started at $(date) ===" >> "$LOG"

if [ -z "$SUPERVISOR_TOKEN" ]; then
  SUPERVISOR_TOKEN=$(cat /proc/1/environ 2>/dev/null | tr '\0' '\n' | grep SUPERVISOR_TOKEN | cut -d= -f2)
  if [ -z "$SUPERVISOR_TOKEN" ]; then
    echo "ERROR: Could not retrieve SUPERVISOR_TOKEN" >> "$LOG"
    exit 1
  fi
fi

install_and_start_addon() {
  local addon_slug="$1"
  echo "Installing: $addon_slug" >> "$LOG"

  curl -s -X POST \
    -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
    -H "Content-Type: application/json" \
    "${BASE_URL}/addons/${addon_slug}/install" >> "$LOG"

  # Poll until install is complete
  echo "Waiting for $addon_slug to finish installing..." >> "$LOG"
  while true; do
    local state
    state=$(curl -s \
      -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
      "${BASE_URL}/addons/${addon_slug}/info" | grep -o '"state":"[^"]*"' | cut -d: -f2 | tr -d '"')

    echo "Current state: $state" >> "$LOG"

    if [ "$state" = "stopped" ] || [ "$state" = "started" ] || [ "$state" = "unknown" ]; then
      break
    fi

    sleep 5
  done

  # Start the add-on
  echo "Starting: $addon_slug" >> "$LOG"
  curl -s -X POST \
    -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
    -H "Content-Type: application/json" \
    "${BASE_URL}/addons/${addon_slug}/start" >> "$LOG"

  echo "Done with: $addon_slug" >> "$LOG"
}

install_and_start_addon "a0d7b954_vscode"

touch "$FLAG_FILE"
echo "=== All done at $(date) ===" >> "$LOG"
