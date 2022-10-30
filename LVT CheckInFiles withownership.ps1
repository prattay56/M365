# Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"  
# Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"  

#version 3.29.2101.0
Install-Module -Name SharePointPnPPowerShellOnline -Force 

Add-Type -Path "C:\Program Files\WindowsPowerShell\Modules\SharePointPnPPowerShellOnline\3.29.2101.0\Microsoft.SharePoint.Client.Runtime.dll"  
Add-Type -Path "C:\Program Files\WindowsPowerShell\Modules\SharePointPnPPowerShellOnline\3.29.2101.0\Microsoft.SharePoint.Client.dll" 

#Variables
$tenantRootUrl = "https://.sharepoint.com" 
$siteCollectionUrl = "https://.sharepoint.com"
$user = "a "
$pass = " "


$LibraryToExclude = @("Solution Gallery", "List Template Gallery", "Converted Forms", "Theme Gallery", "Web Part Gallery", "Master Page Gallery", "Form Templates", "Site Assets", "Site Pages", "Style Library", "App Packages")

function CheckNoVersionOutdocuments($url) {
    Write-Host "Connecting to site: $url"
	
    $clientContext = New-Object  Microsoft.SharePoint.Client.ClientContext($url)
    # Credentials for on-premise environment
    #$credentials = New-Object System.Net.NetworkCredential($user, $pass)
    # Credentials for online environment
    [SecureString]$SecurePass = ConvertTo-SecureString $pass -AsPlainText -Force 	
    $clientContext.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($user, $SecurePass)
	
    $credentials = $clientContext.Credentials
    $authenticationCookies = $credentials.GetAuthenticationCookie($url, $true)
    # Set the Authentication Cookies and the Accept HTTP Header
    $webSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $targetSiteUri = [System.Uri]$url
    $webSession.Cookies.SetCookies($targetSiteUri, $authenticationCookies)
    $webSession.Headers.Add("Accept", "application/json;odata=verbose")

    $oWebsite = $clientContext.Web
    $childWebs = $oWebsite.Webs
    
    $clientContext.Load($oWebsite)
    $clientContext.Load($oWebsite.Lists)	
    $clientContext.Load($childWebs)
    $clientContext.ExecuteQuery()
	
    # Iterate all document libraries	
    foreach ($list in $oWebsite.Lists) {
        if ($list.BaseType -ne "DocumentLibrary") {
            continue
        }
        if ($LibraryToExclude -contains $list.Title) {
            write-host "execulde list" $list.Title
        }
        #if($list.Title -eq "Photos"){
        else {
            Write-Host " - Scanning document library: " $list.Title
            GetNoVersionDocuments $url $list.ID $webSession
        }				
    }	
	
    # Iterate all subsites
    foreach ($childWeb in $childWebs) {
        if ($childWeb.WebTemplate -ne "App") {
            $newpath = $tenantRootUrl + $childWeb.ServerRelativeUrl				
            CheckNoVersionOutdocuments($newpath)				
        }        	
    }
}

function GetNoVersionDocuments($url, $listID, $webSession) {
    $root = $url + '/_layouts/15/ManageCheckedOutFiles.aspx?List={' + $listID + '}'
    Write-Host $root
    #$secpasswd = ConvertTo-SecureString $pass -AsPlainText -Force
    #$credential = New-Object System.Management.Automation.PSCredential($user, $secpasswd)

    $result = Invoke-WebRequest $root -Method Get -WebSession $webSession
    $table = $result.ParsedHtml.IHTMLDocument3_getElementById("onetidTable")
    $trs = $table.getElementsByTagName('tr')
    for ($i = 1; $i -lt $trs.length; $i++) {
        $tr = $trs[$i];
        $check = $tr.GetElementsByClassName('ms-standardheader')
        if ($check.length -eq 1) {
            Write-host $tr.childNodes.item(0).outerText
        }
        else {
            if ($tr.getElementsByTagName('input').length -eq 1) {
                $Name = $tr.getElementsByTagName('input')[0].title
                $Location = $tr.cells[3].outerText
                $CheckOutUser = $tr.cells[4].outerText
                $Modified = $tr.cells[5].outerText
                $Size = $tr.cells[6].outerText
                New-Object psobject -Property @{"Name" = $Name; "Location" = $Location; "CheckOutUser" = $CheckOutUser; "Modified" = $Modified; "Size" = $Size } | Select *
            }
            else {
                $Name = $tr.getElementsByTagName('a')[0].outerText
                $Location = $tr.cells[3].outerText
                $CheckOutUser = $tr.cells[4].outerText
                $Modified = $tr.cells[5].outerText
                $Size = $tr.cells[6].outerText
                New-Object psobject -Property @{"Name" = $Name; "Location" = $Location; "CheckOutUser" = $CheckOutUser; "Modified" = $Modified; "Size" = $Size } | Select *
            }
        }        
    }
}

CheckNoVersionOutdocuments($siteCollectionUrl)