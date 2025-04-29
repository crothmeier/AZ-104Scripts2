<#
Deploys a baseline Conditional Access policy that requires MFA for all users outside trusted locations.
#>

Connect-MgGraph -Scopes "Policy.ReadWrite.ConditionalAccess","Directory.Read.All"

$policy = @{
    displayName = "Baseline – Require MFA"
    state       = "enabled"
    conditions  = @{
        users      = @{ include = @("all") }
        locations  = @{ include = @("all"), exclude = @("trusted") }
    }
    grantControls = @{
        operator = "OR"
        builtInControls = @("mfa")
    }
}

New-MgConditionalAccessPolicy -BodyParameter $policy
