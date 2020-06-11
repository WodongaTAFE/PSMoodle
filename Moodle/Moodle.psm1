# Dot source public/private functions
$PublicTypes = @(Get-ChildItem -Path "$PSScriptRoot\types" -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue | Sort-Object FullName)
$PublicFunctions = @(Get-ChildItem -Path "$PSScriptRoot\public" -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue)
$PrivateFunctions = @(Get-ChildItem -Path "$PSScriptRoot\private" -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue)

$AllFunctions = $PublicTypes + $PublicFunctions + $PrivateFunctions
foreach ($Function in $AllFunctions) {
    . $Function.FullName
}

Export-ModuleMember -Function $PublicFunctions.BaseName
