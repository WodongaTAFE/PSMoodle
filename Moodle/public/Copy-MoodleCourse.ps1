<#
.SYNOPSIS
Copies the details from one Moodle course to another.

.PARAMETER Id
Specifies the unique ID of the source course.

.PARAMETER Course
Specifies the source course.

.PARAMETER DestinationId
Specifies the ID of the destination course.

.PARAMETER Clear
Specifies whether the destination course detail should be cleared before copying.

.PARAMETER IncludeActivities
Specifies whether course activities should be copied.

.PARAMETER IncludeBlocks
Specifies whether course blocks should be copied.

.PARAMETER IncludeFilters
Specifies whether course filters should be copied.

.EXAMPLE
Copy-MoodleCourse -Id 1 -DestinationId 2 -IncludeBlocks

Copies group #1's details to group #2, including course blocks.
#>
function Copy-MoodleCourse {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,ParameterSetName='id')]
        [int] $Id,

        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName='course')]
        [MoodleCourse] $Course,

        [Parameter(Mandatory)]
        [int] $DestinationId,

        [switch] $Clear,

        [switch] $IncludeActivities,

        [switch] $IncludeBlocks,

        [switch] $IncludeFilters
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            Throw "You must call the Connect-Moodle cmdlet before calling any other cmdlets."
        }

        $function = 'core_course_import_course'
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"
    }

    Process {
        if ($Course) {
            $Id = $Course.Id
        }

        $body = @{
            'importfrom' = $Id
            'importto' = $DestinationId
            'deletecontent' = if ($Clear) { 1 } else { 0 }
            'options[0][name]' = 'activities'
            'options[0][value]' = if ($IncludeActivities) { 1 } else { 0 }
            'options[1][name]' = 'blocks'
            'options[1][value]' = if ($IncludeBlocks) { 1 } else { 0 }
            'options[2][name]' = 'filters'
            'options[2][value]' = if ($IncludeFilters) { 1 } else { 0 }
        }

        if ($PSCmdlet.ShouldProcess($Id, "Copy")) {
            $result = Invoke-RestMethod -Method Post -Uri ([uri]::new($Url, $path)) -Body $body -ContentType 'application/x-www-form-urlencoded' @proxySettings
            if ($result.errorcode) {
                Write-Error $result.message
            }
        }
    }
}
