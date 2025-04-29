#!/usr/bin/env bash
# EXAM NOTE: Private Endpoints provide a dedicated private IP address for a PaaS service inside your VNet,
# eliminating public internet exposure while maintaining full service functionality.
set -euo pipefail

usage() { 
  echo "Usage: $0 -g RG -s storageName -v vnetName -n subnetName -l location" 
  echo "Example: $0 -g myResourceGroup -s mystorageacct -v myVNet -n pe-subnet -l eastus"
  exit 1
}

while getopts g:s:v:n:l: flag; do
  case "${flag}" in
    g) RG=${OPTARG} ;;
    s) SA=${OPTARG} ;;
    v) VNET=${OPTARG} ;;
    n) SUBNET=${OPTARG} ;;
    l) LOC=${OPTARG} ;;
    *) usage ;;
  esac
done

[[ -z "${RG:-}" || -z "${SA:-}" || -z "${VNET:-}" || -z "${SUBNET:-}" || -z "${LOC:-}" ]] && usage

echo "Deploying private endpoint for $SA in $RG..."

# 1. Create Resource Group (idempotent)
echo "Ensuring resource group exists..."
az group create -n "$RG" -l "$LOC" --output none

# 2. Check if VNet exists, create if it doesn't
echo "Checking VNet..."
VNET_EXISTS=$(az network vnet show -g "$RG" -n "$VNET" --query id -o tsv 2>/dev/null || echo "")
if [ -z "$VNET_EXISTS" ]; then
  echo "Creating VNet: $VNET..."
  az network vnet create -g "$RG" -n "$VNET" --address-prefix 10.0.0.0/16 --output none
fi

# 3. Check if subnet exists, create if it doesn't
# EXAM NOTE: Subnets used for Private Endpoints MUST have 'privateLinkServiceNetworkPolicies' disabled!
echo "Checking subnet..."
SUBNET_EXISTS=$(az network vnet subnet show -g "$RG" --vnet-name "$VNET" -n "$SUBNET" --query id -o tsv 2>/dev/null || echo "")
if [ -z "$SUBNET_EXISTS" ]; then
  echo "Creating subnet: $SUBNET with private endpoint network policies disabled..."
  az network vnet subnet create         -g "$RG"         --vnet-name "$VNET"         -n "$SUBNET"         --address-prefixes 10.0.1.0/24         --disable-private-endpoint-network-policies true         --output none
else
  echo "Ensuring subnet has private endpoint network policies disabled..."
  az network vnet subnet update         -g "$RG"         --vnet-name "$VNET"         -n "$SUBNET"         --disable-private-endpoint-network-policies true         --output none
fi

# 4. Create storage account (idempotent)
echo "Ensuring storage account exists..."
az storage account create       -n "$SA"       -g "$RG"       -l "$LOC"       --sku Standard_LRS       --kind StorageV2       --https-only true       --output none

# 5. Create Private Endpoint
echo "Creating Private Endpoint..."
STORAGE_ID=$(az storage account show -n "$SA" -g "$RG" --query id -o tsv)
PE_EXISTS=$(az network private-endpoint show -g "$RG" -n "${SA}-pe" --query id -o tsv 2>/dev/null || echo "")
if [ -z "$PE_EXISTS" ]; then
  az network private-endpoint create         -g "$RG"         -n "${SA}-pe"         --vnet-name "$VNET"         --subnet "$SUBNET"         --private-connection-resource-id "$STORAGE_ID"         --group-id "blob"         --connection-name "${SA}-pe-conn"         --output none
else
  echo "Private Endpoint ${SA}-pe already exists."
fi

# 6. Private DNS Zone setup
echo "Setting up Private DNS Zone..."
DNS_ZONE="privatelink.blob.core.windows.net"
DNS_ZONE_EXISTS=$(az network private-dns zone show -g "$RG" -n "$DNS_ZONE" --query id -o tsv 2>/dev/null || echo "")
if [ -z "$DNS_ZONE_EXISTS" ]; then
  az network private-dns zone create -g "$RG" -n "$DNS_ZONE" --output none
fi

DNS_LINK_EXISTS=$(az network private-dns link vnet show -g "$RG" -n "${VNET}-link" --zone-name "$DNS_ZONE" --query id -o tsv 2>/dev/null || echo "")
if [ -z "$DNS_LINK_EXISTS" ]; then
  echo "Linking DNS Zone to VNet..."
  az network private-dns link vnet create         -g "$RG"         -n "${VNET}-link"         --zone-name "$DNS_ZONE"         --virtual-network "$VNET"         --registration-enabled false         --output none
fi

echo "Creating DNS Zone Group..."
DNS_GROUP_EXISTS=$(az network private-endpoint dns-zone-group show -g "$RG" --endpoint-name "${SA}-pe" --query id -o tsv 2>/dev/null || echo "")
if [ -z "$DNS_GROUP_EXISTS" ]; then
  az network private-endpoint dns-zone-group create         -g "$RG"         -n "default"         --endpoint-name "${SA}-pe"         --private-dns-zone "$DNS_ZONE"         --zone-name "${SA}-zone"         --output none
fi

echo -e "\nDeployment complete. Validate connectivity from a VM in the same VNet:"
echo "nslookup ${SA}.blob.core.windows.net"
echo "curl -v https://${SA}.blob.core.windows.net"
