$currentDirectory = Split-Path $MyInvocation.MyCommand.Path
Push-Location $currentDirectory

$insightFonts=".\Insight\Fonts\"

New-Item -ItemType Directory -Force -Path $insightFonts

Get-ChildItem "C:\Windows\Fonts" -Filter *.ttf | where Name -NotMatch lucon.ttf | 
Foreach-Object {
    
    Write-Host $_.FullName
    Copy-Item $_.FullName -Destination $insightFonts
}
