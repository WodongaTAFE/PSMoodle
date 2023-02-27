<#
.SYNOPSIS
Gets courses a user is enrolled in.

.PARAMETER UserId
Specifies the unique ID of a user.

.PARAMETER User
Specfies a Moodle user.

.EXAMPLE
Get-MoodleUserCourse -UserId 1

Gets all courses that user #1 is enrolled in.

.EXAMPLE
Get-MoodleUser 1 | Get-MoodleUserCourse

Gets all courses that user #1 is enrolled in.
#>
function Get-MoodleUserCourse {
    # [OutputType([MoodleCourse])]
    [CmdletBinding(DefaultParameterSetName='id')]
    param (
        # The unique user id.
        [Parameter(ParameterSetName="id",Mandatory,Position=0)][int] $UserId,
        # The user to return courses for.
        [Parameter(ParameterSetName="pipeline", ValueFromPipeline)][MoodleUser]$User
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            Throw "You must call the Connect-Moodle cmdlet before calling any other cmdlets."
        }

        $function = 'core_enrol_get_users_courses'
    }

    Process {
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"

        if ($User) {
            $UserId = $User.Id
        }
        $path = $path + "&userid=$UserId"

        $results = Invoke-RestMethod -Uri ([uri]::new($Url, $path)) @proxySettings
        $results | Foreach-Object {
            New-Object -TypeName MoodleCourse -Property @{
                Id = $_.id
                ShortName = $_.shortname
                FullName = $_.fullname
                CategoryId = $_.category
                IdNumber = $_.idnumber
                Visible = if ($_.visible) { $true } else {$false }
            }
        }
    }
}
