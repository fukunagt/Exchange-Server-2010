@echo off
PowerShell .\CheckExchangeServices.ps1
set ret=%ERRORLEVEL%
echo %0 ret: %ret%
exit %ret%
