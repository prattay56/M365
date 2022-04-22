#Input variables
$User = Read-host "Enter UPN to be added like : mesg@hp.com"
$AdminURL = Read-Host "Enter Admin URL like :  https://hp-admin.sharepoint.com"
$Currentuser = Read-host "Enter UPN of current user : Admin@hp.com"

Connect-PNPOnline -url $AdminURL -Interactive -verbose

$SiteURLs = Get-PnPTenantSite 

#Iterate through each site
ForEach ($Site in $SiteURLs) {
    #Set current user who is running the script as site admin
    Set-PnPTenantSite -Identity $site -Owners $Currentuser -Verbose

    #Connect to SharePoint Online Site
    Connect-PnPOnline -Url $site.Url -Interactive -Verbose
 
    #Get the Associcated Owners group of the site
    $Web = Get-PnPWeb
    $Group = Get-PnPGroup -AssociatedOwnerGroup
 
    #Add user to the Group
    Add-PnPGroupMember -LoginName $User -Identity $Group
    Write-host -f Green "`tAdded $User to $($Group.Title) site: $($Web)" 

}