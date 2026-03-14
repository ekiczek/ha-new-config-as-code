#!/bin/bash

FLAG_FILE="/config/.addons_installed"

# Exit if already run
if [ -f "$FLAG_FILE" ]; then
  echo "Add-ons already installed, skipping."
  exit 0
fi

# Run the actual installation in the background so shell_command doesn't time out
nohup bash /config/scripts/install_addons_worker.sh > /config/scripts/install_addons.log 2>&1 &

echo "Installation started in background. Check install_addons.log for details."
exit 0
