<#
.SYNOPSIS
Deletes a Moodle course category.

.DESCRIPTION
Deletes a course category and reparents or deletes all subcategories.

.PARAMETER Id
Specifies the unique ID of the course category to delete.

.PARAMETER Category
Specifies the course category to delete.

.PARAMETER Recurse
If specified, all subcategories under the given category will also be deleted.

.PARAMETER Parent
Specifies the new parent of any subcategories.

.EXAMPLE
Remove-MoodleCourseCategory -Id 1

Deletes course category #1.
#>
function Remove-MoodleCourseCategory {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,Position=0,ParameterSetName='id recurse')]
        [Parameter(Mandatory,Position=0,ParameterSetName='id reparent')]
        [int] $Id,

        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName='category recurse')]
        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName='category reparent')]
        [MoodleCourseCategory] $Category,

        [Parameter(Mandatory,ParameterSetName='id recurse')]
        [Parameter(Mandatory,ParameterSetName='category recurse')]
        [switch] $Recurse,

        [Parameter(Position=1,ParameterSetName='id reparent')]
        [Parameter(Position=1,ParameterSetName='category reparent')]
        [Alias('ParentId')]
        [int] $Parent = 0
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            throw "You must call the Connect-Moodle cmdlet before calling any other cmdlets."
        }

        $function = 'core_course_delete_categories'
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"
    }

    Process {
        if ($Category) {
            $Id = $Category.Id
        }

        $body = @{
            'categories[0][id]' = $Id
            'categories[0][recursive]' = if ($Recurse) { 1 } else { 0 }
            'categories[0][newparent]' = $Parent
        }

        if ($PSCmdlet.ShouldProcess($Id, "Delete")) {
            $result = Invoke-RestMethod -Method Post -Uri ([uri]::new($Url, $path)) -Body $body -ContentType 'application/x-www-form-urlencoded' @proxySettings
            if ($result.errorcode) {
                Write-Error $result.message
            }
        }
    }
}
