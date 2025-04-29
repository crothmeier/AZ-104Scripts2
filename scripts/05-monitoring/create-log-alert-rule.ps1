param(
    [Parameter(Mandatory=$true)][string]$Rg,
    [Parameter(Mandatory=$true)][string]$AlertName,
    [Parameter(Mandatory=$true)][string]$WorkspaceId
)
Connect-AzAccount
$query = "AzureActivity | where OperationName == 'Delete Virtual Machine'"
New-AzScheduledQueryRule -ResourceGroupName $Rg -Location 'eastus' -Enabled $true `
  -Action (New-AzScheduledQueryRuleAznsActionGroup -ActionGroup (New-AzActionGroup -ResourceGroupName $Rg -Name "${AlertName}-ag" -ShortName "alert" -ReceiverEmailAddress "you@example.com").Id) `
  -ScheduleFrequencyInMinutes 5 -ScheduleTimeWindowInMinutes 5 -Query $query -Description "Alert on VM deletions" -Name $AlertName `
  -Location 'eastus'
