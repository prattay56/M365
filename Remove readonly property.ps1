#Function to remove readonly
function RemoveReadonly($Path) {
    $Files = Get-ChildItem $Path -Recurse
    ForEach ($File in $Files) {
        Write-Host file:$File IsReadOnly: $File.IsReadOnly -ForegroundColor Yellow
        if ($File.Attributes -ne "Directory" -and $File.IsReadOnly -eq $true) {
            try {
                Set-ItemProperty -Path $File.Fullname -name IsReadOnly -value $false
                Write-Host "Removed ReadOnly from file $($File.Fullname) " -f Green
            }
            catch { 
                Write-Host "Error at file $($File.Fullname)" -f Yellow
            }
        } 
    }
}

#Csv to parse
$Report = Read-Host "Enter the path of the file"
# Function call to run against all Locations in the csv
$Csv = Import-Csv -Path $Report
foreach($i in $Csv) {
    RemoveReadonly -Path $i.Location
}