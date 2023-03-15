<#
.SYNOPSIS
Disconnects from the connected Moodle instance.

.DESCRIPTION
Clears cached credentials for the connected Moodle instance.
#>
function Disconnect-Moodle {
    [CmdletBinding()]
    param()

    Remove-Variable -Scope Script -Name _MoodleUrl
    Remove-Variable -Scope Script -Name _MoodleToken
    Remove-Variable -Scope Script -Name _MoodleProxySettings
}
