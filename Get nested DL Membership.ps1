function Get-MailboxUsersInDistributionGroup {
    param (
        [string]$DistributionList,
        [string]$CsvPath
    )

    # Function to recursively get users from nested distribution groups
    function Get-UsersFromNestedDLs {
        param (
            [string]$DLName
        )

        # Get members of the distribution group
        $members = Get-DistributionGroupMember -Identity $DLName
        
        # Initialize an empty array to store user objects
        $nestedUserObjects = @()

        # Loop through each member
        foreach ($member in $members) {
            # If the member is a distribution group, recursively get users from it
            if ($member.RecipientType -eq "MailUniversalDistributionGroup") {
                $nestedUsers = Get-UsersFromNestedDLs -DLName $member.PrimarySmtpAddress
                $nestedUserObjects += $nestedUsers
            }
            # If the member is a user mailbox, add it to the array
            elseif ($member.RecipientType -eq "UserMailbox") {
                $nestedUserObjects += [PSCustomObject]@{
                    Name          = $member.Name
                    Email         = $member.PrimarySmtpAddress
                    RecipientType = $member.RecipientType
                    WindowsLiveID = $member.WindowsLiveID
                }
            }
        }

        return $nestedUserObjects
    }

    # Get users from the specified distribution list and its nested distribution lists
    $allUsers = Get-UsersFromNestedDLs -DLName $DistributionList

    # Export the user information to a CSV file
    $allUsers | Sort-Object -Unique -Property Email | Export-Csv -Path $CsvPath -NoTypeInformation -Append
}

# Example usage:
$Alldls = @("ADL","BDL","CDL") 
foreach ($d in $Alldls) {
    Get-MailboxUsersInDistributionGroup -DistributionList $d -CsvPath "C:\Temp\AllMailboxUsers.csv"
}
