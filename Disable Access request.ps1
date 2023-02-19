
#Function to disable access request SPO
Function Disable-PnPAccessRequest
{ 
    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $true, ValueFromPipeline = $True)] $Web
    )
 
    Try {
        Write-host -f Yellow "Disabling Access Request on:"$web.Url
        If($Web.HasUniqueRoleAssignments)
        {
            #Disable Access Request           
            $Web.RequestAccessEmail = [string]::Empty
            $Web.SetUseAccessRequestDefaultAndUpdate($False)
            $Web.Update()
            Invoke-PnPQuery
            Write-host -f Green "`tAccess Request has been Disabled!"$web.Url
        }
        else
        {
            Write-host -f Yellow "`tWeb inherits permissions from the parent!"$web.Url
        }
    }
    Catch {
        write-host "`tError Disabling Access Request: $($_.Exception.Message)" -foregroundcolor Red
    }
}


#Parameter
$SiteURL = "https://fudsk.sharepoint.com"
 
#Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -Interactive
 
#Call the Function for all webs
Get-PnPSubWeb -IncludeRootWeb -Recurse -Includes HasUniqueRoleAssignments | ForEach-Object { Disable-PnPAccessRequest $_ }