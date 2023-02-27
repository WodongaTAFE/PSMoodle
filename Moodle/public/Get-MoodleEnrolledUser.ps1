<#
.SYNOPSIS
Gets users enrolled in a course.

.PARAMETER CourseId
Specifies the unique ID of a course.

.PARAMETER Course
Specfies a Moodle course.

.EXAMPLE
Get-MoodleEnrolledUser -CourseId 1

Gets all users enrolled in course #1.

.EXAMPLE
Get-MoodleCourse 1 | Get-MoodleEnrolledUser

Gets all users enrolled in course #1.
#>
function Get-MoodleEnrolledUser {
    # [OutputType([MoodleUser])]
    [CmdletBinding(DefaultParameterSetName='id')]
    param (
        # The unique course id.
        [Parameter(ParameterSetName="id",Mandatory,Position=0)][int] $CourseId,
        # The course to return enrolled users for.
        [Parameter(ParameterSetName="pipeline", ValueFromPipeline)][MoodleCourse]$Course
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            Throw "You must call the Connect-Moodle cmdlet before calling any other cmdlets."
        }

        $function = 'core_enrol_get_enrolled_users'
    }

    Process {
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"

        if ($Course) {
            $CourseId = $Course.Id
        }
        $path = $path + "&courseid=$($CourseId)&options[0][name]=userfields&options[0][value]=id,username,firstname,lastname,email"

        $results = Invoke-RestMethod -Uri ([uri]::new($Url, $path)) @proxySettings
        $results | Foreach-Object {
            New-Object -TypeName MoodleUser -Property @{
                Id=$_.id
                UserName = $_.username
                FirstName = $_.firstname
                LastName = $_.lastname
                Email = $_.email
            }
        }
    }
}
