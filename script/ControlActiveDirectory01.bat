@echo off
call SetEnvironment.bat
set MailboxDatabaseName=%1

clpscrpc.exe ControlActiveDirectory02.bat "%CLP_PATH%\bin\clpscrpl.exe"
set ret=%ERRORLEVEL%
echo %0 ret: %ret%
exit %ret%

