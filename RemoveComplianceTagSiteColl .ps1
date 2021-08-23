$Site = Read-Host "Enter the site URL"
Connect-PnPOnline -Url $Site -UseWebLogin

$listcol = Get-PnPList
foreach ($list in $listcol) {
    $items = Get-PnPListItem -List $list.Title
    Write-Host "Fixing list " $list.Title, $list.Id, $items.Count
 
    
    try {
        foreach ($item in $items) {
 
            $item.SetComplianceTag("", $false, $false, $false, $false)
            $item.Update()
            Write-Host "Succefully removed tag from item:" $item.ID -f Green
        }
        Invoke-PnPQuery 
    }
    catch {
        Write-Host "Unable to remove tag from item:" $item.ID -f Red
    }
}