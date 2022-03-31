#To remove labels from all items in a LVT library
#Variables
$List = "Shared Documents"
$site = "https://Domain.sharepoint.com/teams/HR"

Connect-PnPOnline -Url $site -Interactive
$listitems = Get-PnPListItem -List $list -PageSize 200 | Where-Object { $_.FileSystemObjectType -eq "file" }
foreach ($item in $listitems) {
    $set = Set-PnPListItem -List $list  -Identity $item.id  -ClearLabel
    Write-Host "Removed label from item:  "  $set.FieldValues['FileRef'] -ForegroundColor red
}