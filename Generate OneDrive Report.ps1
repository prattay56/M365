#variables
$SiteAdminUPN = Read-Host "Enter Global Admin UPN"
$TenantSiteURL = Read-Host "Enter SharePoint admin URL"
$ReportOutput = Read-Host "Enter  report path Eg: C:\Temp\OneDriveReport.csv"

Import-Module -Name pnp.powershell -Verbose

function SetSiteAdmin {
    param (
        [Parameter(Mandatory = $true)]  [string]$SiteAdmin,
        [Parameter(Mandatory = $true)]  [string]$Site
    )
    Set-PnPTenantSite -Url $Site -Owners $SiteAdmin
}

function GetSiteCreationTime {
    param (
        [Parameter(Mandatory = $true)] [string]$VarSite
    )
    Connect-PnPOnline -Url $VarSite -Interactive | Out-Null
    # Connect-PnPOnline -Url $VarSite -UseWebLogin
    $Ctx = Get-PnPContext
    #Get the Web
    $Web = $Ctx.Web
    $Ctx.Load($web)
    $Ctx.ExecuteQuery()
    $Web.created.toShortDateString()
 
}

######################################################################### PART- 1 #########################################################################

#Connect to tenant as Admin
Connect-PnPOnline -Url $TenantSiteURL -Interactive
$MySites = Get-PnPTenantSite -IncludeOneDriveSites -Filter "Url -like '-my.sharepoint.com/personal/'"

#Set secondary admin for all OneDrive sites
foreach ($i in $MySites) {
    SetSiteAdmin -SiteAdmin $SiteAdminUPN -Site $i.url
    Write-Output $i.url -Verbose
}   

######################################################################### PART- 2 #########################################################################
#Generating Report

#Array to store Result
$ResultSet = @()

#Loop through each site collection and retrieve details
Foreach ($Sites in $MySites) {

    Write-Host "Processing Site Collection :"$Sites.URL -f Yellow
    $CreatedDate = GetSiteCreationTime -VarSite $Sites.URL
    $ConsumedSize = ($Sites.StorageUsageCurrent.ToString() + "MB")/1GB
    $AllocatedSize = ($Sites.StorageQuota.ToString() + "MB")/1GB

    #Get site collection details   
    $Result = new-object PSObject
    $Result | add-member -membertype NoteProperty -name "Title" -Value $Sites.Title
    $Result | add-member -membertype NoteProperty -name "Url" -Value $Sites.Url
    $Result | add-member -membertype NoteProperty -name "Usage(GB)" -Value $ConsumedSize
    $Result | add-member -membertype NoteProperty -name "Allocated(GB)" -Value $AllocatedSize
    $Result | add-member -membertype NoteProperty -name "CreatedDate" -Value ($CreatedDate)
    $ResultSet += $Result
}

$ResultSet

#Export Result to csv file
$ResultSet |  Export-Csv $ReportOutput -notypeinformation 
Write-Host "Site Creation Date Report Generated Successfully!" -f Green