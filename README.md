# AZ-104 Advanced Scripts

**Purpose**  
This repository contains reference automation artifacts that cover the *advanced* skill areas of the **AZ‑104: Microsoft Azure Administrator** exam.  
They are intentionally opinionated, idempotent, and focus on tasks you are expected to perform *in production* rather than “hello‑world” demos.

## Prerequisites
* Azure CLI ≥ 2.59 or Az PowerShell ≥ 11
* Logged‑in user with **Owner** or delegated **Contributor + User Access Administrator** rights
* A default Log Analytics workspace in the target subscription
* For Bicep modules: Bicep CLI ≥ 0.26 (bundled with latest az CLI)

## Repository Layout
```
.
├── scripts
│   ├── 01-identity
│   │   ├── enable-pim.ps1
│   │   └── conditional-access-policy.ps1
│   ├── 02-networking
│   │   ├── create-vnet-peering.sh
│   │   └── deploy-app-gateway-waf.bicep
│   ├── 03-compute
│   │   ├── vmss-autoscale.ps1
│   │   └── add-custom-script-extension.sh
│   ├── 04-storage
│   │   ├── storage-lifecycle-policy.json
│   │   └── enable-azfiles-backup.ps1
│   └── 05-monitoring
│       ├── enable-diagnostics.sh
│       └── create-log-alert-rule.ps1
├── modules
│   ├── vnet.bicep
│   └── vmss.bicep
└── pipelines
    └── github-actions-ci.yml
```

## Quick‑start

```bash
# Deploy a hub‑spoke VNet peering
cd scripts/02-networking
chmod +x create-vnet-peering.sh
./create-vnet-peering.sh -s HUB -d SPOKE -g NetRG -l eastus

# Validate all Bicep modules
az bicep build --file ../../modules/vnet.bicep
```

## License
MIT
