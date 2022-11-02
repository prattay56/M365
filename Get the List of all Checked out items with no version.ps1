Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"  
Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"  

$siteCollectionUrl = "https://fudsk.sharepoint.com"  
$user = "aman@sobujprantar.org"
# You can save a plain text password in a text file
# $SecurePass = Get-Content "C:\String\mst.txt" | ConvertTo-SecureString -AsPlainText -Force 
$SecurePass = 'Your plain text password here' | ConvertTo-SecureString -AsPlainText -Force
$listName = "Documents" # your library name goes here

function CheckNoVersionOutdocuments($url) {
    Write-Host "Connecting to site: $url"
	
    $clientContext = New-Object  Microsoft.SharePoint.Client.ClientContext($url)
    # Credentials for online environment	
    $clientContext.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($user, $SecurePass)
	
    $credentials = $clientContext.Credentials
    $authenticationCookies = $credentials.GetAuthenticationCookie($url, $true)
    # Set the Authentication Cookies and the Accept HTTP Header
    $webSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $targetSiteUri = [System.Uri]$url
    $webSession.Cookies.SetCookies($targetSiteUri, $authenticationCookies)
    $webSession.Headers.Add("Accept", "application/json;odata=verbose")

    $List = $clientContext.Web.Lists.GetByTitle($ListName)
    $clientContext.Load($List)    
    $clientContext.ExecuteQuery()
	
    # Run on document Lib
    GetNoVersionDocuments $url $List.ID $webSession	
		
	
	
}

function GetNoVersionDocuments($url, $listID, $webSession) {
    $root = $url + '/_layouts/15/ManageCheckedOutFiles.aspx?List={' + $listID + '}'
    Write-Host $root

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