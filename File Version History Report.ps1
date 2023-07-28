function Get-LibraryVersionReport {
    param (
        # Parameter help description
        [Parameter(Mandatory = $true)]
        [Microsoft.SharePoint.Client.List]
        $Library,
        # Parameter help description
        [Parameter(Mandatory = $true)]
        [string]
        $CSVPath
    )

    # $Library = Get-PnPList -Identity $LibraryName
    $VersionHistoryData = @()
    #Iterate through all files
    Get-PnPListItem -List $Library -PageSize 500 | Where { $_.FieldValues.FileLeafRef -like "*.*" } | ForEach-Object {
        Write-host "Getting Versioning Data of the File:"$_.FieldValues.FileRef
        #Get FileSize & version Size
        $FileSizeinKB = [Math]::Round(($_.FieldValues.File_x0020_Size / 1KB), 2)
        $File = Get-PnPProperty -ClientObject $_ -Property File
        $Versions = Get-PnPProperty -ClientObject $File -Property Versions
        $VersionSize = $Versions | Measure-Object -Property Size -Sum | Select-Object -expand Sum
        $VersionSizeinKB = [Math]::Round(($VersionSize / 1KB), 2)
        $TotalFileSizeKB = [Math]::Round(($FileSizeinKB + $VersionSizeinKB), 2)
 
        #Extract Version History data
        $VersionHistoryData += New-Object PSObject -Property  ([Ordered]@{
                "File Name"            = $_.FieldValues.FileLeafRef
                "File URL"             = $_.FieldValues.FileRef
                "Versions"             = $Versions.Count
                "File Size (KB)"       = $FileSizeinKB
                "Version Size (KB)"    = $VersionSizeinKB
                "Total File Size (KB)" = $TotalFileSizeKB
            })
    }

    $VersionHistoryData | Export-Csv -Path $CSVPath -NoTypeInformation -Append
}

#Set Variables
$SiteURL = "https://DOMAIN.sharepoint.com/sites/XDR"
$CSVPath = "C:\Temp\VersionHistoryRpt.csv"

# connect to the desired site
Connect-PnPOnline -Url $SiteURL -useweblogin

# List only the document libraries in the site
$AllLibraries = Get-PnPList | where { $_.BaseTemplate -eq 101 -and $_.Title -notin ("Form Templates", "Site Assets", "Style Library") }

#Pull report for all the doc libs
foreach($libs in $AllLibraries) {
Write-Host "Generating report for Lib: $($libs.title)"
    Get-LibraryVersionReport -Library $libs -CSVPath  $CSVPath
}
