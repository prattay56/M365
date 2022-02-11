$Admincenter = Read-Host -Prompt "Enter SPO admin center url"
$SiteCollAdmin = Read-Host -Prompt "Enter admin UPN/email"
$CSV = Read-Host -Prompt "Enter path of csv file"
Connect-PnPOnline -Url $Admincenter -Interactive -Verbose
# $Allsites = Get-PnPTenantSite -IncludeOneDriveSites
$Allsites = Import-Csv -Path $CSV
$lib = 'PreservationHoldLibrary'
#Get All Site collections and Iterate through
ForEach ($Site in $Allsites) {
    #Add Site collection Admin
    Set-PnPTenantSite -Url $Site.Url -Owners $SiteCollAdmin
    Write-host "Added Site Collection Administrator to $($Site.URL)" -ForegroundColor Green
}
foreach ($subs in $Allsites) {
    Connect-PnPOnline -Url $subs.url -Interactive -Verbose
    $PHL = Get-PnPList -Identity  $lib 
    if ( $Null -ne $PHL ) {
        Write-Host "PHL found in site" $subs.Url "Attempting to delete PHL" -ForegroundColor Cyan
        # Remove-PnPList -Identity $PHL   -Force -Verbose
    }
    #Getting all the sub sites under current site	
    $allsubsites = Get-PnPSubWebs -Recurse
    foreach ($allsubsite in $allsubsites) {
        Write-host "Found subsites " $allsubsite.url -ForegroundColor Green
        Connect-PnPOnline -Url $allsubsite.url -Interactive -Verbose
        $PHL1 = Get-PnPList -Identity  $lib 
        if ( $Null -ne $PHL1 ) {
            Write-Host "PHL found in subsite" $allsubsite.Url "Attempting to delete PHL" -ForegroundColor Cyan
            # Remove-PnPList -Identity $PHL1   -Force -Verbose
        }
    }	
}