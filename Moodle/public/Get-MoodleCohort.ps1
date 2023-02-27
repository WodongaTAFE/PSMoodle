<#
.SYNOPSIS
Gets a Moodle cohort.

.PARAMETER Id
Specifies the unique ID of the cohort.

.PARAMETER System
Query cohorts on system context.

.PARAMETER System
Query cohorts on system context.

.PARAMETER Level
Query cohorts on specified [MoodleContext] and.

.PARAMETER InstanceID
Query cohorts on specified [MoodleContext].

.PARAMETER User
Query cohorts on specified [MoodleUser].

.PARAMETER Category
Query cohorts on specified [MoodleCategory].

.PARAMETER Course
Query cohorts on specified [MoodleCourse].

.PARAMETER Query
Query cohorts with specified string.

.PARAMETER LimitFrom
Start results from this offset

.PARAMETER LimitNum
Limit numbers of results to spefied value

.PARAMETER All
Return all results.

.PARAMETER Includes
What other contexts to fetch the frameworks from. (all, parents, self)


.EXAMPLE
Get-MoodleCohort -Id  1

Gets a cohort whose ID is 1.
#>
function Get-MoodleCohort {
    [CmdletBinding(DefaultParameterSetName='id')]
    param (
        [Parameter(Mandatory, Position=0, ParameterSetName='id')]
        [int] $Id,

        [Parameter(Mandatory, ParameterSetName='system')]
        [switch] $System,

        [Parameter(Mandatory, ParameterSetName='level')]
        [MoodleContext] $Level,

        [Parameter(Mandatory, ParameterSetName='level')]
        [string] $InstanceId,

        [Parameter(ParameterSetName='user', ValueFromPipeline)]
        [MoodleUser] $User,

        [Parameter(ParameterSetName='category', ValueFromPipeline)]
        [MoodleCourseCategory] $Category,

        [Parameter(ParameterSetName='course', ValueFromPipeline)]
        [MoodleCourse] $Course,

        [Parameter(ParameterSetName='user')]
        [Parameter(ParameterSetName='category')]
        [Parameter(ParameterSetName='course')]
        [Parameter(ParameterSetName='level')]
        [Parameter(ParameterSetName='system')]
        [string] $Query = '',

        [Parameter(ParameterSetName='user')]
        [Parameter(ParameterSetName='category')]
        [Parameter(ParameterSetName='course')]
        [Parameter(ParameterSetName='level')]
        [Parameter(ParameterSetName='system')]
        [int] $LimitFrom = 0,

        [Parameter(ParameterSetName='user')]
        [Parameter(ParameterSetName='category')]
        [Parameter(ParameterSetName='course')]
        [Parameter(ParameterSetName='level')]
        [Parameter(ParameterSetName='system')]
        [int]$LimitNum = 25,

        [Parameter(ParameterSetName='user')]
        [Parameter(ParameterSetName='category')]
        [Parameter(ParameterSetName='course')]
        [Parameter(ParameterSetName='level')]
        [Parameter(ParameterSetName='system')]
        [switch]$All ,

        [Parameter(ParameterSetName='user')]
        [Parameter(ParameterSetName='category')]
        [Parameter(ParameterSetName='course')]
        [Parameter(ParameterSetName='level')]
        [Parameter(ParameterSetName='id')]
        [ValidateSet('all', 'parents', 'self')]
        [String]$Includes = 'self'
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            Throw 'You must call the Connect-Moodle cmdlet before calling any other cmdlets.'
        }

        if ($PSBoundParameters.ContainsKey('id')) {
            $function = 'core_cohort_get_cohorts'
        } else {
            $function = 'core_cohort_search_cohorts'
        }
    }

    Process {
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"
        $iterParams = @{}

        switch -Wildcard ($PsCmdlet.ParameterSetName) {
            'id' {
                $path += "&cohortids[0]=$Id"
                Write-debug "Request path: $($path -replace 'wstoken=(.*?)&','wstoken=[hidden]&')"
                $results = Invoke-RestMethod -Uri ([uri]::new($Url, $path)) @proxySettings
                Break
            }
            'level' {
                $iterParams.Add('InstanceId', $InstanceId)
                $iterParams.Add('Level', $Level)
            }
            'system' {
                $Level = [MoodleContext]::System
                $ContextId = 10
                $iterParams.Add('System', $System)
                $includes='parents'
            }
            'user'{
                $Level = [MoodleContext]::User
                $InstanceId = $User.Id
                $iterParams.Add('User', $User)
            }
            'category' {
                $Level = [MoodleContext]::CourseCat
                $InstanceId = $Category.Id
                $iterParams.Add('Category', $Category)
            }
            'course' {
                $Level = [MoodleContext]::Course
                $InstanceId = $Course.Id
                $iterParams.Add('Course', $Course)
            }
            '*' {
                $contextLevel = $Level.ToString().ToLower()
                $path += "&context[contextlevel]=$contextLevel"

                if($InstanceID -ne '') {
                    $path += "&context[instanceid]=$InstanceId"
                }

                if($ContextID) {
                    $path += "&context[contextid]=$ContextId"
                }

                $path += "&includes=$Includes&limitfrom=$LimitFrom&limitnum=$LimitNum&query=$Query"
                Write-debug "Request path: $($path -replace 'wstoken=(.*?)&','wstoken=[hidden]&')"
                $results = (Invoke-RestMethod -Uri ([uri]::new($Url, $path)) @proxySettings).cohorts
            }
        }


        if ($results) {
            $results | Foreach-Object {
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

            #is there need to fetch more results
            if($All -and $results.Count -eq $LimitNum ) {
                $iterParams.Add('LimitFrom', $LimitFrom + $LimitNum)
                $iterParams.Add('LimitNum', $LimitNum )
                $iterParams.Add('All', $All)
                Write-Debug "Call for more"
                Get-MoodleCohort @iterParams
            }
        }
    }
}
