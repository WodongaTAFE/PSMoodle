<#
.SYNOPSIS
Enrols a user in a course.

.PARAMETER User
Specifies a Moodle user.

.PARAMETER CourseId
Specifies the unique ID of a course.

.PARAMETER Course
Specifies a Moodle course.

.PARAMETER UserId
Specifies the unique ID of a user.

.PARAMETER Role
Specifies the role the user will take in the course. Defaults to student.

.EXAMPLE
New-MoodleEnrolment -UserId 1 -CourseId 1 -Role Student

Enrols user #1 as a student in course #1.

.EXAMPLE
Get-MoodleUser -UserName jbloggs | New-MoodleEnrolment -CourseId 1

Enrols a user with user name 'jbloggs' in course #1.

.EXAMPLE
Get-MoodleCourse -ShortName NET101 | New-MoodleEnrolment -User 1 -Role Teacher

Enrols user #1 as a teacher in a course with short name 'NET101'.
#>
function New-MoodleEnrolment {
    [CmdletBinding(SupportsShouldProcess,DefaultParameterSetName='id')]
    param (
        [Parameter(Mandatory,Position=0,ParameterSetName='userid course')]
        [Parameter(Mandatory,Position=0,ParameterSetName='userid courseid')]
        [int]
        $UserId,

        [Parameter(Mandatory,ValueFromPipeline,Position=0,ParameterSetName='user course')]
        [Parameter(Mandatory,ValueFromPipeline,Position=0,ParameterSetName='user courseid')]
        [MoodleUser]
        $User,

        [Parameter(Mandatory,ValueFromPipeline,Position=1,ParameterSetName='userid course')]
        [Parameter(Mandatory,ValueFromPipeline,Position=1,ParameterSetName='user course')]
        [MoodleCourse]
        $Course,

        [Parameter(Mandatory,Position=1,ParameterSetName='user courseid')]
        [Parameter(Mandatory,Position=1,ParameterSetName='userid courseid')]
        [int]
        $CourseId,

        [Parameter()]
        [ValidateSet('Manager','CourseCreator','EditingTeacher','Teacher','Student','Guest','User','FrontPage')]
        [string]
        $Role = 'Student'
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            Throw "You must call the Connect-Moodle cmdlet before calling any other cmdlets."
        }

        $function = 'enrol_manual_enrol_users'
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

        $roles = @{
            Manager = 1
            CourseCreator = 2
            EditingTeacher = 3
            Teacher = 4
            Student = 5
            Guest = 6
            User = 7
            FrontPage = 8
        }

        if (!$roles.ContainsKey($Role)) {
            throw 'Please specify a valid role.'
        }

        $roleId = $roles[$Role]

        $body["enrolments[$i][userid]"] = $UserId
        $body["enrolments[$i][courseid]"] = $CourseId
        $body["enrolments[$i][roleid]"] = $RoleId
        $i++
    }

    End {
        if ($i -eq 0) {
            Write-Verbose 'No enrolments to process.'
            return
        }

        if ($Course) {
            $target = "User #$UserId"
        } else {
            $target = "Course #$CourseId"
        }

        Write-Verbose $i
        if ($PSCmdlet.ShouldProcess($target, "Processing $i enrolments")) {
            $result = Invoke-RestMethod -Method Post -Uri ([uri]::new($Url, $path)) -Body $body -ContentType 'application/x-www-form-urlencoded' @proxySettings
            if ($result.errorcode) {
                Write-Error $result.message
            }
        }
    }
}
