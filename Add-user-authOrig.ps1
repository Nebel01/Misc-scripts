#Add group dist name
$groupName = ""

#Add user dist name
$account = ""

function AD-AddOwenerToDistGroup {


    param([Parameter(mandatory=$true)] [string[]] $UserDistName,
            [Parameter(mandatory=$true)] [string[]] $GroupDistName,
            [string] $Subgroup = $false)

            process{
foreach($group in $GroupDistName) {

#Retrieve all authOrig member for the specific group
$authOrig = Get-ADGroup -Identity $group -Properties * | Select-Object authOrig

#Check if the is not already part of the authOrig, I add it
if(($authOrig.authOrig -Contains $UserDistName) -eq $false) {
    Set-ADGroup -Identity $group -Add @{"authOrig"=$UserDistName} -Confirm:$false

    #Debug line
    #$authOrig = Get-ADGroup -Identity $groupName -Properties * | Select-Object authOrig
}

#Check for sub-groups and add it in each one
if($Subgroup -eq $true) {
    $subGroups = Get-ADGroupMember -Identity $group | where objectClass -eq "group" | Select-Object distinguishedName

    foreach($g in $subGroups) {
        $authOrigSub = Get-ADGroup -Identity $g.distinguishedName -Properties * | Select-Object authOrig
        #If the is not already part of the authOrig, I add it
        if(($authOrigSub.authOrig -Contains $UserDistName) -eq $false) {
            Set-ADGroup -Identity $g.distinguishedName -Add @{"authOrig"=$UserDistName} -Confirm:$false
        }
    }
}

#Close Foreach loop
}
#Close Process function
}
#Close function
}

AD-AddOwenerToDistGroup -UserDistName $account -GroupDistName $groupName -Subgroup $true
