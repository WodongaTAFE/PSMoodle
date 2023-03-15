<#
.SYNOPSIS
Finds courses.

.DESCRIPTION
Finds courses in the connected Moodle instance.

.PARAMETER SearchString
The text to search for.

.PARAMETER Enrolled
Limits the search to only enrolled courses.

.PARAMETER Completion
Limits the search to only courses that require completion.

.EXAMPLE
Find-MoodleCourse -SearchString diploma

Finds all courses containing the text "diploma".

#>
function Find-MoodleCourse {
    # [OutputType([MoodleCourse])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0)][string] $SearchString,
        [Parameter()][switch]$Enrolled,
        [Parameter()][switch]$Completion
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            Throw "You must call the Connect-Moodle cmdlet before calling any other cmdlets."
        }

        $function = 'core_course_search_courses'
    }

    Process {
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"

        $body = @{
            criterianame = 'search'
            criteriavalue = $SearchString
            limittoenrolled = if ($Enrolled) { 1 } else { 0 }
            onlywithcompletion = if ($Completion) { 1 } else { 0 }
        }

        $result = Invoke-RestMethod -Uri ([uri]::new($Url, $path)) -Method POST -Body $body -ContentType 'application/x-www-form-urlencoded' @proxySettings
        if ($result.courses) {
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
}
