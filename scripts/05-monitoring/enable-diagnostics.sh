#!/usr/bin/env bash
# Enables Diagnostic Settings to send metrics & logs to Log Analytics
set -euo pipefail
if [ $# -lt 3 ]; then
  echo "Usage: $0 <resource-id> <workspace-id> <setting-name>"
  exit 1
fi
az monitor diagnostic-settings create --resource "$1" --workspace "$2"            --name "$3" --logs '[{"category":"AllLogs","enabled":true}]'            --metrics '[{"category":"AllMetrics","enabled":true,"retentionPolicy":{"days":0,"enabled":false}}]'
