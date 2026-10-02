param([string] $ByondDirectory)

$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '../..')
$dependencies = @{}
Get-Content dependencies.sh | ForEach-Object {
    if ($_ -match '^export ([A-Z_0-9]+)=(.+)$') {
        $dependencies[$Matches[1]] = $Matches[2].Trim()
    }
}
$version = "$($dependencies.BYOND_MAJOR).$($dependencies.BYOND_MINOR)"
if (!$ByondDirectory) {
    $ByondDirectory = Join-Path $PWD "tools/bootstrap/.cache/byond-$version"
    $compiler = Join-Path $ByondDirectory 'byond/bin/dm.exe'
    if (!(Test-Path -LiteralPath $compiler)) {
        New-Item -ItemType Directory -Path $ByondDirectory -Force | Out-Null
        $archive = Join-Path $ByondDirectory 'byond.zip'
        # The official host can challenge CI runners; the mirror must match the same pinned checksum.
        $downloadUrls = @(
            "https://www.byond.com/download/build/$($dependencies.BYOND_MAJOR)/${version}_byond.zip",
            "https://byond-builds.dm-lang.org/$($dependencies.BYOND_MAJOR)/${version}_byond.zip"
        )
        $downloaded = $false
        foreach ($downloadUrl in $downloadUrls) {
            try {
                Write-Output "Downloading BYOND $version from $downloadUrl"
                Invoke-WebRequest $downloadUrl -OutFile $archive -TimeoutSec 60
                $downloaded = $true
                break
            } catch {
                Write-Warning "Unable to download BYOND from $downloadUrl ($($_.Exception.GetType().Name))."
            }
        }
        if (!$downloaded) {
            throw "Unable to download BYOND $version from the official host or mirror"
        }
        if ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash -ne $dependencies.BYOND_WINDOWS_SHA256) {
            throw 'BYOND archive checksum does not match dependencies.sh'
        }
        Expand-Archive -LiteralPath $archive -DestinationPath $ByondDirectory -Force
    }
}
$env:DM_EXE = Join-Path $ByondDirectory 'byond/bin/dm.exe'
$compilerVersion = & $env:DM_EXE
if ($compilerVersion -notcontains "DM compiler version $version") {
    throw "Expected compiler $version at $env:DM_EXE"
}
Write-Output "Compiler: $env:DM_EXE ($version)"
if ((Get-FileHash -LiteralPath rust_g.dll -Algorithm SHA256).Hash -ne $dependencies.RUST_G_WINDOWS_SHA256) {
    throw 'rust_g.dll does not match the pinned Windows release'
}
if ((Get-Content tgui/package.json -Raw | ConvertFrom-Json).packageManager -ne "bun@$($dependencies.BUN_VERSION)") {
    throw 'Bun declarations disagree'
}
foreach ($entry in @('MIN_COMPILER_VERSION', 'MIN_COMPILER_BUILD')) {
    $expected = if ($entry -eq 'MIN_COMPILER_VERSION') { $dependencies.BYOND_MAJOR } else { $dependencies.BYOND_MINOR }
    if (!(Select-String -LiteralPath code/_compile_options.dm -Pattern "^#define $entry $expected$" -Quiet)) {
        throw "$entry disagrees with dependencies.sh"
    }
}
& tools/build/build.bat --ci build
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
foreach ($artifact in @('roguetown.dmb', 'roguetown.rsc', 'tgui/public/tgui.bundle.js', 'tgui/public/tgui.bundle.css', 'tgui/public/tgui-panel.bundle.js', 'tgui/public/tgui-panel.bundle.css', 'tgui/public/helpers.min.js', 'tgui/public/ntos-error.min.css')) {
    if (!(Test-Path -LiteralPath $artifact) -or (Get-Item -LiteralPath $artifact).Length -eq 0) {
        throw "Missing or empty artifact: $artifact"
    }
}
