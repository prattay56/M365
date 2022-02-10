$Admincenter = Read-Host -Prompt "Enter SPO admin center url"
Connect-PnPOnline -Url $Admincenter -Interactive
$Allsites = Get-PnPTenantSite -IncludeOneDriveSites
$lib = 'PreservationHoldLibrary'

foreach ($subs in $Allsites) {
	Connect-PnPOnline -Url $subs.url -Credentials $cred -Verbose
	$PHL = Get-PnPList -Identity  $lib 
	if ( $Null -ne $PHL ) {
		Write-Host "PHL found in site" $subs.Url "Attempting to delete PHL" -ForegroundColor Cyan
		Remove-PnPList -Identity $PHL   -Force -Verbose
		
	}
	#Getting all the sub sites under current site	
	$allsubsites = Get-PnPSubWebs -Recurse
	foreach ($allsubsite in $allsubsites) {
		Write-host "Found subsites " $allsubsite.url -ForegroundColor Green
		Connect-PnPOnline -Url $allsubsite.url -Credentials $cred -Verbose
		$PHL1 = Get-PnPList -Identity  $lib 
		if ( $Null -ne $PHL1 ) {
			Write-Host "PHL found in site" $allsubsite.Url "Attempting to delete PHL" -ForegroundColor Cyan
			Remove-PnPList -Identity $PHL1   -Force -Verbose
				
		}
		
	}	
}
