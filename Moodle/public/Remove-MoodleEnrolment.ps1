<#
.SYNOPSIS
Unenrols a user from a course.

.PARAMETER User
Specifies a Moodle user.

.PARAMETER CourseId
Specifies the unique ID of a course.

.PARAMETER Course
Specifies a Moodle course.

.PARAMETER UserId
Specifies the unique ID of a user.

.EXAMPLE
Remove-MoodleEnrolment -UserId 1 -CourseId 1

Unenrols user #1 from course #1.

.EXAMPLE
Get-MoodleUser -UserName jbloggs | Remove-MoodleEnrolment -CourseId 1

Unenrols a user with user name 'jbloggs' from course #1.

.EXAMPLE
Get-MoodleCourse -ShortName NET101 | Remove-MoodleEnrolment -User 1

Unenrols user #1 from a course with short name 'NET101'.
#>
function Remove-MoodleEnrolment {
    [CmdletBinding(SupportsShouldProcess,DefaultParameterSetName='id')]
    param (
        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName='userpipeline')]
        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName='userpipelinewithcourse')]
        [Parameter(Mandatory,Position=0,ParameterSetName='coursepipelinewithuser')]
        [MoodleUser]
        $User,

        [Parameter(Mandatory,ParameterSetName='userpipeline')]
        [Parameter(Mandatory,ParameterSetName='id')]
        [int]
        $CourseId,

        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName='coursepipeline')]
        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName='coursepipelinewithuser')]
        [Parameter(Mandatory,Position=0,ParameterSetName='userpipelinewithcourse')]
        [MoodleCourse]
        $Course,

        [Parameter(Mandatory,ParameterSetName='coursepipeline')]
        [Parameter(Mandatory,ParameterSetName='id')]
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

        $function = 'enrol_manual_unenrol_users'
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"

        $body = @{}
        $i = 0
    }

    Process {
        if ($User) {
            $UserId = $User.Id
        }
        if ($Course) {
            $CourseId = $Course.Id
        }

        $body["enrolments[$i][userid]"] = $UserId
        $body["enrolments[$i][courseid]"] = $CourseId
        $i++
    }

    End {
        if ($Course) {
            $target = "User #$UserId"
        } else {
            $target = "Course #$CourseId"
        }

        if ($PSCmdlet.ShouldProcess($target, "Processing $i unenrolments")) {
            $result = Invoke-RestMethod -Method Post -Uri ([uri]::new($Url, $path)) -Body $body -ContentType 'application/x-www-form-urlencoded' @proxySettings
            if ($result.errorcode) {
                Write-Error $result.message
            }
        }
    }
}
