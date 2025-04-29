#!/usr/bin/env bash
set -euo pipefail
# Adds a Custom Script Extension to an existing VM
if [ $# -lt 3 ]; then
  echo "Usage: $0 <resource-group> <vm-name> <script-url>"
  exit 1
fi
az vm extension set --publisher Microsoft.Azure.Extensions             --name CustomScript --version 2.1             --resource-group "$1" --vm-name "$2"             --settings "{"fileUris": ["$3"], "commandToExecute": "bash $(basename $3)"}"
