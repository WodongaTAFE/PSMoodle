class MoodleUser {
    [int]$Id

    [string]$UserName

    [string]$FirstName

    [string]$LastName

    [string]$Email
}

class MoodleUserDetails : MoodleUser {
    [string]$IdNumber

    [bool]$Suspended

    [string]$Auth

    [nullable[datetime]]$FirstAccess

    [nullable[datetime]]$LastAccess
}    
