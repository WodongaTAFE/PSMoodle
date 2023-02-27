<#
.SYNOPSIS
Creates a new Moodle group.

.PARAMETER Course
Specifies the course to which the group should apply.

.PARAMETER CourseId
Specifies the ID of the course to which the group should apply.

.PARAMETER Name
Specifies the name of the new group.

.PARAMETER Description
Specifies the description of the new group.

.PARAMETER DescriptionFormat
Specifies the format of the given description.

.PARAMETER EnrolmentKey
Specifies the secret enrolment key for this group/course.

.PARAMETER IdNumber
Specifies a new free-text ID Number for the group.

.EXAMPLE
New-MoodleGroup -CourseId 1 -Name 'My Group' -Description 'Group description!'

#>
function New-MoodleGroup {
    # [OutputType([MoodleGroup])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,ValueFromPipeline,Position=0,ParameterSetName='course')]
        [MoodleCourse]
        $Course,

        [Parameter(Mandatory,Position=0,ParameterSetName='courseid')]
        [int]
        $CourseId,

        # The name of the group.
        [Parameter(Mandatory)]
        [string] $Name,

        # The description of the group.
        [string] $Description,

        # The format of the supplied description.
        [MoodleDescriptionFormat] $DescriptionFormat = [MoodleDescriptionFormat]::HTML,

        # Secret enrolment phrase.
        [string] $EnrolmentKey,

        # The external "ID Number" of the user.
        [string] $IdNumber
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            Throw "You must call the Connect-Moodle cmdlet before calling any other cmdlets."
        }

        $function = 'core_group_create_groups'
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"
    }

    Process {
        if ($Course) {
            $CourseId = $Course.Id
        }

        $body = @{
            'groups[0][courseid]' = $CourseId
            'groups[0][name]' = $Name
            'groups[0][description]' = $Description
            'groups[0][descriptionformat]' = [int]$DescriptionFormat
            'groups[0][enrolmentkey]' = $EnrolmentKey
            'groups[0][idnumber]' = $IdNumber
        }

        if ($PSCmdlet.ShouldProcess($UserName, "Create")) {
            $results = Invoke-RestMethod -Method Post -Uri ([uri]::new($Url, $path)) -Body $body -ContentType 'application/x-www-form-urlencoded' @proxySettings

            if ($results) {
                if ($results.errorcode) {
                    Write-Error $results.message
                }

                $results | Foreach-Object {
                    New-Object -TypeName MoodleGroup -Property @{
                        Id=$_.id
                        CourseId=$_.courseid
                        Name=$_.name
                        IdNumber = $_.idnumber
                        Description = $_.description
                        DescriptionFormat = $_.descriptionformat
                        EnrolmentKey = $_.enrolmentkey
                    }
                }
            }
        }
    }
}
