class MoodleUserDetails : MoodleUser {
    [string]$Department

    [string]$IdNumber

    [bool]$Suspended

    [string]$Auth

    [nullable[datetime]]$FirstAccess

    [nullable[datetime]]$LastAccess
}    
