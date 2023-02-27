<#
.SYNOPSIS
Gets the user IDs of members of a Moodle group.

.PARAMETER Id
Specifies the unique ID of the group.

.PARAMETER Group
Specifies a Moodle group.

.EXAMPLE
Get-MoodleGroupMembers -Id  1

Gets member IDs of a group whose ID is 1.

.EXAMPLE
Get-MoodleGroup -Id 1 | Get-MoodleGroupMember

Gets member IDs of a group whose ID is 1.

#>
function Get-MoodleGroupMember {
    [CmdletBinding(DefaultParameterSetName='id')]
    param (
        [Parameter(ParameterSetName="id",Mandatory,Position=0)]
        [Alias('GroupId')]
        [int] $Id,

        [Parameter(ParameterSetName="pipeline", ValueFromPipeline)]
        [MoodleGroup] $Group
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            Throw 'You must call the Connect-Moodle cmdlet before calling any other cmdlets.'
        }

        $function = 'core_group_get_group_members'
    }

    Process {
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"

        if ($Group) {
            $Id = $Group.Id
        }
        $path += "&groupids[0]=$Id"

        (Invoke-RestMethod -Uri ([uri]::new($Url, $path)) @proxySettings).userids
    }
}
