<#
.SYNOPSIS
Deletes a Moodle cohort.

.PARAMETER Id
Specifies the unique ID of the cohort to delete.

.PARAMETER Cohort
Specifies the cohort to delete.

.EXAMPLE
Remove-MoodleCohort -Id 1

Deletes cohort #1.
#>
function Remove-MoodleCohort {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,Position=0,ParameterSetName='id',ValueFromPipelineByPropertyName)]
        [string] $Id,

        [Parameter(Mandatory,ParameterSetName='cohort',ValueFromPipelineByPropertyName)]
        [MoodleCohort] $Cohort
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            Throw "You must call the Connect-Moodle cmdlet before calling any other cmdlets."
        }

        $function = 'core_cohort_delete_cohorts'
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"
    }

    Process {
        if ($Cohort) {
            $Id = $Cohort.Id
        }

        $body = @{
            'cohortids[0]' = $Id
        }

        if ($PSCmdlet.ShouldProcess($Id, "Delete")) {
            $result = Invoke-RestMethod -Method Post -Uri ([uri]::new($Url, $path)) -Body $body -ContentType 'application/x-www-form-urlencoded' @proxySettings
            if ($result.errorcode) {
                Write-Error $result.message
            }
        }
    }
}
