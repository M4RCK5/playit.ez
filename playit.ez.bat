@echo off

pushd "%~dp0"

if /i "%~1"=="-h" call :help & goto :quit
if /i "%~1"=="-d" call :dash & goto :quit
if /i "%~1"=="-b" call :boot & goto :quit
if /i "%~1"=="-s" call :stop & goto :quit

call :workdir || goto :quit
if /i "%~1"=="-f" start "" "%workdir%" & goto :quit

call :stop
if /i "%~1"=="-w" call :wipe & goto :quit
if /i "%~1"=="-r" call :reset & goto :quit

if /i "%~1"=="-u" call :update
call :install

call :playit

:quit
popd
exit /b 0




:: Subroutines

:help
echo.
echo playit.ez is a batch script to quickly setup a playit agent.
echo.
echo Custom workdir: unquoted path in "playit.ez.txt" next to the script.
echo.
echo Launch Parameters:
echo.
echo    -h  Show all launch parameters.
echo    -d  Open web dashboard.
echo    -f  Open playit.ez folder.
echo    -b  Launch after boot.
echo    -s  Stop playit.ez.
echo    -r  Reset playit.ez proxy settings.
echo    -u  Update playit.ez.
echo    -w  Wipe all playit.ez files.
echo.
goto :eof

:dash
start "" "https://playit.gg/login"
goto :eof

:workdir
set "workdir=%systemdrive%\playit.ez"
echo %~n0 | findstr /i "portable" >nul 2>&1 && set "workdir=%~dp0playit.ez"

md "%workdir%" >nul 2>&1
cd /d "%workdir%" >nul 2>&1
if not "%cd%"=="%workdir%" (
	echo.
	echo Error: Please verify workdir.
	timeout /t 5
	exit /b 1
)
goto :eof

:stop
taskkill /t /f /im "playit.exe" >nul 2>&1
timeout /t 2 >nul 2>&1
goto :eof

:wipe
ver>nul
echo.
choice /c yn /n /t 5 /d n /m "You have 5s. to confirm playit.ez uninstall (y/n)... "
if %errorlevel% equ 2 (
	echo.
	echo Uninstall skipped.
) else (
	if exist "%workdir%" rd "%workdir%" /s /q >nul 2>&1
	echo.
	echo playit.ez uninstalled.
)
timeout /t 5
goto :eof

:reset
echo.
echo playit.ez agent reset.
if exist "playit.exe" start "playit.ez" /b "playit.exe" --secret_path ".\playit.toml" reset >nul 2>&1
timeout /t 5
goto :eof

:update
echo.
echo Starting update process...
del /f /q "playit.exe" >nul 2>&1
goto :eof

:install
if not exist "playit.exe" (
	echo.
	echo Downloading playit.ez agent...
	call :dl "https://github.com/playit-cloud/playit-agent/releases/download/v0.17.1/playit-windows-x86_64-signed.exe" "playit.exe"
)
goto :eof

:playit
if exist "playit.exe" (
	start "playit.ez" /min "playit.exe" --secret_path ".\playit.toml" start
)
goto :eof




:: Tools

:dl url output
md "%~dp2" >nul 2>&1
powershell -noprofile -command "$progresspreference = 'silentlycontinue'; invoke-webrequest -uri '%~1' -outfile '%~2'" >nul 2>&1

goto :eof
