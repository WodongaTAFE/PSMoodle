<#
.SYNOPSIS
Finds users.

.DESCRIPTION
Finds users in the connected Moodle instance. The search considers all given parameters with the AND operation.

.PARAMETER Id
Specifies the unique ID of a user to find.

.PARAMETER UserName
Specifies the unique user name of a user to find.

.PARAMETER IdNumber
Specifies the free-text ID Number of a user to find.

.PARAMETER Email
Specifies the email address of a user to find. Use '%' as wildcard character.

.PARAMETER LastName
Specifies the lastname of a user to find. Use '%' as wildcard character.

.PARAMETER FirstName
Specifies the firstname of a user to find. Use '%' as wildcard character.

.PARAMETER Auth
Specifies the authentication method of users to find.

.EXAMPLE
Find-MoodleUser -UserName teacher

Gets a user whose user name is 'teacher'.

.EXAMPLE
Find-MoodleUser -Auth manual

Finds all users whose auth method is 'manual'.

.EXAMPLE
Find-MoodleUser -Email '%@example.com'

Finds all users whose email ends in '@example.com'.
#>
function Find-MoodleUser {
    # [OutputType([MoodleUserDetails])]
    [CmdletBinding()]
    param (
        [Parameter()][int] $Id,
        [Parameter()][string] $UserName,
        [Parameter()][string] $IdNumber,
        [Parameter()][string] $Email,
        [Parameter()][string] $LastName,
        [Parameter()][string] $FirstName,
        [Parameter()][string] $Auth
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            Throw "You must call the Connect-Moodle cmdlet before calling any other cmdlets."
        }

        $function = 'core_user_get_users'
    }

    Process {
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"

        $params = @{
            id        = $Id
            username  = $UserName
            idnumber  = $IdNumber
            email     = $Email
            lastname  = $LastName
            firstname = $FirstName
            auth      = $Auth
        }

        $body = @{}

        $index = 0
        foreach ($key in $params.Keys) {
            $value = $params[$key]
            if ($PSBoundParameters.ContainsKey($key)) {
                $body.Add("criteria[$index][key]", $key)
                $body.Add("criteria[$index][value]", $value)
                $index++
            }
        }

        $results = Invoke-RestMethod -Method Post -Uri ([uri]::new($Url, $path)) -Body $body -ContentType 'application/x-www-form-urlencoded' @proxySettings
        $results.users | ForEach-Object {
            New-Object -TypeName MoodleUserDetails -Property @{
                Id           = $_.id
                UserName     = $_.username
                Auth         = $_.auth
                FirstName    = $_.firstname
                LastName     = $_.lastname
                Email        = $_.email
                Institution  = $_.institution
                Department   = $_.department
                IdNumber     = $_.idnumber
                Suspended    = $_.suspended
                FirstAccess  = if ($_.firstaccess -gt 0) { [DateTimeOffset]::FromUnixTimeSeconds($_.firstaccess).DateTime } else { $null }
                LastAccess   = if ($_.lastaccess -gt 0) { [DateTimeOffset]::FromUnixTimeSeconds($_.lastaccess).DateTime } else { $null }
            }
        }
    }
}
