<#
.SYNOPSIS
Unassign a Role to a Moodle user.

.DESCRIPTION
Unassign a Role to a Moodle user in a given context and/or instance.

.PARAMETER UserId
Specifies the unique ID of a user.

.PARAMETER RoleId
Specifies the unique ID of a role.

.PARAMETER ContextId
Specifies the unique ID of the context in which to unassign the role.

.PARAMETER System
Specifies that the Role should be unassigned in System context.

.PARAMETER ContextLevel
Specifies the [MoodleContext] in which to unassign the role.

.PARAMETER InstanceId
Specifies the unique ID of the instance in which to unassign the role.

.EXAMPLE
Remove-MoodleUserRole -UserId 24 -RoleId 10 -InstanceId 2 -Context CourseCat

Unassigns the Role with ID 10 from the User with ID 24 in the CourseCategory with ID 2.

.EXAMPLE
Remove-MoodleUserRole -UserId 24 -RoleId 10 -System

Unassigns the Role with ID 10 from the User with ID 24 in the System context.

.EXAMPLE
Remove-MoodleUserRole -UserId 24 -RoleId 10 -ContextId 22

Unassigns the Role with ID 10 from the User with ID 24 in the Context with ID 22.
#>
function Remove-MoodleUserRole {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The unique user id.
        [Parameter(Mandatory, Position = 0)][int] $UserId,
        [Parameter(Mandatory, Position = 1)][int] $RoleId,

        [Parameter(Mandatory, Position = 2, ParameterSetName = 'contextid')]
        [int] $ContextId,

        [Parameter(Mandatory, Position = 2, ParameterSetName = 'system')]
        [switch] $System,

        [Parameter(Mandatory, Position = 2, ParameterSetName = 'level')]
        [MoodleContext] $ContextLevel,

        [Parameter(Mandatory, Position = 3, ParameterSetName = 'level')]
        [string] $InstanceId

    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            Throw "You must call the Connect-Moodle cmdlet before calling any other cmdlets."
        }

        $function = 'core_role_unassign_roles'
    }

    Process {
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"

        $body = @{
            'unassignments[0][roleid]' = [int]$RoleId
            'unassignments[0][userid]' = [int]$UserId
        }

        $shouldProcessTargetString = "User $UserId with Role $RoleId"

        if ($PSCmdlet.ParameterSetName -eq 'contextid') {
            $body['unassignments[0][contextid]'] = [int]$ContextId
            $shouldProcessTargetString += " in Context $ContextId"
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'system') {
            $body['unassignments[0][contextlevel]'] = [MoodleContext]::System.ToString().ToLower()
            $body['unassignments[0][instanceid]'] = 10
            $shouldProcessTargetString += " in Context System"
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'level') {
            $body['unassignments[0][contextlevel]'] = $ContextLevel.ToString().ToLower()
            $body['unassignments[0][instanceid]'] = [int]$InstanceId
            $shouldProcessTargetString += " on Instance $InstanceId in ContextLevel $ContextLevel"
        }

        if ($PSCmdlet.ShouldProcess($shouldProcessTargetString, "Role Unassignment")) {
            $result = Invoke-RestMethod -Method Post -Uri ([uri]::new($Url, $path)) -Body $body -ContentType 'application/x-www-form-urlencoded' @proxySettings
            if ($result.errorcode) {
                Write-Error "$($result.message): $($result.debuginfo)"
            }
        }
    }
}
