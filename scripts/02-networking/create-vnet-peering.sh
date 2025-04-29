#!/usr/bin/env bash
# Creates bidirectional VNet peering between two VNets
set -euo pipefail

while getopts s:d:g:l: flag; do
  case "${flag}" in
    s) SRC=${OPTARG};;
    d) DEST=${OPTARG};;
    g) RG=${OPTARG};;
    l) LOC=${OPTARG};;
  esac
done

if [[ -z "${SRC:-}" || -z "${DEST:-}" ]]; then
    echo "Usage: $0 -s SRC_VNET -d DEST_VNET -g RESOURCE_GROUP -l LOCATION"
    exit 1
fi

az network vnet create -n "$SRC"  -g "$RG" -l "$LOC" --address-prefix "10.0.0.0/16" --subnet-name "default" --subnet-prefix "10.0.0.0/24"
az network vnet create -n "$DEST" -g "$RG" -l "$LOC" --address-prefix "10.1.0.0/16" --subnet-name "default" --subnet-prefix "10.1.0.0/24"

az network vnet peering create -g "$RG" --name "${SRC}-to-${DEST}" --vnet-name "$SRC"  --remote-vnet "$DEST" --allow-vnet-access
az network vnet peering create -g "$RG" --name "${DEST}-to-${SRC}" --vnet-name "$DEST" --remote-vnet "$SRC" --allow-vnet-access
echo "Peering complete."
