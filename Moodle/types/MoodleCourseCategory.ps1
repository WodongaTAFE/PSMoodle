[Diagnostics.CodeAnalysis.SuppressMessageAttribute('TypeNotFound', 'MoodleDescriptionFormat')]
class MoodleCourseCategory {
    [int]$Id

    [string]$Name

    [string]$IdNumber

    [string]$Description

    [MoodleDescriptionFormat]$DescriptionFormat

    [int]$Parent

    [bool]$Visible
}
