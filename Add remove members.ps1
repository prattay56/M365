

#Connect to Exchange Online
Connect-ExchangeOnline -Credential $Cred
 
#PowerShell to Import Members to office 365 group from CSV
$csv = Import-CSV "C:\Temp\Data.csv"
$output = "C:\Temp\OutData.csv"
$Results = @()

foreach ($s in $csv) {

    if ($s.Operation -eq "A") {
        Add-UnifiedGroupLinks -Identity $s.GroupID -LinkType $s.Type -Links $s.Member
        Write-host -f Green "Added  $($s.Member) as $($s.Type) to Office 365 Group $($s.GroupID)"
        $Results += New-Object PSObject -Property ([ordered]@{
                GroupID = $s.GroupID
                Member  = $s.Member
                Status  = "$($s.Type) Added"
                Type    = $s.Type
               
            })
        
    }
    else {
        Remove-UnifiedGroupLinks -Identity $s.GroupID -LinkType Members -Links $s.Member -Confirm:$false
        Write-host -f Green "Removed $($s.Member) from Office 365 Group $($s.GroupID)"

        $Results += New-Object PSObject -Property ([ordered]@{
                GroupID = $s.GroupID
                Member  = $s.Member
                Status  = "$($s.Type) Removed"
                Type    = $s.Type
                
            })
    }
    
}
$Results | Export-Csv -Path $Output