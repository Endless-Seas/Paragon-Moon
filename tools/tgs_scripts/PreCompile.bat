@echo off
setlocal
if "%~1"=="" (
    echo Pass the TGS game directory as the first argument.
    exit /b 1
)
set "TG_BOOTSTRAP_CACHE=%~dp0bootstrap"
cd /d "%~1"
if errorlevel 1 exit /b %errorlevel%
set "CBT_BUILD_MODE=TGS"
call tools\build\build.bat
exit /b %errorlevel%
