function Get-MoodleCurrentSessionInfo {
    # [OutputType([MoodleSessionInfo])]
    [CmdletBinding()]
    param()

    $Url = $Script:_MoodleUrl
    $Token = $Script:_MoodleToken
    $proxySettings = $Script:_MoodleProxySettings

    if (!$Url -or !$Token) {
        throw "You must call the Connect-Moodle cmdlet before calling any other cmdlets."
    }

    $function = 'core_webservice_get_site_info'
    $path = "webservice/rest/server.php?wstoken=$Token&wsfunction=$function&moodlewsrestformat=json"

    $result  = Invoke-RestMethod -Uri ([uri]::new($Url, $path)) @proxySettings
    New-Object -TypeName MoodleSessionInfo -Property @{
        SiteName = $result.sitename
        SiteUrl = $result.siteurl
        UserId = $result.userid
        UserName = $result.username
        FirstName = $result.firstname
        LastName = $result.lastname
    }
}
