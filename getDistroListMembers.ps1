### Variables ###
$myDate = Get-Date -UFormat "%Y%m%d-%H%M%S" # Date format for output file name
$OutputFh = "GroupListing_$($myDate).json" # Output File Path
$outputFields = 'primarySmtpAddress','DisplayName','GroupType','Members' # Fields to Include in Output
$groupList = @()


### Main ###
# Connect to exchange online
Write-Host "Creating Session with Exchange Online"
$UserCredential = Get-Credential
$sessionParams = @{
    'ConfigurationName' = 'Microsoft.Exchange';
    'ConnectionUri' = "https://outlook.office365.com/powershell-liveid/";
    'Credential' = $UserCredential;
    'Authentication' = 'Basic';
    'AllowRedirection' = $true
}
$Session = New-PSSession @sessionParams
Import-PSSession $Session


Write-Host "Retrieving Exchange Groups"
$distributionGroups = Get-DistributionGroup

foreach ( $group in $distributionGroups ) {
    $Script:memberCollection = {}.Invoke()
    Add-Member -InputObject $group -NotePropertyName Members -NotePropertyValue ""

    $myMembers = Get-DistributionGroupMember -Identity $group.primarySmtpAddress
    foreach ( $member in $myMembers ) {
        $memberCollection.Add(@{"DisplayName"=$member.Id;"Email"=$member.primarySmtpAddress})
    }
    $group.Members = $memberCollection
}

$groupList += $distributionGroups


Write-Host "Retrieving Office365 Groups"
$o365Groups = Get-UnifiedGroup

foreach ( $group in $o365Groups ) {
    $Script:memberCollection = {}.Invoke()
    Add-Member -InputObject $group -NotePropertyName Members -NotePropertyValue ""

    $myMembers = Get-UnifiedGroupLinks -Identity $group.primarySmtpAddress -LinkType Members
    foreach ( $member in $myMembers ) {
        $memberCollection.Add(@{"DisplayName"=$member.Id;"Email"=$member.primarySmtpAddress})
    }
    $group.Members = $memberCollection
    $group.GroupType = "O365 Group"
}

$groupList += $o365Groups


Write-Host "Writing JSON output to file..."
$groupList | Select $outputFields | ConvertTo-Json -Depth 5 > $outputFh


Write-Host "Closing Session with Exchange Online. Goodbye!"
Remove-PSSession $Session