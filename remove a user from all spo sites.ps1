Install-Module -Name PnP.PowerShell -Force

$Admincenter = Read-Host "Enter SharePoint Admin center URL, Eg: https://contoso-admin.sharepoint.com"
$orphanupn = Read-Host "Enter Orphanuser to be removed, Eg: john.doe@contoso.com" 


Connect-PNPOnline -url $Admincenter -interactive    
$SiteCollections = Get-PnPTenantSite -IncludeOneDriveSites

ForEach ($Site in $SiteCollections) {
    Try {
 
        $user = Get-PnPUser | ? { $_.Loginname -like "*$orphanupn*" }
        $user | Remove-PnPUser  -Confirm:$false
        Write-host "Deleted user $($user.Email) Successfully! form site:" $Site.URL -ForegroundColor Green
    }
 
    Catch {
        write-host -f Red "Error removing EEEU from site :" $site.URL $_.Exception.Message
    }
}
