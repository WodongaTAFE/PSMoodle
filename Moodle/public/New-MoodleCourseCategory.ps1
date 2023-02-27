<#
.SYNOPSIS
Creates a new Moodle course category.

.PARAMETER Name
Specifies the name of the new course catgeory.

.PARAMETER Description
Specifies the description of the new course catgeory.

.PARAMETER DescriptionFormat
Specifies the format of the given description.

.PARAMETER Parent
Specifies the parent course category to which the course category should be added.

.PARAMETER ParentId
Specifies the ID of the parent course category to which the course category should be added.

.PARAMETER Theme
Specifies the theme for this course catgeory.

.PARAMETER IdNumber
Specifies a new free-text ID Number for the course catgeory.

.EXAMPLE
New-MoodleCourseCatgeory -ParentId 1 -Name 'My Subcatgeory' -Description 'A subcategory of category 1!'

#>
function New-MoodleCourseCategory {
    # [OutputType([MoodleCourseCategory])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $Name,

        [string] $Description,
        [MoodleDescriptionFormat] $DescriptionFormat = [MoodleDescriptionFormat]::HTML,

        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName='parent')]
        [MoodleCourseCategory]
        $Parent,

        [Parameter(ParameterSetName='parentid')]
        [int]
        $ParentId = 0,

        [string] $Theme,

        [string] $IdNumber
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            Throw "You must call the Connect-Moodle cmdlet before calling any other cmdlets."
        }

        $function = 'core_course_create_categories'
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"
    }

    Process {
        if ($Parent) {
            $ParentId = $Parent.Id
        }

        $body = @{
            'categories[0][name]' = $Name
            'categories[0][description]' = $Description
            'categories[0][descriptionformat]' = [int]$DescriptionFormat
            'categories[0][parent]' = $ParentId
            'categories[0][theme]' = $Theme
            'categories[0][idnumber]' = $IdNumber
        }

        if ($PSCmdlet.ShouldProcess($UserName, "Create")) {
            $results = Invoke-RestMethod -Method Post -Uri ([uri]::new($Url, $path)) -Body $body -ContentType 'application/x-www-form-urlencoded' @proxySettings

            if ($results) {
                if ($results.errorcode) {
                    Write-Error $results.message
                    return
                }

                $results | Foreach-Object {
                    New-Object -TypeName MoodleCourseCategory -Property @{
                        Id=$_.id
                        Name=$_.name
                        # that's all we get from the web service - populate the rest from the params
                        IdNumber = $IdNumber
                        Description = $Description
                        DescriptionFormat = $Descriptionformat
                        Parent=$ParentId
                        Visible = $true
                    }
                }
            }
        }
    }
}
