<#
.SYNOPSIS
Creates a new Moodle user.

.PARAMETER Password
Specifies the new user's password.

.PARAMETER GeneratePassword
If specified, allow Moodle to generate a password and email it to the new user.

.PARAMETER Auth
Specifies the new user's authentication type. Default is Manual.

.PARAMETER UserName
Specifies a unique user name for the new user.

.PARAMETER Email
Specifies a unique email address for the new user.

.PARAMETER FirstName
Specifies the new user's first name.

.PARAMETER LastName
Specifies the new user's last name.

.PARAMETER IdNumber
Specifies a free-text ID Number for the new user.

.EXAMPLE
New-MoodleUser -GeneratePassword -UserName jbloggs -Email jbloggs@example.com -FirstName Joe -LastName Bloggs

Creates a new user for Joe Bloogs with username jbloggs. Moodle will generate a password and email it to him.

#>
function New-MoodleUser {
    # [OutputType([MoodleUserDetails])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The user's password.
        [Parameter(Mandatory,ParameterSetName='suppliedpassword')][securestring] $Password,

        # Generate a password and email it to the new user.
        [Parameter(Mandatory,ParameterSetName='generatedpassword')][switch][bool] $GeneratePassword,

        # The user's authentication type.
        [Parameter(Mandatory)]
        [ValidateSet('Manual','LDAP','SAML2','OIDC')]
        [string]$Auth,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$UserName,

        # The unique email address of the user.
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Email,

        # The user's first name.
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$FirstName,

        # The user's family name.
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$LastName,

        # The external "ID Number" of the user.
        [Parameter(ValueFromPipelineByPropertyName)][string] $IdNumber
    )

    Begin {
        $Url = $Script:_MoodleUrl
        $Token = $Script:_MoodleToken
        $proxySettings = $Script:_MoodleProxySettings

        if (!$Url -or !$Token) {
            Throw "You must call the Connect-Moodle cmdlet before calling any other cmdlets."
        }

        $function = 'core_user_create_users'
        $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"
    }

    Process {
        $body = @{
            'users[0][username]' = $UserName
            'users[0][auth]' = $Auth.ToLower()
            'users[0][firstname]' = $FirstName
            'users[0][lastname]' = $LastName
            'users[0][email]' = $Email
            'users[0][idnumber]' = $IdNumber
        }

        if ($GeneratePassword) {
            $body['users[0][createpassword]'] = 1

        } elseif (!$NoPassword) {
            $marshal = [Runtime.InteropServices.Marshal]
            $pass = $marshal::PtrToStringAuto( $marshal::SecureStringToBSTR($Password) )
            $body['users[0][password]'] = $pass
        }

        if ($PSCmdlet.ShouldProcess($UserName, "Create")) {
            $results = Invoke-RestMethod -Method Post -Uri ([uri]::new($Url, $path)) -Body $body -ContentType 'application/x-www-form-urlencoded' @proxySettings
            $results | Foreach-Object {
                New-Object -TypeName MoodleUserDetails -Property @{
                    Id=$_.id
                    UserName=$UserName
                    Auth=$Auth
                    FirstName=$FirstName
                    LastName=$LastName
                    Email=$Email
                    IdNumber=$IdNumber
                }
            }
        }
    }
}
