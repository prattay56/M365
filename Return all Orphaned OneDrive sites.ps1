
<#...
Prerequisites
#Install AAD module and SPO Module
Install-Module AzureAD  -Force
Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Force
# 
...#>

Connect-AzureAD 
Connect-SPOService 

# Get all ODB sites
$ODBSites = Get-SPOSite -Template "SPSPERS" -Limit ALL -IncludePersonalSite $True

# Get all AzureAD Accounts and create hash table for lookup
$AADUsers = Get-AzureADUser -All $True -Filter "Usertype eq 'Member'" | Select UserPrincipalName, DisplayName
$AADAccounts = @{} 
$AADUsers.ForEach( { $AADAccounts.Add([String]$_.UserPrincipalName, $_.DisplayName) } )

# Find the Orphaned sites by comparing the Site Owners to AAD
ForEach ($Site in $ODBSites) {
      If (!($AADAccounts.Item($Site.Owner))) {
            # Report
            Write-Host "Orphaned ODB sites " $Site.URL
      }
}

