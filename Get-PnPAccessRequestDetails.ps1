function Get-PnPAccessRequestDetails {
      
    $webs = Get-PnPSubWeb -Includes HasUniqueRoleAssignments, RequestAccessEmail, UseAccessRequestDefault , MembersCanShare, AssociatedMemberGroup.AllowMembersEditMembership, AssociatedMemberGroup -Recurse -IncludeRootWeb

    $Data = @()

    Foreach ($web in $webs ) {
        
        #Access Request details
        $HasUniqueRoleAssignments = $Web.HasUniqueRoleAssignments 
        $RequestAccessEmail = $Web.RequestAccessEmail
        $UseAccessRequestDefault = $Web.UseAccessRequestDefault
        $AllowMembersEditMembership = $Web.AssociatedMemberGroup.AllowMembersEditMembership 
        $MembersCanShare = $web.MembersCanShare


        #Send Data to object array
        $Data += New-Object psobject -Property $([Ordered]@{
                site                 = $web.Url
                UniquePermission     = $HasUniqueRoleAssignments # This is the permission inheritance status ON/OFF
                EmailAddress         = $RequestAccessEmail # These is the email id who will get the access request. 
                AccessRequestStatus  = $UseAccessRequestDefault #this is the "Allow access request Toggle ON/OFF"
                MembersCanSHareFiles = $AllowMembersEditMembership # Allow members to share the site and individual files and folders.
                MembersCanShare      = $MembersCanShare # Allow members to invite others to the site members group, alertstest Members
            })    
    }

    #Display Array Data
    $Data
}

#Parameters
$site = "https://fudsk.sharepoint.com/sites/apisite" 
$Csv = "C:\Temp\report.csv"

try {
    
    #Connect to the sharepoint site where you want to pull the report from.
    Connect-PnPOnline -url $site -Credentials $cred -Verbose

    #Function call
    Get-PnPAccessRequestDetails | Export-Csv -Path $Csv
    Write-Host "Exported succesfully!" -ForegroundColor green
}
catch {
    write-host -f Red "Exporting report!" $_.Exception.Message

}