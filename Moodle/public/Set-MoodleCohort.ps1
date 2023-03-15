<#
.SYNOPSIS
Updates a Moodle cohort.

.PARAMETER Id
Specifies the unique ID of the cohort to update.

.PARAMETER Cohort
Specifies the cohort to update.

.PARAMETER CategoryId
Specifies the ID of the course category to which the cohort should apply.

.PARAMETER Category
Specifies the course category to which the cohort should apply.

.PARAMETER System
Specifies that this should be a system-level cohort.

.PARAMETER Name
Specifies the name of the cohort.

.PARAMETER Description
Specifies the description of the cohort.

.PARAMETER DescriptionFormat
Specifies the format of the given description.

.PARAMETER Visible
Specifies whether the chort should be visible.

.PARAMETER Theme
Specifies the theme of the cohort.

.PARAMETER IdNumber
Specifies a free-text ID Number for the cohort.

.EXAMPLE
Set-MoodleCohort -Id 1 "Teachers' Pets" -Description 'Our favourite students.'

Updates cohort #1's name and description.
#>
function Set-MoodleCohort {
    [CmdletBinding(SupportsShouldProcess)]

    param (
        [Parameter(Mandatory,ParameterSetName='id-system',ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory,ParameterSetName='id-catid',ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory,ParameterSetName='id-category',ValueFromPipelineByPropertyName)]
        [int] $Id,

        [Parameter(Mandatory,ParameterSetName='cohort-system',ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory,ParameterSetName='cohort-catid',ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory,ParameterSetName='cohort-category',ValueFromPipelineByPropertyName)]
        [MoodleCohort] $Cohort,

        [Parameter(Mandatory,ParameterSetName='id-system',ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory,ParameterSetName='cohort-system',ValueFromPipelineByPropertyName)]
        [switch] $System,

        [Parameter(Mandatory,ParameterSetName='id-catid',ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory,ParameterSetName='cohort-catid',ValueFromPipelineByPropertyName)]
        [int] $CategoryId,

        [Parameter(Mandatory,ParameterSetName='id-category',ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory,ParameterSetName='cohort-category',ValueFromPipelineByPropertyName)]
        [MoodleCourseCategory] $Category,

        [Parameter(Mandatory,ParameterSetName='id-system',ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory,ParameterSetName='id-catid',ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory,ParameterSetName='id-category',ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName='cohort-system',ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName='cohort-category',ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName='cohort-catid',ValueFromPipelineByPropertyName)]
        [string] $Name,

        [Parameter(Mandatory,ParameterSetName='id-system',ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory,ParameterSetName='id-catid',ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory,ParameterSetName='id-category',ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName='cohort-system',ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName='cohort-category',ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName='cohort-catid',ValueFromPipelineByPropertyName)]
        [string] $IdNumber,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Description,

        [Parameter(ValueFromPipelineByPropertyName)]
        [MoodleDescriptionFormat] $DescriptionFormat,

        [Parameter(ValueFromPipelineByPropertyName)]
        [bool] $Visible,

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

        $function = 'core_cohort_update_cohorts'
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"
    }

    Process {
        if ($Cohort) {
            $Id = $Cohort.Id
        }

        $params = @{
            name = $Name
            idnumber = $IdNumber
            description = $Description
            descriptionformat = [int]$DescriptionFormat
            visible = if ($Visible) { 1 } else { 0 }
            theme = $Theme
        }

        $body = @{
            'cohorts[0][id]' = $Id
        }

        foreach ($key in $params.Keys) {
            if ($PSBoundParameters.ContainsKey($key)) {
                $body["cohorts[0][$key]"] = $params[$key]
            } elseif ($PSBoundParameters.ContainsKey('Cohort')){
                Switch ($key){
                    'descriptionformat' {
                        $body["cohorts[0][$key]"] = [int]$Cohort.$key
                    }
                    'visible' {
                        $body["cohorts[0][$key]"] = if ($Cohort.$key) { 1 } else { 0 }
                    }
                    'default' {
                        $body["cohorts[0][$key]"] = $Cohort.$key
                    }
                }
            }
        }

        if ($System) {
            $body['cohorts[0][categorytype][type]'] = 'system'
            $body['cohorts[0][categorytype][value]'] = '0'
        }
        else {
            if ($Category) {
                $CategoryId = $Category.Id
            }

            if ($CategoryId) {
                $body['cohorts[0][categorytype][type]'] = 'id'
                $body['cohorts[0][categorytype][value]'] = $CategoryId
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
