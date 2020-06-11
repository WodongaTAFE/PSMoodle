class MoodleUserDetails : MoodleUser {
    [string]$IdNumber

    [bool]$Suspended

    [string]$Auth

    [nullable[datetime]]$FirstAccess

    [nullable[datetime]]$LastAccess
}    
