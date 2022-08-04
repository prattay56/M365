#Config Parameters
$AdminSiteURL = "https://YOURDOMAIN-admin.sharepoint.com"
$ReportOutput = "C:\Temp\SPOStorage.csv"
 
 
#Connect to SharePoint Online Admin Center
Connect-PnPOnline -Url $AdminSiteURL  -Interactive
 
#Get all Private sites and private channel sites
$PrivateChannelSite = Get-PnPTenantSite -Template "TEAMCHANNEL#1"
$private = Get-PnPMicrosoft365Group -IncludeSiteUrl | Where-Object { $_.Visibility -eq "Private" }

#Save them in an array for later
$ResultSet = @()

        #For private sites        
        Foreach ($Site in $private) {            
            #Send the Result to CSV
            $Result = new-object PSObject
            $Result | add-member -membertype NoteProperty -name "SiteURL" -Value $Site.siteurl
            $ResultSet += $Result            
        }

        #For $Private Channel Site
        Foreach ($S in $PrivateChannelSite) {
            #Send the Result to CSV
            $Result = new-object PSObject
            $Result | add-member -membertype NoteProperty -name "SiteURL" -Value $S.url
            $ResultSet += $Result
        }

#Compiled all sites in an object
$SiteCollections = $ResultSet.SiteURL

#counter
$i = 1
#Array to store final Result
$ResultS = @()

foreach ($SiteURL in $SiteCollections) {
    #Get the Site collection Storage Metrics
    if ($null -ne $SiteURL ) {
        
        $details = Get-PnPTenantSite -Url $SiteURL 
        $i
        $i++
        Write-Host "Processing Site Collection :" $details.URL -f Yellow
        #Send the Result to CSV
        $obj = new-object PSObject
        $obj | add-member -membertype NoteProperty -name "SiteURL" -Value $details.URL
        $obj | add-member -membertype NoteProperty -name "Allocated" -Value $details.StorageQuota
        $obj | add-member -membertype NoteProperty -name "Used" -Value $details.StorageUsageCurrent
        $obj | add-member -membertype NoteProperty -name "Warning Level" -Value  $details.StorageQuotaWarningLevel
        $ResultS += $obj
 

    }
    
}

#Export Result to csv file
$ResultS |  Export-Csv $ReportOutput -notypeinformation
 
Write-Host "Site Quota Report Generated Successfully!" -f Green
