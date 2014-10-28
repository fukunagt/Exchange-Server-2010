@echo off
PowerShell -File "%ExchangeBin%\RemoteExchange-ECX.ps1"
set ret=%ERRORLEVEL%
echo %0 ret: %ret%
exit %ret%
