#!/bin/sh
set -eu

BaseDir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$BaseDir/../../dependencies.sh"
Cache=${TG_BOOTSTRAP_CACHE:-$BaseDir/.cache}
case "$(uname -sm)" in
    'Linux x86_64') Platform=bun-linux-x64-baseline ;;
    'Linux aarch64') Platform=bun-linux-aarch64 ;;
    'Darwin arm64') Platform=bun-darwin-aarch64 ;;
    'Darwin x86_64') Platform=bun-darwin-x64 ;;
    MINGW*|MSYS*) exec powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$BaseDir/javascript_.ps1" "$@" ;;
    *) echo 'Unsupported Bun bootstrap platform' >&2; exit 1 ;;
esac
BunDir="$Cache/bun-v$BUN_VERSION-$Platform"
BunExe="$BunDir/$Platform/bun"
if [ ! -x "$BunExe" ]; then
    mkdir -p "$BunDir"
    Release="https://github.com/oven-sh/bun/releases/download/bun-v$BUN_VERSION"
    curl -fsSL "$Release/$Platform.zip" -o "$BunDir/$Platform.zip"
    curl -fsSL "$Release/SHASUMS256.txt" -o "$BunDir/SHASUMS256.txt"
    (
        cd "$BunDir"
        awk -v file="$Platform.zip" '$2 == file { print }' SHASUMS256.txt > selected.sha256
        test -s selected.sha256
        if command -v sha256sum >/dev/null 2>&1; then
            sha256sum --check selected.sha256
        else
            shasum -a 256 --check selected.sha256
        fi
        unzip -oq "$Platform.zip"
    )
fi
test "$("$BunExe" --version)" = "$BUN_VERSION"
export PATH="$(dirname "$BunExe"):$PATH"
echo "Using vendored Bun $BUN_VERSION"
exec "$BunExe" "$@"
