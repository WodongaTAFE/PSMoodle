<#
.SYNOPSIS
    Get issued badges for a user or course
.DESCRIPTION
    Uses the core_badges_get_user_badges endpoint to retrieve badges issued to a user or course.
.PARAMETER User
    The user to get badges for.
.PARAMETER UserId
    The ID of the user to get badges for.
.PARAMETER Course
    The course to get badges for.
.PARAMETER CourseId
    The ID of the course to get badges for.
.EXAMPLE
    Get-MoodleUser -Email user@domain.com | Get-MoodleBadge

    Gets all badges issued to the user with the email address user@domain.com
.EXAMPLE
    Get-MoodleBadge -CourseId 1

    Gets all badges issued to assignees of the course with the ID 1
#>
function Get-MoodleBadge {
    [CmdletBinding(DefaultParameterSetName = 'userid')]
    param
    (
        [Parameter(Mandatory, ParameterSetName = 'user', ValueFromPipeline)]
        [MoodleUser] $User,

        [Parameter(Mandatory, Position = 0, ParameterSetName = 'userid')]
        [int] $UserId,

        [Parameter(Mandatory, ParameterSetName = 'course', ValueFromPipeline)]
        [MoodleCourse] $Course,

        [Parameter(Mandatory, ParameterSetName = 'courseid')]
        [int] $CourseId
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            Throw 'You must call the Connect-Moodle cmdlet before calling any other cmdlets.'
        }

        $function = 'core_badges_get_user_badges'
    }

    process {
        
        $path = "webservice/rest/server.php"

        $body = @{ 
            wstoken            = $Token
            wsfunction         = $function
            moodlewsrestformat = 'json'
        }

        if ($PSCmdlet.ParameterSetName -eq 'user') {
            $body.userid = $User.Id
        }

        if ($PSCmdlet.ParameterSetName -eq 'userid') {
            $body.userid = $UserId
        }

        if ($PSCmdlet.ParameterSetName -eq 'course') {
            $body.courseid = $Course.Id
        }

        if ($PSCmdlet.ParameterSetName -eq 'courseid') {
            $body.courseid = $CourseId
        }

        $results = Invoke-RestMethod -Uri ([uri]::new($Url, $path)) @proxySettings -Body $body

        foreach ($badge in $results.badges) {
            [MoodleBadge]@{
                Id             = $badge.id
                Name           = $badge.name
                Description    = $badge.description
                TimeCreated    = if ($badge.timecreated -gt 0) { [DateTimeOffset]::FromUnixTimeSeconds($badge.timecreated).DateTime } else { $null }
                TimeModified   = if ($badge.timemodified -gt 0) { [DateTimeOffset]::FromUnixTimeSeconds($badge.timemodified).DateTime } else { $null }
                UserCreated    = $badge.usercreated
                UserModified   = $badge.usermodified
                IssuerName     = $badge.issuername
                IssuerUrl      = $badge.issuerurl
                IssuerContact  = $badge.issuercontact
                Type           = $badge.type
                CourseId       = $badge.courseid
                Message        = $badge.message
                MessageSubject = $badge.messagesubject
                UniqueHash     = $badge.uniquehash
                DateIssued     = if ($badge.dateissued -gt 0) { [DateTimeOffset]::FromUnixTimeSeconds($badge.dateissued).DateTime } else { $null }
                DateExpire     = if ($badge.dateexpire -gt 0) { [DateTimeOffset]::FromUnixTimeSeconds($badge.dateexpire).DateTime } else { $null }
                Visible        = $badge.visible
                Email          = $badge.email
                Version        = $badge.version
                Language       = $badge.language
                BadgeUrl       = $badge.badgeurl
            }
        }
    }
}
