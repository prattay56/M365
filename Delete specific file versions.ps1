#Config Variables
$SiteURL = Read-Host "Enter Site URL"
$ListName = Read-Host "Enter the Document library Name Eg: Shared Documents"
  
$Olddate = Read-Host 'Enter Older date'  
$Olddate = [DateTime]::Parse($Olddate)
$Newdate = Read-Host 'Enter Newer date'
$Newdate = [DateTime]::Parse($Newdate)
 
#Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -Interactive
# Connect-PnPOnline -Url $SiteURL -UseWebLogin
#Get All Items from the List - Exclude 'Folder' List Items
$ListItems = Get-PnPListItem -List $ListName -PageSize 2000 | Where { $_.FileSystemObjectType -eq "File" }
try {
    foreach ($ID in $ListItems.id ) {
        
        $item = Get-PnPListItem -List $ListName -Id $ID
        $File = Get-PnPProperty -ClientObject $item -Property File
        Write-host -f Yellow "Scanning File:"$File.Name
        $Versions = Get-PnPProperty -ClientObject $File -Property Versions | ? { ($_.Created -ge $olddate) -and ($_.created -le $Newdate) }  
        $Versions.count
        If ($Versions.count -gt 0) {
            for ($i = 0; $i -le $Versions.count; $i++) {
                write-host -f Cyan "`t Deleting Version:" $versions[0].VersionLabel
                $versions[0].DeleteObject()
            }
            Invoke-PnPQuery 
        }
        
    }
}
catch {
    Write-Host "Error deleting item" $_.Exception.Message -f Red 
}