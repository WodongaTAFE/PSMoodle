<#
.SYNOPSIS
Updates a user.

.DESCRIPTION
Use this cmdlet to change properties on an existing user.

.PARAMETER Id
Specifies the unique ID of a user.

.PARAMETER User
Specifies a Moodle user.

.PARAMETER Password
Specifies a new password for the user.

.PARAMETER Auth
Specifies a new authentication type for the user.

.PARAMETER UserName
Specifies a new unique user name for the user.

.PARAMETER Email
Specifies a new unique email address for the user.

.PARAMETER FirstName
Specifies a new first name for the user.

.PARAMETER LastName
Specifies a new last name for the user.

.PARAMETER IdNumber
Specifies a new free-text ID Number for the user.

.PARAMETER Suspended
Specifies whether the user's account is suspended.

.EXAMPLE
Set-MoodleUser 1 -FirstName John

Changes user #1's first name to 'John'.

.EXAMPLE
Get-MoodleUser -UserName jbloggs | Set-MoodleUser -Suspended $true

Suspends a user whose user name is 'jbloggs'.
#>
function Set-MoodleUser {
    [CmdletBinding(DefaultParameterSetName='id',SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,ParameterSetName='id',Position=0)]
        [int]$Id,

        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName='pipelineuser')]
        [MoodleUser]$User,

        # The user's password.
        [Parameter()][securestring] $Password,

        # The user's authentication type.
        [Parameter()]
        [ValidateSet('Manual','LDAP','SAML2','OIDC')]
        [string]$Auth,

        [Parameter()]
        [string]$UserName,

        # The unique email address of the user.
        [Parameter()]
        [string]$Email,

        # The user's first name.
        [Parameter()]
        [string]$FirstName,

        # The user's family name.
        [Parameter()]
        [string]$LastName,

        # The external "ID Number" of the user.
        [Parameter()]
        [string] $IdNumber,

        # True if the user should be suspended.
        [Parameter()]
        [bool] $Suspended
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            Throw "You must call the Connect-Moodle cmdlet before calling any other cmdlets."
        }

        if ($Password) {
            $marshal = [Runtime.InteropServices.Marshal]
            $rawpwd = $marshal::PtrToStringAuto( $marshal::SecureStringToBSTR($Password) )
        }

        $function = 'core_user_update_users'
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"

        $body = @{}
        $i = 0
    }

    Process {
        if ($User) {
            $Id = $User.Id
        }

        $params = @{
            username = $UserName
            auth = $Auth.ToLower()
            password = $rawpwd
            firstname = $FirstName
            lastname = $LastName
            email = $Email
            idnumber = $IdNumber
            suspended = if ($Suspended) { 1 } else { 0 }
        }

        $body["users[$i][id]"] = $Id

        foreach ($key in $params.Keys) {
            if ($PSBoundParameters.ContainsKey($key)) {
                $body["users[$i][$key]"] = $params[$key]
            }
        }
        $i++
    }

    End {
        if ($PSCmdlet.ShouldProcess($Id, "Update")) {
            $result = Invoke-RestMethod -Method Post -Uri ([uri]::new($Url, $path)) -Body $body -ContentType 'application/x-www-form-urlencoded' @proxySettings
            if ($result.errorcode) {
                Write-Error $result.message
            }
        }
    }
}
