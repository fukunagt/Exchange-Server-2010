@echo off
call SetEnvironment.bat
set MailboxDatabaseName=%1
set DatabaseControl=%2

clpscrpc.exe ControlMailboxDatabase02.bat "%CLP_PATH%\bin\clpscrpl.exe"
set ret=%ERRORLEVEL%
echo %0 ret: %ret%
exit %ret%
