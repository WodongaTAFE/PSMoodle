<#
.SYNOPSIS
Creates a new Moodle cohort.

.PARAMETER CategoryId
Specifies the ID of the course category to which the cohort should apply.

.PARAMETER Category
Specifies the course category to which the cohort should apply.

.PARAMETER System
Specifies that this should be a system-level cohort.

.PARAMETER Name
Specifies the name of the new cohort.

.PARAMETER Description
Specifies the description of the new cohort.

.PARAMETER DescriptionFormat
Specifies the format of the given description.

.PARAMETER Visible
Specifies whether the new chort should be visible.

.PARAMETER Theme
Specifies the theme of the new cohort.

.PARAMETER IdNumber
Specifies a free-text ID Number for the new cohort.

.EXAMPLE
New-MoodleCohort -System -Name "Teachers' Pets" -Description 'Our favourite students.'

Creates a new system-level cohort.
#>
function New-MoodleCohort {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,ParameterSetName='system')]
        [switch] $System,

        [Parameter(Mandatory,ParameterSetName='catid')]
        [int] $CategoryId,

        [Parameter(Mandatory,ParameterSetName='category')]
        [MoodleCourseCategory] $Category,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string] $Name,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string] $IdNumber,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Description,

        [Parameter(ValueFromPipelineByPropertyName)]
        [MoodleDescriptionFormat] $DescriptionFormat = [MoodleDescriptionFormat]::HTML,

        [Parameter(ValueFromPipelineByPropertyName)]
        [bool] $Visible = $true,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Theme
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            Throw "You must call the Connect-Moodle cmdlet before calling any other cmdlets."
        }

        $function = 'core_cohort_create_cohorts'
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"
    }

    Process {
        $body = @{
            'cohorts[0][name]' = $Name
            'cohorts[0][description]' = $Description
            'cohorts[0][descriptionformat]' = [int]$DescriptionFormat
            'cohorts[0][idnumber]' = $IdNumber
        }

        if ($System) {
            $body['cohorts[0][categorytype][type]'] = 'system'
            $body['cohorts[0][categorytype][value]'] = '0'
        }
        else {
            if ($Category) {
                $CategoryId = $Category.Id
            }

            $body['cohorts[0][categorytype][type]'] = 'id'
            $body['cohorts[0][categorytype][value]'] = $CategoryId
        }

        if ($PSCmdlet.ShouldProcess($Name, "Create")) {
            Invoke-RestMethod -Method Post -Uri ([uri]::new($Url, $path)) -Body $body -ContentType 'application/x-www-form-urlencoded' @proxySettings | Foreach-Object {
                New-Object -TypeName MoodleCohort -Property @{
                    Id = $_.id
                    Name = $_.name
                    IdNumber = $_.idnumber
                    Description = $_.description
                    DescriptionFormat = $_.descriptionformat
                    Visible = $_.visible
                    Theme = $_.theme
                }
            }
        }
    }
}
