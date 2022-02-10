#Remove the Labels from specific items under a Library

$site = Read-host "Enter SIte URL Eg: https://contoso.sharepoint.com/sites/ABC/123/"
Connect-PnPOnline -Url $site -interactive

$list = Get-PnPList  | ogv -PassThru

$ID = @()
do {
    $var = (Read-Host "Please enter item IDs")
    if ($var -ne '') { $ID += $var }
}
until ($var -eq '')

try {
    foreach ($i in $ID) {
        $items = Get-PnPListItem -List $list -ID $i
        
        foreach ($ID in $items) {
            $Done = Set-PnPListItem -IDentity $ID -List $list  -ClearLabel
            write-host -f green  "Removed succesfully !" $Done.ID
        }
    
    }
}
catch {
    write-host -f Red "Error removing label!" $_.Exception.Message
}




