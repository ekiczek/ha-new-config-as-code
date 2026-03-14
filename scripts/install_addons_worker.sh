#!/bin/bash

LOG="/config/scripts/install_addons.log"
FLAG_FILE="/config/.addons_installed"
BASE_URL="http://supervisor"

echo "=== Worker started at $(date) ===" >> "$LOG"

# Check if SUPERVISOR_TOKEN is available
if [ -z "$SUPERVISOR_TOKEN" ]; then
  echo "ERROR: SUPERVISOR_TOKEN is empty or not set" >> "$LOG"
  # Try to fetch it from the supervisor env as a fallback
  SUPERVISOR_TOKEN=$(cat /proc/1/environ 2>/dev/null | tr '\0' '\n' | grep SUPERVISOR_TOKEN | cut -d= -f2)
  if [ -z "$SUPERVISOR_TOKEN" ]; then
    echo "ERROR: Could not retrieve SUPERVISOR_TOKEN from /proc/1/environ either" >> "$LOG"
    exit 1
  else
    echo "INFO: Retrieved SUPERVISOR_TOKEN from /proc/1/environ" >> "$LOG"
  fi
else
  echo "INFO: SUPERVISOR_TOKEN is set" >> "$LOG"
fi

install_addon() {
  local addon_slug="$1"
  echo "Installing addon: $addon_slug" >> "$LOG"

  local full_response
  full_response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST \
    -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
    -H "Content-Type: application/json" \
    "${BASE_URL}/addons/${addon_slug}/install")

  echo "Response: $full_response" >> "$LOG"

  local http_status
  http_status=$(echo "$full_response" | grep "HTTP_STATUS" | cut -d: -f2)

  if [ "$http_status" -eq 200 ]; then
    echo "Successfully installed: $addon_slug" >> "$LOG"
  else
    echo "Failed to install: $addon_slug (HTTP $http_status)" >> "$LOG"
    exit 1
  fi
}

install_addon "a0d7b954_vscode"

touch "$FLAG_FILE"
echo "=== All done at $(date) ===" >> "$LOG"
