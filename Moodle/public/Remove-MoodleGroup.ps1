<#
.SYNOPSIS
Deletes a Moodle group.

.PARAMETER Id
Specifies the unique ID of the group to delete.

.PARAMETER Group
Specifies the group to delete.

.EXAMPLE
Remove-MoodleGroup -Id 1

Deletes group #1.
#>
function Remove-MoodleGroup {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,Position=0,ParameterSetName='id',ValueFromPipelineByPropertyName)]
        [int] $Id,

        [Parameter(Mandatory,ParameterSetName='group',ValueFromPipelineByPropertyName)]
        [MoodleGroup] $Group
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            Throw "You must call the Connect-Moodle cmdlet before calling any other cmdlets."
        }

        $function = 'core_group_delete_groups'
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"
    }

    Process {
        if ($Group) {
            $Id = $Group.Id
        }

        $body = @{
            'groupids[0]' = $Id
        }

        if ($PSCmdlet.ShouldProcess($Id, "Delete")) {
            $result = Invoke-RestMethod -Method Post -Uri ([uri]::new($Url, $path)) -Body $body -ContentType 'application/x-www-form-urlencoded' @proxySettings
            if ($result.errorcode) {
                Write-Error $result.message
            }
        }
    }
}
