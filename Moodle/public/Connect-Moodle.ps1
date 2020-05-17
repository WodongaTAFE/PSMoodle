<#
.SYNOPSIS
Connects to a Moodle instance with an authentication token or credentials.

.DESCRIPTION
Call Connect-Moodle to connect to a Moodle instance (using its URL and credentials or token) before calling other Moodle cmdlets.

.PARAMETER Url
The base URL of the Moodle instance.

.PARAMETER Credential
Specifies a PSCredential object. For more information about the PSCredential object, type Get-Help Get-Credential.

The PSCredential object provides the user ID and password for organizational ID credentials.

.PARAMETER Token
Specifies an authentication token, provided by your Moodle administrator.

.EXAMPLE

Connect-Moodle https://sandbox.moodledemo.net/ -Credential (Get-Credential)

Prompts for your username and password, then connects to the Moodle sandbox demo instance.

.NOTES
See also: Disconnect-Moodle.
#>
function Connect-Moodle {
    [CmdletBinding(DefaultParameterSetName='cred')]
    param (
        # The base URL of your Moodle instance.
        [Parameter(Mandatory,Position=0)]
        [uri]$Url,

        # Secure login credentials for your Moodle instance.
        [Parameter(Mandatory,Position=1,ParameterSetName='cred')]
        [PSCredential] $Credential,
        
        # The API token to connect to Moodle.
        [Parameter(Mandatory,Position=1,ParameterSetName='token')]
        [string] $Token
    )
    
    $function = 'core_webservice_get_site_info'
    if ($Credential) {
        # Extract plain text password from credential
        $marshal = [Runtime.InteropServices.Marshal]
        $pwd = $marshal::PtrToStringAuto( $marshal::SecureStringToBSTR($Credential.Password) )

        $path = "/login/token.php?service=moodle_mobile_app&username=$($Credential.UserName)&password=$pwd"
        $result = Invoke-RestMethod -Uri ([uri]::new($Url, $path))

        $Token = $result.token
        if (!$Token) {
            throw 'Cannot connect to Moodle instance.'
        }
    }

    $path = "/webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"
    
    $result  = Invoke-RestMethod -Uri ([uri]::new($Url, $path))
    
    if ($result.SiteName) {
        Write-Verbose "Connected to $($result.SiteName) as user $($result.UserName)."
    
        $PsCmdlet.SessionState.PSVariable.Set("_MoodleUrl", $Url)
        $PsCmdlet.SessionState.PSVariable.Set("_MoodleToken", $Token)
    } else {
        throw "Could not connect to $Url with the given token."
    }    
}
