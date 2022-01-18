<#
    This script remove authOrig from the Active Directory. authOrig is used by Google Admin to assign owner permissions to groups.
#>

$Subgroup = $true
$groupName = ""
$account = ""


#Retrieve all authOrig member for the specific group
$authOrig = Get-ADGroup -Identity $groupName -Properties * | Select-Object authOrig
#Write-Host $authOrig.authOrig

#If it's not part of the authOrig, I add it
if(($authOrig.authOrig -Contains $account) -eq $true) {
    Set-ADGroup -Identity $groupName -Remove @{"authOrig"=$account} -Confirm:$false
    #$authOrig = Get-ADGroup -Identity $groupName -Properties * | Select-Object authOrig
}

#Check for sub-groups and add it in each one
if($Subgroup -eq $true) {
    $subGroups = Get-ADGroupMember -Identity $groupName | where objectClass -eq "group" | Select-Object distinguishedName

    foreach($g in $subGroups) {
        $authOrigSub = Get-ADGroup -Identity $g.distinguishedName -Properties * | Select-Object authOrig
        #If the is not already part of the authOrig, I add it
        if(($authOrigSub.authOrig -Contains $account) -eq $true) {
            Set-ADGroup -Identity $g.distinguishedName -Remove @{"authOrig"=$account} -Confirm:$false
        }
    }

}
