<#
.SYNOPSIS
Updates a Moodle course category.

.PARAMETER Id
Specifies the unique ID of the course category to update.

.PARAMETER Category
Specifies the course category to update.

.PARAMETER Name
Specifies the name of the course category.

.PARAMETER Description
Specifies the description of the course category.

.PARAMETER DescriptionFormat
Specifies the format of the given description.

.PARAMETER Parent
Specifies the unique id of the parent category.

.PARAMETER Theme
Specifies the theme of the course category.

.PARAMETER IdNumber
Specifies a free-text ID Number for the course category.

.EXAMPLE
Set-MoodleCourseCategory -Id 1 -Name 'My Category' -Description 'Just a category!'

Updates course category #1's name and description.
#>
function Set-MoodleCourseCategory {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,ParameterSetName='id',ValueFromPipelineByPropertyName)]
        [int] $Id,

        [Parameter(Mandatory,ParameterSetName='category',ValueFromPipeline)]
        [MoodleCourseCategory] $Category,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string] $Name,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Description,

        [Parameter(ValueFromPipelineByPropertyName)]
        [MoodleDescriptionFormat] $DescriptionFormat,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('ParentId')]
        [int] $Parent,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Theme,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $IdNumber
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            Throw "You must call the Connect-Moodle cmdlet before calling any other cmdlets."
        }

        $function = 'core_course_update_categories'
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"
    }

    Process {
        if ($Category) {
            $Id = $Category.Id
        }

        $params = @{
            name = $Name
            idnumber = $IdNumber
            description = $Description
            descriptionformat = [int]$DescriptionFormat
            parent = $Parent
            theme = $Theme
        }

        $body = @{
            'categories[0][id]' = $Id
        }

        foreach ($key in $params.Keys) {
            if ($PSBoundParameters.ContainsKey($key)) {
                $body["categories[0][$key]"] = $params[$key]
            }
        }

        if ($PSCmdlet.ShouldProcess($Id, "Update")) {
            $result = Invoke-RestMethod -Method Post -Uri ([uri]::new($Url, $path)) -Body $body -ContentType 'application/x-www-form-urlencoded' @proxySettings
            if ($result.errorcode) {
                Write-Error $result.message
            }
        }
    }
}
