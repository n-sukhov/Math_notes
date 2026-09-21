$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$buildDir = Join-Path $projectRoot "build"
$xelatexCommand = Get-Command "xelatex" -ErrorAction SilentlyContinue

if ($xelatexCommand) {
    $xelatexExe = $xelatexCommand.Source
}
else {
    $xelatexExe = "C:\Program Files\MiKTeX\miktex\bin\x64\xelatex.exe"
    if (-not (Test-Path -LiteralPath $xelatexExe)) {
        throw "xelatex was not found. Restart the terminal after installing MiKTeX."
    }
}

New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
Push-Location $projectRoot

try {
    $xelatexArgs = @(
        "--enable-installer"
        "--aux-directory=$buildDir"
        "-interaction=nonstopmode"
        "-file-line-error"
        "main.tex"
    )

    foreach ($pass in 1..2) {
        Write-Host "XeLaTeX: pass $pass of 2"
        & $xelatexExe @xelatexArgs

        if ($LASTEXITCODE -ne 0) {
            throw "XeLaTeX failed with exit code $LASTEXITCODE. See build/main.log."
        }
    }

    $generatedPdf = Join-Path $projectRoot "math_analysis_notes_Zorich.pdf"
    $finalPdf = Join-Path $projectRoot "main.pdf"
    Copy-Item -LiteralPath $generatedPdf -Destination $finalPdf -Force

    Write-Host "Done: $projectRoot\main.pdf"
    Write-Host "Auxiliary files: $buildDir"
}
finally {
    Pop-Location
}
