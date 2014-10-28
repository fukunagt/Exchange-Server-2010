@echo off
call SetEnvironment.bat

clpscrpc.exe CheckExchangeServices02.bat "%CLP_PATH%\bin\clpscrpl.exe"
set ret=%ERRORLEVEL%
echo %0 ret: %ret%
exit %ret%
