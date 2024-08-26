[Diagnostics.CodeAnalysis.SuppressMessageAttribute('TypeNotFound', 'MoodleBadgeType')]
class MoodleBadge {
    [uint] $Id
    [string] $Name
    [string] $Description
    [nullable[datetime]] $TimeCreated
    [nullable[datetime]] $TimeModified
    [uint] $UserCreated
    [uint] $UserModified
    [string] $IssuerName
    [string] $IssuerUrl
    [string] $IssuerContact
    [MoodleBadgeType] $Type
    [nullable[uint]] $CourseId
    [string] $Message
    [string] $MessageSubject
    [string] $UniqueHash
    [nullable[datetime]] $DateIssued
    [nullable[datetime]] $DateExpire
    [bool] $Visible
    [string] $Email
    # Cannot use version or SemVer as Version is a string
    [string] $Version
    [string] $Language
    [string] $BadgeUrl
}
