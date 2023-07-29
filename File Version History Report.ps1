#Parameters
$SiteURL = "https://Domain.sharepoint.com/sites/AsiaSales"
$CSVFile = "C:\Temp\VersionHistoryRpt.csv"
$X = 8   #this is the number of versions to pull( here last 8 versions)
 
#Delete the Output report file if exists
If (Test-Path $CSVFile) { Remove-Item $CSVFile }
 
#Connect to SharePoint Online site
Connect-PnPOnline -Url $SiteURL -Interactive
 
#Get All Document Libraries from the Web - Exclude Hidden and certain lists
$ExcludedLists = @("Form Templates", "Preservation Hold Library", "Site Assets", "Pages", "Site Pages", "Images",
    "Site Collection Documents", "Site Collection Images", "Style Library")
$Lists = Get-PnPList | Where-Object { $_.Hidden -eq $False -and $_.Title -notin $ExcludedLists -and $_.BaseType -eq "DocumentLibrary" }
 
#Iterate through all files from all document libraries
ForEach ($List in $Lists) {
    $global:counter = 0
    $Files = Get-PnPListItem -List $List -PageSize 2000 -Fields File_x0020_Size, FileRef -ScriptBlock { Param($items) $global:counter += $items.Count; Write-Progress -PercentComplete ($global:Counter / ($List.ItemCount) * 100) -Activity "Getting Files of '$($List.Title)'" -Status "Processing Files $global:Counter to $($List.ItemCount)"; }  | Where { $_.FileSystemObjectType -eq "File" }
     
    $VersionHistoryData = @()
    $Files | ForEach-Object {
        Write-host "Getting Versioning Data of the File:"$_.FieldValues.FileRef
        #Get File Size and version Size
        $FileSizeinKB = [Math]::Round(($_.FieldValues.File_x0020_Size / 1KB), 2)
        $File = Get-PnPProperty -ClientObject $_ -Property File
        $AllVersions = Get-PnPProperty -ClientObject $File -Property Versions 
        $Versions = $AllVersions | Sort-Object -Property Created -Descending | Select-Object -First $X
        $VersionSize = $Versions | Measure-Object -Property Size -Sum | Select-Object -expand Sum
        $VersionSizeinKB = [Math]::Round(($VersionSize / 1KB), 2)
        $TotalFileSizeKB = [Math]::Round(($FileSizeinKB + $VersionSizeinKB), 2)
  
        #Extract Version History data
        $VersionHistoryData += New-Object PSObject -Property  ([Ordered]@{
                "Library Name"         = $List.Title
                "File Name"            = $_.FieldValues.FileLeafRef
                "File URL"             = $_.FieldValues.FileRef
                "Versions"             = $Versions.Count
                "File Size (KB)"       = $FileSizeinKB
                "Version Size (KB)"    = $VersionSizeinKB
                "Total File Size (KB)" = $TotalFileSizeKB
            })
    }
    $VersionHistoryData | Export-Csv -Path $CSVFile -NoTypeInformation -Append
}
