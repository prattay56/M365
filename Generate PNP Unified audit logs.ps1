# The command should be line This 
# UnifiedReport -AdmincenterURL "https://DOMAIN-admin.sharepoint.com" -Csv "C:\Temp\Report.csv"

# Generates audit log using this https://docs.microsoft.com/en-us/powershell/module/sharepoint-pnp/get-pnpunifiedauditlog?view=sharepoint-ps
# Required Permissions: Microsoft Office 365 Management API: ActivityFeed.Read
# To give consent : Login to Azure and search for "PnP Management Shell" or "PnP Office 365 Management Shell" and grant consent.
#Parameters available in the report
# CreationTime	Id	Operation	OrganizationId	OrganizationName	OriginatingServer	Parameters	ExtendedProperties	RecordType	UserKey	UserType	Version	Workload	ClientIP	ActorIpAddress	ResultStatus	ObjectId	UserId	CorrelationId	EventSource	ItemType	UserAgent	EventData	WebId	ListId	ListItemId	SiteUrl	SourceFileExtension	SourceFileName	SourceRelativeUrl

# # Variables
# $AdmincenterURL = Read-Host "Enter the Sharepoint admin center URL"
# $Csv = Read-Host -Prompt "Enter the path of the blank csv"
# $startdate = Read-Date "Enter start date"
# $Endddate = Read-Date "Enter end date"
# $url = Read-Host "Enter the url of site "
# $module = Get-Module SharePointPnPPowerShellOnline
# if ($null -eq $module) {
#     Write-Host "missing pnp module"
#     Install-Module -Name pnp.powershell -Force -Verbose
#     Import-Module -Name pnp.powershell -Verbose
# }

function UnifiedReport {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $true)] [String] $AdmincenterURL,
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
    
        $Report = Get-PnPUnifiedAuditLog  | Where-Object { ($_.Operation -eq "SearchQueryPerformed" ) -and ($_.Workload -eq "SharePoint" ) } 
        $Report | Export-Csv -Path $Csv -NoTypeInformation
        Write-Host " Report Completed  " -ForegroundColor Green  
    
    }
    catch {
        Write-Host "Error" $_.exception.message -ForegroundColor Red
    }
}




