<#
.SYNOPSIS
Gets a course.

.DESCRIPTION
Gets a course from the connected Moodle instance.

.PARAMETER Id
Specifies the unique ID of a course.

.PARAMETER Category
Specifies a course category.

.PARAMETER ShortName
Specifies the short name of a course.

.PARAMETER IdNumber
Specifies the free-text ID Number of a course.

.PARAMETER CategoryId
Specifies a course category ID.

.EXAMPLE
Get-MoodleCourse -ShortName NET101

Gets a course whose short name is 'NET101'.

.EXAMPLE
Get-MoodleCourseCategory 17 | Get-MoodleCourse

Gets all courses whose category is #17.
#>
function Get-MoodleCourse {
    # [OutputType([MoodleCourse])]
    [CmdletBinding(DefaultParameterSetName='id')]
    param (
        # The unique course id.
        [Parameter(ParameterSetName="id",Position=0)][int] $Id,
        # Only return courses from this category.
        [Parameter(ParameterSetName="pipeline", ValueFromPipeline)][MoodleCourseCategory]$Category,
        # The short name of the course.
        [Parameter(ParameterSetName="shortname")][string] $ShortName,
        # The external "ID Number" of the course.
        [Parameter(ParameterSetName="idnumber")][string] $IdNumber,
        # The category id.
        [Parameter(ParameterSetName="category")][int] $CategoryId
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            Throw "You must call the Connect-Moodle cmdlet before calling any other cmdlets."
        }

        $function = 'core_course_get_courses_by_field'
    }

    Process {
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"

        $params = @{
            id = $Id
            shortname = $ShortName
            idnumber = $IdNumber
        }

        if ($PSBoundParameters.ContainsKey('categoryid')) {
            $path += "&field=category&value=$CategoryId"
        } elseif ($Category) {
            $path += "&field=category&value=$($Category.Id)"
        }

        foreach ($key in $params.Keys) {
            if ($PSBoundParameters.ContainsKey($key)) {
                $path += "&field=$key&value=$($params[$key])"
            }
        }

        $result = Invoke-RestMethod -Uri ([uri]::new($Url, $path)) @proxySettings
        $result.courses | Foreach-Object {
            New-Object -TypeName MoodleCourse -Property @{
                Id = $_.id
                ShortName = $_.shortname
                FullName = $_.fullname
                CategoryId = $_.categoryid
                IdNumber = $_.idnumber
                Visible = if ($_.visible) { $true } else {$false }
            }
        }
    }
}
