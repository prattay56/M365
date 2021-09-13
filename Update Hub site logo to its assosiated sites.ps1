$tenantAdmin = Read-Host "Enter SPO admin URL "
$hubSiteurl = Read-Host "Enter HUb Site URL " 

# Browse the Logo pnp file you have downloaded from the Source Hub site.
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop') 

}
$null = $FileBrowser.ShowDialog()


$imgPath = $FileBrowser.FileName
Connect-PnPOnline -Url $tenantAdmin -UseWebLogin
$HubSite = Get-PnPHubSite $hubSiteurl
$HubSiteId = $HubSite.SiteId
$ModernSites = (Get-PnPTenantSite -Template 'GROUP#0') + (Get-PnPTenantSite -Template 'SITEPAGEPUBLISHING#0') 
$SitesFromHub = New-Object System.Collections.ArrayList
Write-Host ("Searching {0} sites:" -f $HubSite.Title) -BackgroundColor Gray
foreach ($ModernSite in $ModernSites) {
    $site = Get-PnPHubSite $ModernSite.Url
    if ($site.SiteUrl) {			
        if ($site.SiteId -eq $HubSiteId) {
            Write-Host ("* {0} - {1}" -f $ModernSite.Title, $ModernSite.Url)
            $SitesFromHub.Add($ModernSite) | Out-Null
        }
    }
}
Write-Host ""
Write-Host "Upload Logo at:" -BackgroundColor Gray
foreach ($SiteHub in $SitesFromHub) {
    Write-Host ("* {0} - {1} ... " -f $SiteHub.Title, $SiteHub.Url) -NoNewline	
    Connect-PnPOnline -Url $SiteHub.Url -UseWebLogin
    try {
        New-PnPList -Title "Site Assets" -Template DocumentLibrary  -Url "SiteAssets" -ErrorAction SilentlyContinue
        Add-PnPFile -Path $imgPath -Folder SiteAssets -ErrorAction Stop
        $imgName = $imgPath | Split-Path -Leaf
        $pathImg = (Get-PnPListItem -List SiteAssets -Fields FileRef).FieldValues | Where-Object { $_.FileRef -match $imgName }  
        Set-PnPWeb -SiteLogoUrl $pathImg.FileRef		
        Write-Host "Done" -BackgroundColor Green
    }
    catch {
        Write-Host $_.ToString() -BackgroundColor Red
    }
}
Write-Host "All Done"