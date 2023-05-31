# PSMoodle
PowerShell Module for [Moodle](https://moodle.org)

This module contains some helpful cmdlets for managing Moodle users and enrolments.

## Installing

The module can be installed from the [PowerShell Gallery](https://www.powershellgallery.com/packages/Moodle/) from an elevated prompt using this command:

    Install-Module Moodle

## Connect to a Moodle Instance

The first thing you'll need to do is connect to a Moodle instance. We do this with Connect-Moodle, supplying a URL and either credentials or a token.

To have PowerShell ask for a username and password and then connect with those credentials:

    Connect-Moodle -Uri 'https://sandbox.moodledemo.net' -Credential (Get-Credential)

To use an existing Moodle API token:

    Connect-Moodle -Uri 'https://sandbox.moodledemo.net' -Token '<your token here>'

Note: For the module to connect, the user or app token must have access to the `core_webservice_get_site_info` function in your Moodle instance.

## Disconnecting

To ensure the Moodle token is not preserved in your session, you can disconnect from the Moodle instance using this command:

    Disconnect-Moodle

Note that no network connections are maintained that need to be cleaned up with this command. It's only used to clear the locally cached URI and token.

## Cmdlets

Once you're connected, you have a bunch of commands you can use to query and/or update the connected Moodle instance:

* Add-MoodleCohortMember
* Add-MoodleUserRole
* Connect-Moodle
* Copy-MoodleCourse
* Disconnect-Moodle
* Find-MoodleCourse
* Find-MoodleUser
* Get-MoodleCohort
* Get-MoodleCohortMember
* Get-MoodleCourse
* Get-MoodleCourseCategory
* Get-MoodleCurrentSessionInfo
* Get-MoodleEnrolledUser
* Get-MoodleGroup
* Get-MoodleGroupMember
* Get-MoodleUser
* Get-MoodleUserCourse
* New-MoodleCohort
* New-MoodleCourseCategory
* New-MoodleEnrolment
* New-MoodleGroup
* New-MoodleUser
* Remove-MoodleCohort
* Remove-MoodleCohortMember
* Remove-MoodleCourseCategory
* Remove-MoodleEnrolment
* Remove-MoodleGroup
* Remove-MoodleUserRole
* Set-MoodleCohort
* Set-MoodleCourseCategory
* Set-MoodleGroup
* Set-MoodleUser

So if you want to see all the users enrolled courses in the induction category, you can use this command:

    Get-MoodleCourseCategory -Name 'Induction' | Get-MoodleCourse | Get-MoodleEnrolledUser | Sort-Object Id -Unique | Format-Table

If you want to enrol a user into all of those courses, and you know their username, you can do something like this:

    Get-MoodleCourseCategory -Name 'Induction' | Get-MoodleCourse | New-MoodleEnrolment -User (Get-MoodleUser -UserName 'mabster')

And if you want to suspend a user with a given username you can do this:

    Get-MoodleUser -UserName 'mabster' | Set-MoodleUser -Suspended $true

All the commands that update data support a -WhatIf parameter, so you can practise without making any changes, and they're pretty well documented so adding a -? switch to any of them will give you some help.

