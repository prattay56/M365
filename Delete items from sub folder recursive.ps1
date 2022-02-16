
#Parameters
$SiteURL = Read-Host "Enter the site url"
$Folder = Read-Host "Enter Folder path Eg: /Shared Documents/abc/123"
 
#Connect to the Site
Connect-PnPOnline -URL $SiteURL -Interactive
 
#Get the web & document Library Folder
$Web = Get-PnPWeb
$SFolder = Get-PnPFolder  -Url $Folder
 
#Function to delete all items in a folder - and sub-folders recursively
Function Delete-AllFilesFromFolder($Folder) {
    #Get the site relative path of the Folder
    If ($Folder.Context.web.ServerRelativeURL -eq "/") {
        $FolderSiteRelativeURL = $Folder.ServerRelativeUrl
    }
    Else {       
        $FolderSiteRelativeURL = $Folder.ServerRelativeUrl.Replace($Folder.Context.web.ServerRelativeURL, [string]::Empty)
    }
 
    #Get All files in the folder
    $Files = Get-PnPFolderItem -FolderSiteRelativeUrl $FolderSiteRelativeURL -ItemType File
     
    #Delete all files
    ForEach ($File in $Files) {
        Write-Host ("Deleting File: '{0}' at '{1}'" -f $File.Name, $File.ServerRelativeURL) -f green
         
        #Delete Item
        Remove-PnPFile -ServerRelativeUrl $File.ServerRelativeURL -Force -Recycle
    }
 
    #Process all Sub-Folders
    $SubFolders = Get-PnPFolderItem -FolderSiteRelativeUrl $FolderSiteRelativeURL -ItemType Folder
    Foreach ($Folder in $SubFolders) {
        #Exclude "Forms" and Hidden folders
        If ( ($Folder.Name -ne "Forms") -and (-Not($Folder.Name.StartsWith("_")))) {
            #Call the function recursively
            Delete-AllFilesFromFolder -Folder $Folder
        }
    }
}
#Get the Root Folder of the Document Library and call the function
Delete-AllFilesFromFolder -Folder $SFolder
