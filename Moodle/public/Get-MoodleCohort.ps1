<#
.SYNOPSIS
Gets a Moodle cohort.

.PARAMETER Id
Specifies the unique ID of the cohort.

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
        [string] $Query = ''
    )
    
    Begin {
        $Url = $PsCmdlet.SessionState.PSVariable.GetValue('_MoodleUrl')
        $Token = $PsCmdlet.SessionState.PSVariable.GetValue('_MoodleToken')
        
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

        if ($PSBoundParameters.ContainsKey('id')) {
            $path += "&cohortids[0]=$Id"

            $results = Invoke-RestMethod -Uri ([uri]::new($Url, $path))
        }
        else {
            if ($System) {
                $Level = [MoodleContext]::System
                $InstanceId = 1
            }
            elseif ($User) {
                $Level = [MoodleContext]::User
                $InstanceId = $User.Id
            }
            elseif ($Category) {
                $Level = [MoodleContext]::CourseCat
                $InstanceId = $Category.Id
            } 
            elseif ($Course) {
                $Level = [MoodleContext]::Course
                $InstanceId = $Course.Id
            }

            $contextLevel = $Level.ToString().ToLower()
            $path += "&context[contextlevel]=$contextLevel&context[instanceid]=$InstanceId&includes=self&query=$Query"

            $results = (Invoke-RestMethod -Uri ([uri]::new($Url, $path))).cohorts
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
        }
    }
}
