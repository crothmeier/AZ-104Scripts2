<#
.SYNOPSIS
    Elevates the current user to an Azure built‑in role using Privileged Identity Management (PIM).

.PARAMETER RoleName
    The role (e.g. 'User Access Administrator') to activate.

.PARAMETER SubscriptionId
    Subscription scope for activation.

.EXAMPLE
    ./enable-pim.ps1 -RoleName 'User Access Administrator' -SubscriptionId '00000000-0000-0000-0000-000000000000'
#>

param(
    [Parameter(Mandatory=$true)][string]$RoleName,
    [Parameter(Mandatory=$true)][string]$SubscriptionId
)

Write-Host "Connecting to Azure…"
Connect-AzAccount -ErrorAction Stop
Select-AzSubscription -SubscriptionId $SubscriptionId

$role = Get-AzRoleDefinition -Name $RoleName
if (-not $role) { throw "Role not found." }

# Activate via PIM
Write-Host "Requesting PIM activation for role '$RoleName'…" -ForegroundColor Cyan
$params = @{
    ResourceId       = "/subscriptions/$SubscriptionId"
    RoleDefinitionId = $role.Id
    DurationInHours  = 4
    Reason           = "Exam‑style elevation"
}
New-AzRoleAssignment -ObjectId (Get-AzADUser -SignedIn).Id @params
Write-Host "Done."
