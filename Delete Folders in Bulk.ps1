# Delete Specific set of folders or files from SharePoint site
$Folder = Import-Csv "C:\Users\amand\Downloads\Folders.csv"
$SiteURL = Import-Csv "C:\Users\amand\Downloads\SiteURL.csv"

# We are considering a common root folder in this use case. 
$ListName = "Documents"

#Connect to Sites recursively to and get the Library url
try {
    foreach ($a in $SiteURL.url) {
        Connect-PnPOnline -Url $a -Interactive -verbose
        
        write-host $("Start time " + (Get-Date)) 
        
        #site and list details
        $siteID = (Get-PnPSite -Includes Id).Id
        $listID = (Get-PnPList $listName).Id
        $web = (get-pnpweb).ServerRelativeUrl

        # Creating a batch job for bulk deletion
        $batchSize = 20
        #bearer token for batch request
        $token = Get-PnPGraphAccessToken

        #Get all the list items
        $ListItems = Get-PnPListItem -List $ListName -PageSize 2000
        Write-host "Total Number of Items Found:"$ListItems.count "in Site:"  $a 
        
        #Delete all files from a folder in batch permanently
        foreach ($i in $Folder.Folder) { 
            #Construct the Serverrelative URL     
            $FolderServerRelativeURL = $web + "/" + $ListName + "/" + $i
            #Get All Items from the csv Folders by filtering
            $ItemsFromFolder = $ListItems | Where-Object { $_.FieldValues["FileDirRef"] -match $FolderServerRelativeURL }
			
            $requests = @()
            $itemCount = $ItemsFromFolder.Count
			
            #Delete all files from a folder in batch permanently using Graph 
				
            for ($i = $itemCount - 1; $i -ge 0; $i--) {
                $itemId = $ItemsFromFolder[$i].Id 
                $request = @{
                    id      = $i
                    method  = "DELETE"
                    url     = "/sites/$siteID/lists/$listID/items/$itemId"
                    headers = $header
                }          
                $requests += $request 
                if ($requests.count -eq $batchSize -or $requests.count -eq $itemCount) { 
                    $batchRequests = @{
                        requests = $requests
                    }
         
                    #IMPORTANT: use -Deph parameter
                    $batchBody = $batchRequests | ConvertTo-Json -Depth 4
                    #send batch request
                    $response = Invoke-WebRequest -Method Post -Uri 'https://graph.microsoft.com/v1.0/$batch' -Headers @{Authorization = "Bearer $($token)" } -ContentType "application/json" -Body $batchBody
                    $StatusCode = $Response.StatusCode
       
                    write-host $("$StatusCode response for deleting 20")
                    #reset batch item counter and requests array
                    $requests = @()
                    $itemCount = $itemCount - $batchSize
                }
            }
        

        
        }
    }
}
catch {
    write-host -f Red "Error" $_.Exception.Message
}