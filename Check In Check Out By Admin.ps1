# Check in by admin onbehalf of  all users 
# Set Variables
$ListName = "Shared Documents"
$SiteURL = "https://XXXX.sharepoint.com/sites/YYYYY"
#Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -Interactive
 
#Get All List Items from the List - Filter Files
$ListItems = Get-PnPListItem -List $ListName -PageSize 500 | Where { $_["FileLeafRef"] -like "*.*" }
 
#Loop through each list item
ForEach ($Item in $ListItems) {
    Try {
        
        # #Get the File from List Item
        $File = Get-PnPProperty -ClientObject $Item -Property File
 
        #check if the file is checked out
        If ($File.CheckOutType -ne "None") {      
            #Check-In and Approve the File
            $File.CheckIn("Checked-in By SPO Admin via Pwsh PNP !", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
            $File.Update()
            Invoke-PnPQuery -ErrorAction SilentlyContinue
            Write-host -f Green "`File Checked-In:"$File.ServerRelativeUrl
        } else {
            $status = $File.CheckOutType
            Write-host -f Yellow $File.ServerRelativeUrl": File is already Checked-in,    Status: "   $status 
        }
    }
    Catch {
        write-host -f Red "Error checking-in Document!" $_.Exception.Message
    }
}

