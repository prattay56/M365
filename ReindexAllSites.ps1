$AdminURL = Read-Host "Enter SPO admin URL"
Connect-PnPOnline -Url $AdminURL -UseWebLogin

$urls = (Get-PnPTenantSite).url

Try {
    foreach ($url in $urls) {
        Connect-PnPOnline -Url $url -UseWebLogin -ErrorAction SilentlyContinue
        Write-Host "Connected to site succesfully " $url -f Green
        Try {

            $Web = Get-PnPWeb
            Request-PnPReIndexWeb -Web $Web -ErrorAction SilentlyContinue
            Write-Host "Re-Index initiated succesfully for site " $url -f Green
        }
        
        catch {
            Write-Host "Unable to initiate Re-Index! Error" $_.Exception.Message -f Red 
        }

        
    }
}
catch {
    Write-Host "Unable to connect to site! Error" $_.Exception.Message -f Red 
}

