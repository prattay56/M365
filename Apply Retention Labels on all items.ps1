# Apply  Retention Labels on all items of a Document library
#Variables
$List = "Shared Documents"
$site = "https://DOMAIN.sharepoint.com/teams/HR"
$label = "PermanentRetention"

Connect-PnPOnline -Url $site -Interactive
$listitems = Get-PnPListItem -List $list -PageSize 200 | Where-Object { $_.FileSystemObjectType -eq "file" }

foreach ($item in $listitems) {
    $set = Set-PnPListItem -List $list -Identity $item.id   -Label $label
    Write-Host "Applied label on item"  $set.FieldValues['FileRef'] -ForegroundColor Green
}