# Generate a brief report of user profiles from Sharepoint online user profile application
#Install the necessary Modules
Install-Module -Name MSOnline -Force
Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Force

#Import Azure AD Module
Import-Module MSOnline
 
Function Export-AllUserProfiles() {
    param
    (
        [Parameter(Mandatory = $true)] [string] $TenantURL,
        [Parameter(Mandatory = $true)] [string] $CSVPath
    )    
    Try {
        

        #Delete the CSV report file if exists
        if (Test-Path $CSVPath) { Remove-Item $CSVPath }
 
        #Get all Users
        #Connect-MsolService 
        Connect-MsolService 
        $Users = Get-MsolUser -All |  Select-Object -ExpandProperty UserPrincipalName
        
        #Connect to SPO Admin center
        Connect-PnPOnline -Url $TenantURL -Interactive -Verbose
        Write-host "Total Number of Profiles Found:"$Users.count -f Yellow
        
        
        #Array to hold result
        $UserProfileData = @()
 
        Foreach ($User in $Users) {
            Write-host "Processing User Name:"$User
            
            #Get the User Profile
            $UserProfile = Get-PnPUserProfileProperty -Account $user
            
            
            #Send Data to object array
            $UserProfileData += New-Object PSObject -Property @{
                'User Account' = $UserProfile.UserProfileProperties["UserName"]
                'Full Name'    = $UserProfile.UserProfileProperties["PreferredName"]
                'E-mail'       = $UserProfile.UserProfileProperties["WorkEmail"]
                'Department'   = $UserProfile.UserProfileProperties["Department"]
                'Location'     = $UserProfile.UserProfileProperties["Office"]
                'WorkPhone'    = $UserProfile.UserProfileProperties["WorkPhone"]
                'JobTitle'     = $UserProfile.UserProfileProperties["Title"]
                'TimeZone'     = $UserProfile.UserProfileProperties["SPS-TimeZone"]
            }
            
        }
        #Export the data to CSV
        $UserProfileData | Export-Csv $CSVPath -Append -NoTypeInformation
 
        write-host -f Green "User Profiles Data Exported Successfully to:" $CSVPath
    }
    Catch {
        write-host -f Red "Error Exporting User Profile Properties!" $_.Exception.Message
    } 
}
 
#Call the function by replacing the variables
$TenantURL = Read-Host -Prompt "Enter SPO admincenter URL like https://DOMAIN-admin.sharepoint.com"
$CSVPath =  Read-Host -Prompt "Enter path of the blank csv file like C:\Temp\UserProfiles.csv"
 
Export-AllUserProfiles -TenantURL $TenantURL -CSVPath $CSVPath