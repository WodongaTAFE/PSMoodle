class MoodleCohort {
    [int]$Id

    [string]$Name

    [string]$Description

    [MoodleDescriptionFormat]$DescriptionFormat

    [string]$IdNumber

    [bool]$Visible

    [string]$Theme
}

enum MoodleDescriptionFormat {
    Moodle = 0;
    HTML = 1;
    Plain = 2;
    Markdown = 4;
}
