function Rename-SiteTeamsGroupEmail {
    param(
        [Parameter(Mandatory = $true)]
        [string]$GroupId,

        [Parameter(Mandatory = $true)]
        [string]$NewDisplayName,

        [Parameter(Mandatory = $true)]
        [string]$NewAlias,

        [Parameter(Mandatory = $true)]
        [string]$NewEmail
    )

    try {
        $grp = Get-UnifiedGroup -Identity $GroupId
        try {
            Set-UnifiedGroup -Identity $grp.Guid -DisplayName $NewDisplayName -Alias $NewAlias -EmailAddresses @{Add = $NewEmail }
            Write-Host "Group  renamed successfully!"
        }
        catch {
            Write-Host "An error occurred: $($_.Exception.Message)"
        }
       

        $url = $grp.SharePointSiteUrl
        $BaseUrl = $url.Substring(0, $url.LastIndexOf('/'))
        $NewSiteUrl = "$BaseUrl/$NewAlias"
        $RenameJob = Start-SPOSiteRename -Identity $url -NewSiteUrl $NewSiteUrl -NewSiteTitle $NewDisplayName -Confirm:$false

        do {    
            $status = Get-SPOSiteRenameState -Identity $url
            Start-Sleep -Seconds 5
        } until ($status.State -eq "Success")

        $Newgrp = Get-UnifiedGroup -Identity $GroupId 

        Write-Host "Site Teams Group Email id renamed successfully!"
    }
    catch {
        Write-Host "An error occurred: $($_.Exception.Message)"
    }
}

# Example usage:
Rename-SiteTeamsGroupEmail -GroupId "c20d82cf-9b32-40b6-9d29-03821e6e7830" -NewDisplayName "Project Management Team" -NewAlias "PMT" -NewEmail "PMT@fudsk.onmicrosoft.com"
