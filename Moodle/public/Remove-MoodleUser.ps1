<#
.SYNOPSIS
Deletes a Moodle user.

.PARAMETER Id
Specifies the unique ID of the user to delete.

.PARAMETER User
Specifies the user to delete.

.EXAMPLE
Remove-MoodleUser -Id 1

Deletes user #1.
#>
function Remove-MoodleUser {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,Position=0,ParameterSetName='id',ValueFromPipelineByPropertyName)]
        [int] $Id,

        [Parameter(Mandatory,ParameterSetName='user',ValueFromPipelineByPropertyName)]
        [MoodleUser] $User
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            Throw "You must call the Connect-Moodle cmdlet before calling any other cmdlets."
        }

        $function = 'core_user_delete_users'
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"
    }

    Process {
        if ($User) {
            $Id = $User.Id
        }

        $body = @{
            'userids[0]' = $Id
        }

        if ($PSCmdlet.ShouldProcess($Id, "Delete")) {
            $result = Invoke-RestMethod -Method Post -Uri ([uri]::new($Url, $path)) -Body $body -ContentType 'application/x-www-form-urlencoded' @proxySettings
            if ($result.errorcode) {
                Write-Error $result.message
            }
        }
    }
}
