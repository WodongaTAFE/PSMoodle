class MoodleUserDetails : MoodleUser {
    [string]$Institution
    
    [string]$Department

    [string]$Address

    [string]$IdNumber

    [bool]$Suspended

    [string]$Auth

    [nullable[datetime]]$FirstAccess

    [nullable[datetime]]$LastAccess

    [hashtable]$CustomFields
}    
