
<#
.SYNOPSIS
    You can use this command/function block to generate a audit log 

.DESCRIPTION
    Generates audit log using this https://docs.microsoft.com/en-us/powershell/module/sharepoint-pnp/get-pnpunifiedauditlog?view=sharepoint-ps
    Required Permissions: Microsoft Office 365 Management API: ActivityFeed.Read


.NOTES
    To give consent : Login to Azure and search for "PnP Management Shell" or "PnP Office 365 Management Shell" and grant consent.
    
    Parameters available in the report
    
    CreationTime	Id	Operation	OrganizationId	OrganizationName	OriginatingServer	Parameters	ExtendedProperties	RecordType	UserKey	UserType	Version	Workload	ClientIP	ActorIpAddress	ResultStatus	ObjectId	UserId	CorrelationId	EventSource	ItemType	UserAgent	EventData	WebId	ListId	ListItemId	SiteUrl	SourceFileExtension	SourceFileName	SourceRelativeUrl

    Operation:
    FilePreviewed
    SearchQueryPerformed
    FileAccessed
    PageViewed
    SharingSet
    and Many more 

    Workload:
    OneDrive
    SharePoint
    

.LINK
    https://docs.microsoft.com/en-us/powershell/module/sharepoint-pnp/get-pnpunifiedauditlog?view=sharepoint-ps

.EXAMPLE
    Example 1
    UnifiedReport -AdmincenterURL "https://DOMAIN-admin.sharepoint.com" -Csv "C:\Temp\Report.csv"   -Workload "SharePoint" -Operation "SearchQueryPerformed"

#>

function UnifiedReport {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $true)] [String] $AdmincenterURL,
        [Parameter(Mandatory = $true)] [string] $Workload,
        [Parameter(Mandatory = $true)] [string] $Operation,
        [Parameter(Mandatory = $true)] [string] $Csv

    )
    
    try {
        
        $module = Get-Module pnp.powershell
        if ($null -eq $module) {
            Write-Host "missing pnp module"
            Install-Module -Name pnp.powershell -Force -Verbose
            Import-Module -Name pnp.powershell -Verbose
        }

        Connect-PnPOnline -Url $AdmincenterURL -Interactive -Verbose
    
        $Report = Get-PnPUnifiedAuditLog  | Where-Object { ($_.Operation -eq $operation ) -and ($_.Workload -eq $workload ) } 
        $Report | Export-Csv -Path $Csv -NoTypeInformation
        Write-Host " Report Completed  " -ForegroundColor Green  
    
    }
    catch {
        Write-Host "Error" $_.exception.message -ForegroundColor Red
    }
}




