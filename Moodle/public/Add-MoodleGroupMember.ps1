<#
.SYNOPSIS
Adds a user to a group.

.PARAMETER User
Specifies a Moodle user.

.PARAMETER GroupId
Specifies the unique ID of a group.

.PARAMETER Group
Specifies a Moodle group.

.PARAMETER UserId
Specifies the unique ID of a user.

.EXAMPLE
Add-MoodleGroupMember -UserId 1 -GroupId 1

Adds user #1 to group #1.

.EXAMPLE
Get-MoodleUser -UserName jbloggs | Add-MoodleGroupMember -GroupId 1

Adds a user with user name 'jbloggs' to group #1.

.EXAMPLE
Get-MoodleGroup -Id 1 | Add-MoodleGroupMember -User 1

Adds user #1 to group #1.
#>
function Add-MoodleGroupMember {
    [CmdletBinding(SupportsShouldProcess,DefaultParameterSetName='id')]
    param (
        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName='user-group')]
        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName='user-groupid')]
        [MoodleUser]
        $User,

        [Parameter(Mandatory,ParameterSetName='id')]
        [Parameter(Mandatory,ParameterSetName='user-groupid')]
        [int]
        $GroupId,

        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName='user-group')]
        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName='group-userid')]
        [MoodleGroup]
        $Group,

        [Parameter(Mandatory,ParameterSetName='id')]
        [Parameter(Mandatory,ParameterSetName='group-userid')]
        [int]
        $UserId
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            Throw "You must call the Connect-Moodle cmdlet before calling any other cmdlets."
        }

        $function = 'core_group_add_group_members'
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"

        $body = @{}
        $i = 0
    }

    Process {
        if ($User) {
            $UserId = $User.Id
        }
        if ($Group) {
            $GroupId = $Group.Id
        }

        $body["members[$i][groupid]"] = $GroupId
        $body["members[$i][userid]"] = $UserId
        $i++
    }

    End {
        if ($i -eq 0) {
            Write-Verbose 'No members to process.'
            return
        }

        if ($Group) {
            $target = "User #$UserId"
        } else {
            $target = "Group #$GroupId"
        }

        if ($PSCmdlet.ShouldProcess($target, "Processing $i members")) {
            $result = Invoke-RestMethod -Method Post -Uri ([uri]::new($Url, $path)) -Body $body -ContentType 'application/x-www-form-urlencoded' @proxySettings
            if ($result.errorcode) {
                Write-Error $result.message
            }
        }
    }
}
