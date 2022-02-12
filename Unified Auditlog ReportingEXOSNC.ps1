
#Date function
function Read-Date {
    param(
        [String] $prompt
    )
    $result = $null
    do {
        $s = Read-Host $prompt
        if ( $s ) {
            try {
                $result = Get-Date $s
                break
            }
            catch [Management.Automation.PSInvalidCastException] {
                Write-Host "Date not valid"
            }
        }
        else {
            break
        }
    }
    while ( $true )
    $result
}

#parameter
$StartDate = Read-Date "Enter Start date Ex: 17/07/2017"
$EndDate = Read-Date "Enter End date Ex: 17/07/2017"
$Csv = Read-Host "Enter empty csv path"
    
try {
         
        
    $Session = Get-PSSession | ? { $_.Name -like "*ExchangeOnline*" }
    if ($null -eq $Session) {
            
            
        Import-Module -Name ExchangeOnlineManagement -Verbose           
        Connect-ExchangeOnline -Verbose                     
    }
    #Search Unified Log
    $SharePointLog = Search-UnifiedAuditLog -StartDate $StartDate  -EndDate $EndDate -ObjectIds $Url -Operations $Operation

    Write-Host "Found $($SharePointLog.count)"
    #Convert to Json
    $AuditLogResults = $SharePointLog.AuditData | ConvertFrom-Json | Select CreationTime, UserId, Operation, ObjectID, SiteUrl, SourceFileName, ClientIP, UserAgent, EventSource, UserType, CorrelationId
 
    #Export Audit log results to CSV
    $AuditLogResults
    $AuditLogResults | Export-csv -Path $Csv -NoTypeInformation

    
}
catch {
    Write-Host "Error" $_.exception.message -ForegroundColor Red
}
Disconnect-ExchangeOnline -Confirm:$false




