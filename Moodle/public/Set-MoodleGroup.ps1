<#
.SYNOPSIS
Updates a Moodle group.

.PARAMETER Id
Specifies the unique ID of the group to update.

.PARAMETER Group
Specifies the group to update.

.PARAMETER Name
Specifies the name of the group.

.PARAMETER Description
Specifies the description of the group.

.PARAMETER DescriptionFormat
Specifies the format of the given description.

.PARAMETER EnrolmentKey
Specifies the secret enrolment key of the group/course.

.PARAMETER IdNumber
Specifies a free-text ID Number for the group.

.EXAMPLE
Set-MoodleGroup -Id 1 -Name 'My Group' -Description 'Just a group!'

Updates group #1's name and description.
#>
function Set-MoodleGroup {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,ParameterSetName='id')]
        [int] $Id,

        [Parameter(Mandatory,ParameterSetName='group',ValueFromPipeline)]
        [MoodleGroup] $Group,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string] $Name,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Description,

        [Parameter(ValueFromPipelineByPropertyName)]
        [MoodleDescriptionFormat] $DescriptionFormat,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $EnrolmentKey,

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

        $function = 'core_group_update_groups'
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"
    }

    Process {
        if ($Group) {
            $Id = $Group.Id
        }

        $params = @{
            name = $Name
            idnumber = $IdNumber
            description = $Description
            descriptionformat = [int]$DescriptionFormat
            enrolmentkey = $EnrolmentKey
        }

        $body = @{
            'groups[0][id]' = $Id
        }

        foreach ($key in $params.Keys) {
            if ($PSBoundParameters.ContainsKey($key)) {
                $body["groups[0][$key]"] = $params[$key]
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
