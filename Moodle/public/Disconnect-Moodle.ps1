<#
.SYNOPSIS
Disconnects from the connected Moodle instance.

.DESCRIPTION
Clears cached credentials for the connected Moodle instance.
#>
function Disconnect-Moodle {
    [CmdletBinding()]
    param()

    $PsCmdlet.SessionState.PSVariable.Remove('_MoodleUrl')
    $PsCmdlet.SessionState.PSVariable.Remove('_MoodleToken')
}
