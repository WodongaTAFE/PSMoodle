<#
.SYNOPSIS
Gets a course category.

.DESCRIPTION
Gets a course category from the connected Moodle instance.

.PARAMETER Id
Specifies the unique ID of a course category.

.PARAMETER Name
Specifies the name of a course category to search for.

.PARAMETER Parent
Specifies The unique id of the parent course category.

.PARAMETER IdNumber
Specifies the free-text ID Number of a course category.

.PARAMETER Visible
If specified, only visible course categories are returned.

.PARAMETER Recurse
If specified, child course categories are also returned.

.EXAMPLE

Get-MoodleCourseCategory -Id 1 -Recurse

Gets course category #1 and all its child categories.

.EXAMPLE

PS C:\Get-MoodleCourseCategory -IdNumber foo -Visible

Gets visible course categories whose ID Number is 'foo'
#>
function Get-MoodleCourseCategory {
    # [OutputType([MoodleCourseCategory])]
    [CmdletBinding()]
    param (
        [Parameter(Position=0)][int] $Id,
        [string] $Name,
        [int] $Parent,
        [string] $IdNumber,
        [switch][bool] $Visible,
        [switch][bool] $Recurse = $false
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            throw "You must call the Connect-Moodle cmdlet before calling any other cmdlets."
        }

        $function = 'core_course_get_categories'
    }

    Process {
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"
        $path = $path + "&addsubcategories=$(if ($Recurse) { 1 } else { 0 })"

        $params = @{
            id = $Id
            name = $Name
            parent = $Parent
            idnumber = $IdNumber
            visible = if ($Visible) { 1 } else { 0 }
        }

        $index = 0
        foreach ($key in $params.Keys) {
            if ($PSBoundParameters.ContainsKey($key)) {
                $path = $path + "&criteria[$index][key]=$key&criteria[$index][value]=$($params[$key])"
                $index++
            }
        }
        $results = Invoke-RestMethod -Uri ([uri]::new($Url, $path)) @proxySettings
        $results | ForEach-Object {
            New-Object -TypeName MoodleCourseCategory -Property @{
                Id = $_.id
                Name = $_.name
                IdNumber = $_.idnumber
                Description = $_.description
                DescriptionFormat = $_.descriptionformat
                Parent = $_.parent
                Visible = $_.visible
            }
        }
    }
}
