@echo off
rem Builds and runs the dying soundscape generator. Output goes to sound/health/.
rem Needs a 64-bit sndfile.dll for Ogg encoding - Audacity's is used by default (pass another folder as an argument to override).
cd /d "%~dp0"
"%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe" /nologo /optimize /platform:x64 /out:"%~dp0dying_audio.exe" "%~dp0Synth.cs" || exit /b 1
"%~dp0dying_audio.exe" "%~dp0..\.." %*
