#Make sure to connect to AAD  and SPOservice first.

Connect-AzureAD 
Connect-SPOService 

#Get all ODB sites
$ODBSites = Get-SPOSite -Template "SPSPERS" -Limit ALL -IncludePersonalSite $True

# Get all AzureAD Accounts and create hash table for lookup
$AADUsers = Get-AzureADUser -All $True -Filter "Usertype eq 'Member'" | Select UserPrincipalName, DisplayName

$AADAccounts = @{} 

$AADUsers.ForEach( {
            $AADAccounts.Add([String]$_.UserPrincipalName, $_.DisplayName) } )

# Find the Orphaned sites by comparing the Site Owners to AAD
ForEach ($Site in $ODBSites) {
      If (!($AADAccounts.Item($Site.Owner))) {
            
            #Spit the OneDrive url of the orphaned user
            Write-Host "Orphaned ODB sites " $Site.URL
      }
}