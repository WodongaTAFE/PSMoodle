<#
.SYNOPSIS
Adds a user to a cohort.

.PARAMETER User
Specifies a Moodle user.

.PARAMETER CohortId
Specifies the unique ID of a cohort.

.PARAMETER Cohort
Specifies a Moodle cohort.

.PARAMETER UserId
Specifies the unique ID of a user.

.EXAMPLE
Add-MoodleCohortMember -UserId 1 -CohortId 1

Adds user #1 to cohort #1.

.EXAMPLE
Get-MoodleUser -UserName jbloggs | Add-MoodleCohortMember -CohortId 1

Adds a user with user name 'jbloggs' to cohort #1.

.EXAMPLE
Get-MoodleCohort -Id 1 | Add-MoodleCohortMember -User 1

Adds user #1 to cohort #1.
#>
function Add-MoodleCohortMember {
    [CmdletBinding(SupportsShouldProcess,DefaultParameterSetName='id')]
    param (
        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName='user-cohort')]
        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName='user-cohortid')]
        [MoodleUser]
        $User,

        [Parameter(Mandatory,ParameterSetName='id')]
        [Parameter(Mandatory,ParameterSetName='user-cohortid')]
        [int]
        $CohortId,

        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName='user-cohort')]
        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName='cohort-userid')]
        [MoodleCohort]
        $Cohort,

        [Parameter(Mandatory,ParameterSetName='id')]
        [Parameter(Mandatory,ParameterSetName='cohort-userid')]
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

        $function = 'core_cohort_add_cohort_members'
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"

        $body = @{}
        $i = 0
    }

    Process {
        if ($User) {
            $UserId = $User.Id
        }
        if ($Cohort) {
            $CohortId = $Cohort.Id
        }

        $body["members[$i][cohorttype][type]"] = 'id'
        $body["members[$i][cohorttype][value]"] = $CohortId
        $body["members[$i][usertype][type]"] = 'id'
        $body["members[$i][usertype][value]"] = $UserId
        $i++
    }

    End {
        if ($i -eq 0) {
            Write-Verbose 'No members to process.'
            return
        }

        if ($Cohort) {
            $target = "User #$UserId"
        } else {
            $target = "Cohort #$CohortId"
        }

        Write-Verbose $i
        if ($PSCmdlet.ShouldProcess($target, "Processing $i members")) {
            $result = Invoke-RestMethod -Method Post -Uri ([uri]::new($Url, $path)) -Body $body -ContentType 'application/x-www-form-urlencoded' @proxySettings
            if ($result.errorcode) {
                Write-Error $result.message
            }
        }
    }
}
