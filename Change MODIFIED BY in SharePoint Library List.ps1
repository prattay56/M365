$SiteURL = Read-Host  " Enter site url like https://domain.sharepoint.com/sites/ABC"
$author = Read-Host  " Enter desired author Email ID/UPN"

#Connect to SharePoint Online site
Connect-PnPOnline -Url $SiteURL -Interactive 
# Select the list/lib from the powershell prompt
$ListName = Get-PnPList | ogv -PassThru

#Get All Folders and nested from the document Library
$Folders = Get-PnPFolder -List $ListName | Select Name, TimeCreated, ItemCount, ServerRelativeUrl
Write-host "Total Number of Items in the Folder in the list:" $Folders.Count

foreach ($item in $Folders) {

    try {
        $Folder = Get-PnPFolder -Url $item.ServerRelativeUrl -Includes ListItemAllFields
        #Update Folder's Created By and Modified By Values
        Set-PnPListItem -List $ListName -Identity $Folder.ListItemAllFields.Id -Values @{"Author" = $author; "Editor" = $author } | Out-Null 
        Write-Host "Succesfully updated item" $item.name -ForegroundColor green
    }
    catch {
        Write-Host "Failed to updated item" $_.Exception.Message  $item.name -ForegroundColor red
    }
    
}


