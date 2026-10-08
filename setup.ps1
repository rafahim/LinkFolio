$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root
$SourceFile = Join-Path $Root 'SOURCE-CODE.txt'
if (-not (Test-Path $SourceFile)) {
    throw 'SOURCE-CODE.txt is required to rebuild the project files.'
}
$Source = [System.IO.File]::ReadAllText($SourceFile, [System.Text.Encoding]::UTF8)
$Matches = [regex]::Matches($Source, '(?m)^===FILE: (.+?)===\r?\n')
if ($Matches.Count -eq 0) {
    throw 'No file sections were found in SOURCE-CODE.txt'
}
$Encoding = New-Object System.Text.UTF8Encoding($false)
for ($Index = 0; $Index -lt $Matches.Count; $Index++) {
    $Match = $Matches[$Index]
    $Name = $Match.Groups[1].Value.Trim()
    $Start = $Match.Index + $Match.Length
    if ($Index + 1 -lt $Matches.Count) {
        $End = $Matches[$Index + 1].Index
    } else {
        $End = $Source.Length
    }
    $Content = $Source.Substring($Start, $End - $Start)
    $Target = [System.IO.Path]::GetFullPath((Join-Path $Root $Name))
    if (-not $Target.StartsWith([System.IO.Path]::GetFullPath($Root), [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Unsafe output path: $Name"
    }
    $Parent = Split-Path -Parent $Target
    if (-not (Test-Path $Parent)) {
        New-Item -ItemType Directory -Path $Parent -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($Target, $Content, $Encoding)
}
$ZipPath = Join-Path $Root 'LinkFolio.zip'
$TempZip = Join-Path ([System.IO.Path]::GetTempPath()) ('LinkFolio-' + [guid]::NewGuid().ToString('N') + '.zip')
if (Test-Path $ZipPath) {
    Remove-Item $ZipPath -Force
}
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($Root, $TempZip, [System.IO.Compression.CompressionLevel]::Optimal, $false)
Move-Item $TempZip $ZipPath -Force
Write-Output 'Created or refreshed project files.'
Write-Output 'Created LinkFolio.zip'
