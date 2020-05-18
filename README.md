# PSMoodle
PowerShell Module for [Moodle](https://moodle.org)

This module contains some helpful cmdlets for managing Moodle users and enrolments.

## Installing

When the module is released to the PowerShell Gallery, you can install it like this from an elevated prompt:

    Install-Module Moodle

## Connect to a Moodle Instance

The first thing you'll need to do is connect to a Moodle instance. We do this with Connect-Moodle, supplying a URL and either credentials or a token.

To have PowerShell ask for a username and password and then connect with those credentials:

    Connect-Moodle -Uri 'https://sandbox.moodledemo.net' -Credential (Get-Credentials)	

To use an existing Moodle API token:

    Connect-Moodle -Uri 'https://sandbox.moodledemo.net' -Token '<your token here>'

## Cmdlets

Once you're connected, you have a bunch of commands you can use to query and/or update the connected Moodle instance:

* Connect-Moodle
* Disconnect-Moodle
* Get-MoodleCourse
* Get-MoodleCourseCategory
* Get-MoodleCurrentSessionInfo
* Get-MoodleEnrolledUser
* Get-MoodleUser
* Get-MoodleUserCourses
* New-MoodleEnrolment
* New-MoodleUser
* Remove-MoodleEnrolment
* Set-MoodleUser

So if you want to see all the users enrolled courses in the induction category, you can use this command:

    Get-MoodleCourseCategory -Name 'Induction' | Get-MoodleCourse | Get-MoodleEnrolledUser | Sort-Object Id -Unique | Format-Table

If you want to enrol a user into all of those courses, and you know their username, you can do something like this:

    Get-MoodleCourseCategory -Name 'Induction' | Get-MoodleCourse | New-MoodleEnrolment -User (Get-MoodleUser -UserName 'mabster')

And if you want to suspend a user with a given username you can do this:

    Get-MoodleUser -UserName 'mabster' | Set-MoodleUser -Suspended $true

All the commands that update data support a -WhatIf parameter, so you can practice without making any changes, and they're pretty well documented so adding a -? switch to any of them will give you some help.
