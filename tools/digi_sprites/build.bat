@echo off
rem Builds dmi.exe (digitigrade sprite generator) with the .NET Framework compiler that ships with Windows.
"%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe" -nologo -O -out:"%~dp0dmi.exe" -r:System.Drawing.dll "%~dp0*.cs"
