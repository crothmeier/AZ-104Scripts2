<#
Creates a VM Scale Set + CPU‑based autoscale rules.
#>
param(
    [Parameter(Mandatory=$true)] [string] $VmssName,
    [Parameter(Mandatory=$true)] [string] $Rg,
    [string] $Location = "eastus"
)

Connect-AzAccount
$null = New-AzResourceGroup -Name $Rg -Location $Location -ErrorAction SilentlyContinue

# VMSS
$vmss = New-AzVmss -ResourceGroupName $Rg -Name $VmssName -Location $Location `
         -VirtualNetworkName "${VmssName}-vnet" -SubnetName "default" `
         -PublicIpAddressName "${VmssName}-pip" -UpgradePolicyMode Automatic `
         -InstanceCount 2 -SkuCapacity 2 -SkuName "Standard_B2ms"

# Autoscale
$profile = New-AzAutoscaleProfile -Name "cpu-profile" -DefaultCapacity 2 -MaximumCapacity 6 -MinimumCapacity 2 `
           -Rule (New-AzAutoscaleRule -MetricName "Percentage CPU" -MetricResourceId $vmss.Id `
                     -Operator GreaterThan -MetricThreshold 70 -TimeGrain 00:01:00 -TimeWindow 00:05:00 -ScaleActionScaleOut 1) `
           -Rule (New-AzAutoscaleRule -MetricName "Percentage CPU" -MetricResourceId $vmss.Id `
                     -Operator LessThan -MetricThreshold 30 -TimeGrain 00:01:00 -TimeWindow 00:05:00 -ScaleActionScaleIn 1)

New-AzAutoscaleSetting -ResourceGroupName $Rg -Name "${VmssName}-autoscale" -TargetResourceUri $vmss.Id -AutoscaleProfile $profile `
    -Enabled $true
