$CSVFilePath = "C:\Temp\SiteAdmins.csv" 
$clst = "Client secret"
$clid = "Client id"

#Get all Site collections
$Sites = Import-Csv "C:\Users\amand\Downloads\Onedrive.csv"


$i = $Sites.count

foreach ($Site in $Sites) {
    Write-Host "$i  | Processing site:" $Site.Url -ForegroundColor Yellow

    Connect-PnPOnline -Url $Site.URL -ClientSecret $clst -ClientId $clid -WarningAction SilentlyContinue
    
    #Get all Site Collection Administrators
    $SiteAdmins = Get-PnPSiteCollectionAdmin

    foreach ($Admin in $SiteAdmins) {
        # Write-host "Site collection admin:" $Admin.LoginName
        #Create an object to store Site Admin information
        $SiteAdminObject = New-Object PSObject -Property @{
            "SiteURL"      = $Site.Url
            "AdminEmail"   = $Admin.Email
            "SiteOwnerUPN" = $Site.Owner
            "AdminUPN"     = $Admin.LoginName
        } 

        #Append the info to csv
        $SiteAdminObject | Export-Csv -Path $CSVFilePath -NoTypeInformation -Encoding UTF8 -Append              
        
    }
    $i--
}