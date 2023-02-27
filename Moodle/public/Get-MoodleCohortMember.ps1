<#
.SYNOPSIS
Gets the user IDs of members of a Moodle cohort.

.PARAMETER Id
Specifies the unique ID of the cohort.

.PARAMETER Cohort
Specifies a Moodle cohort.

.EXAMPLE
Get-MoodleCohortMembers -Id  1

Gets member IDs of a cohort whose ID is 1.

.EXAMPLE
Get-MoodleCohort -Id 1 | Get-MoodleCohortMember

Gets member IDs of a cohort whose ID is 1.

#>
function Get-MoodleCohortMember {
    [CmdletBinding(DefaultParameterSetName='id')]
    param (
        [Parameter(ParameterSetName="id",Mandatory,Position=0)]
        [int] $Id,

        [Parameter(ParameterSetName="pipeline", ValueFromPipeline)]
        [MoodleCohort] $Cohort
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            Throw 'You must call the Connect-Moodle cmdlet before calling any other cmdlets.'
        }

        $function = 'core_cohort_get_cohort_members'
    }

    Process {
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"

        if ($Cohort) {
            $Id = $Cohort.Id
        }
        $path += "&cohortids[0]=$Id"

        (Invoke-RestMethod -Uri ([uri]::new($Url, $path)) @proxySettings).userids
    }
}
