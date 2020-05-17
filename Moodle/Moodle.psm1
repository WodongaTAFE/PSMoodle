# Dot source public/private functions
$PublicTypes = @(Get-ChildItem -Path "$PSScriptRoot\types" -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue)
$PublicFunctions = @(Get-ChildItem -Path "$PSScriptRoot\public" -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue)
$PrivateFunctions = @(Get-ChildItem -Path "$PSScriptRoot\private" -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue)

$AllFunctions = $PublicTypes + $PublicFunctions + $PrivateFunctions
foreach ($Function in $AllFunctions) {
    try {
        . $Function.FullName
    } catch {
        throw ('Unable to dot source {0}' -f $Function.FullName)
    }
}

Export-ModuleMember -Function $PublicFunctions.BaseName
