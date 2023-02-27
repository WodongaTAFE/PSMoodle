<#
.SYNOPSIS
Gets a Moodle user.

.DESCRIPTION
Gets the details of a Moodle user.

.PARAMETER Id
Specifies the unique ID of a user.

.PARAMETER UserName
Specifies the unique user name of a user.

.PARAMETER IdNumber
Specifies the free-text ID Number of a user.

.PARAMETER Email
Specifies the unique email address of a user.

.EXAMPLE
Get-MoodleUser -UserName teacher

Gets a user whose user name is 'teacher'.

.EXAMPLE
Get-MoodleUser -Email JBloggs@example.com

Searches for a user whose email address is 'JBloggs@example.com' or 'jbloggs@example.com'.
Searching for a user by email is case-sensitive, so we try the lower-case variation as part of the same search.
#>
function Get-MoodleUser {
    # [OutputType([MoodleUserDetails])]
    [CmdletBinding(DefaultParameterSetName='id')]
    param (
        # The unique user id.
        [Parameter(ParameterSetName="id",Mandatory,Position=0)][int] $Id,
        # The unique user name.
        [Parameter(ParameterSetName="username",Mandatory)][string] $UserName,
        # The external "ID Number" of the user.
        [Parameter(ParameterSetName="idnumber",Mandatory)][string] $IdNumber,
        # THe unique email address of the user.
        [Parameter(ParameterSetName="email",Mandatory)][string] $Email
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            Throw "You must call the Connect-Moodle cmdlet before calling any other cmdlets."
        }

        $function = 'core_user_get_users_by_field'
    }

    Process {
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"

        $params = @{
            id = $Id
            username = $UserName
            idnumber = $IdNumber
            email = $Email
        }

        $index = 0
        foreach ($key in $params.Keys) {
            $value = $params[$key]
            if ($PSBoundParameters.ContainsKey($key)) {
                $path = $path + "&field=$($key)&values[0]=$value"

                if ($value -cne $value.ToString().ToLower()) {
                    $path = $path + "&values[1]=$($value.ToLower())"
                }
                $index++
            }
        }

        $results = Invoke-RestMethod -Uri ([uri]::new($Url, $path)) @proxySettings
        $results | Foreach-Object {
            New-Object -TypeName MoodleUserDetails -Property @{
                Id=$_.id
                UserName = $_.username
                Auth = $_.auth
                FirstName = $_.firstname
                LastName = $_.lastname
                Email = $_.email
                IdNumber = $_.idnumber
                Suspended = $_.suspended
                FirstAccess = if ($_.firstaccess -gt 0) { [DateTimeOffset]::FromUnixTimeSeconds($_.firstaccess).DateTime } else { $null }
                LastAccess = if ($_.lastaccess -gt 0) { [DateTimeOffset]::FromUnixTimeSeconds($_.lastaccess).DateTime } else { $null }
            }
        }
    }
}
