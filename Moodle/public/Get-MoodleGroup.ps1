<#
.SYNOPSIS
Gets a Moodle group.

.PARAMETER Id
Specifies the unique ID of the group.

.EXAMPLE
Get-MoodleGroup -Id  1

Gets a group whose ID is 1.
#>
function Get-MoodleGroup {
    [CmdletBinding(DefaultParameterSetName='id')]
    param (
        [Parameter(Mandatory, Position=0, ParameterSetName='id')]
        [int] $Id,

        [Parameter(Mandatory, ParameterSetName='course', ValueFromPipeline)]
        [MoodleCourse] $Course,

        [Parameter(Mandatory, ParameterSetName='courseid', ValueFromPipeline)]
        [int] $CourseId
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            Throw 'You must call the Connect-Moodle cmdlet before calling any other cmdlets.'
        }

        if ($PSBoundParameters.ContainsKey('id')) {
            $function = 'core_group_get_groups'
        } else {
            $function = 'core_group_get_course_groups'
        }
    }

    Process {
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"

        if ($PSBoundParameters.ContainsKey('id')) {
            $path += "&groupids[0]=$Id"

            $results = Invoke-RestMethod -Uri ([uri]::new($Url, $path)) @proxySettings
        }
        else {
            if ($Course) {
                $CourseId = $Course.Id
            }

            $path += "&courseid=$CourseId"

            $results = (Invoke-RestMethod -Uri ([uri]::new($Url, $path)) @proxySettings)
        }

        if ($results) {
            if ($results.errorcode -is [string]) {
                # invalidrecord gets thrown if the group is not found. We just want to not return anything.
                if ($results.errorcode -ne 'invalidrecord') {
                    Write-Error $results.message
                }
                return
            }

            $results | Foreach-Object {
                New-Object -TypeName MoodleGroup -Property @{
                    Id=$_.id
                    CourseId=$_.courseid
                    Name=$_.name
                    IdNumber = $_.idnumber
                    Description = $_.description
                    DescriptionFormat = $_.descriptionformat
                    EnrolmentKey = $_.enrolmentkey
                }
            }
        }
    }
}
