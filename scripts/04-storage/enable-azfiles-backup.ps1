param(
    [Parameter(Mandatory=$true)][string]$StorageAccountName,
    [Parameter(Mandatory=$true)][string]$ResourceGroupName,
    [Parameter(Mandatory=$true)][string]$VaultName
)

Connect-AzAccount
Enable-AzRecoveryServicesBackupRPMissing

# Register storage account
$sa = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName
Set-AzRecoveryServicesBackupProperty -StorageAccount $sa.StorageAccountId -BackupManagementType AzureStorage -WorkloadType AzureFiles

# Protect all shares
Get-AzStorageShare -Context $sa.Context | ForEach-Object {
    Enable-AzRecoveryServicesProtection -Name $_.Name -Item $_ -VaultId (Get-AzRecoveryServicesVault -Name $VaultName).Id -Policy (Get-AzRecoveryServicesBackupProtectionPolicy -WorkloadType AzureFiles | Select -First 1)
}
