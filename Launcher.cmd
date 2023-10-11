@echo off
::Starter 2.0
::
:: Launcher CabOS 11
::
::
::
::
::
::
::
::
::
::

set Version=2.02

::Valeurs numeraires
set Sound_vol=0
set time_upd=30
setlocal EnableDelayedExpansion


::Chemins
set BASE_DIR=D:\CabOS
set SSD_dir=D:\cabOS\temp\uwf_mgr
set X360_ctl=D:\CabOS\Binaries\Xbox360ce\x360ce.exe
set emul_path=E:\DATA_WIN11\CoinOPS Collections.exe
set aria_path=D:\CabOS\binaries\aria
set upd_path=D:\CabOS\temp\updater
set binaries=D:\CabOS\binaries
set fw_temp=D:\CabOS\temp\updater
set hotfixes=D:\CabOS\temp\hotfixes

::Updater settings
set update_url=https://raw.githubusercontent.com/sn8k/CabOS/main/version.run
set runner_url=https://github.com/sn8k/CabOS/raw/main/runner.cmd
set zipped_url=https://github.com/sn8k/CabOS/archive/refs/heads/main.zip


:redirector
if "%1"=="noupdate" ( cls & goto updated )
if "%1"=="?" ( goto :helper )
if "%1"=="help" ( goto :helper )
if "%1"=="protect" ( echo protect >%SSD_dir%\uwfstat.tmp )
if "%1"=="unprotect" ( echo unprotect >%SSD_dir%\uwfstat.tmp )
if "%1"=="debug" ( echo on && set debug=pause )
if "%1"=="update" ( cls & goto updater_compare )

goto step1

:helper
echo CabOS 2.0 Launcher %version%
echo.
echo Arguments :
echo.
echo ? / help : this screen
echo protect : protect overlay
echo unprotect : unprotect overlay
echo update : force update
echo debug : set debug key as pause and disable echo 
echo hotfix : updates hotfixes
echo.
echo (c) YanG Soft
echo.
goto EOF


:step1
:: This part is empty, that's normal
:: it's here only for debugging options ...


:: End of Step 1

:admin_check
:: Demande l'élévation de privilèges administratifs
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotAdmin ) else ( goto getAdmin )
:getAdmin
echo Demande d'élévation de privilèges administratifs...
cd /d %~dp0
powershell -Command "& { Start-Process cmd -ArgumentList '/c %0' -Verb RunAs }"
exit /b
:gotAdmin
echo.
echo Admin rights checked.
echo.

:hotfixes_downloader
::a completer.

:hotfixes_launcher
for %%f in (%hotfixes%\*.bat) do (
    call "%%f"
)


:Serial_gen
for /f "tokens=2 delims=: " %%a in ('ipconfig ^| find "Adresse physique"') do (
    set "mac=%%a"
)

:: Remplace les deux-points par des tirets
set "mac=!mac::=-!"

:: Génère un numéro de série en ajoutant une date/heure
if not exist "d:\CabOS\serial" (
	set "serial=%mac%-!date:~10,4!!date:~7,2!!date:~4,2!!time:~0,2!!time:~3,2!!time:~6,2!"
	echo %serial%>d:\CabOS\serial
	) ELSE (
	set /P "serial=<d:\CabOS\serial
echo.
echo Serial number of this Cabinet: %serial%
echo.

:updater
if not exist "%fw_temp%" ( md "%fw_temp%" )

echo %version%>"%fw_temp%\actual.fw"

Echo Checking if updates are available
echo.
echo Checking %update_url% ....
echo fake loading, will be removed OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOooooooooooooooo
echo.
echo Done. 


:updater_compare
echo comparing version...


if exist "%fw_temp%\actual.fw" (
	set /P version=<"%fw_temp%\actual.fw"
	)
	
if exist "%fw_temp%\new.fw" (
	set /P new_version=<"%fw_temp%\new.fw"
	) ELSE (
	set new_version=not found download error
	)

if exist "%fw_temp%\dummy.txt" ( 
	set version=9.99
	)

if exist "%fw_temp%\dummy.txt" ( 
	set new_version=9.99
	)


echo Actual Version is : %version%
echo last updated Version is : %new_version%
echo.

if "%1"=="update" (set "new_version=forced" & goto updater_process)
if "%version%"=="%new_version%" (goto check_overlay)
if "%version%"=="9.99" (goto check_overlay)
if "%new_version%"=="not found download error" (goto self_test)


:updater_process
echo.
echo i will install Ver. %new_version% over %version%
echo you still can close the windows now before process starts.
echo.
echo.
echo timeout 5 > %fw_temp%\run.cmd
echo copy %base_dir%\launcher.cmd %fw_temp%\launcher-%version%.tmp >> %fw_temp%\run.cmd

echo copy %fw_temp%\launcher.tmp %base_dir%\launcher.cmd  >> %fw_temp%\run.cmd
echo start %BASE_DIR%\launcher.cmd noupdate >> %fw_temp%\run.cmd

timeout 5
start "%fw_temp%\run.cmd"
goto EOF

:updated
cls
Echo this version has been updated to %new_version%
Echo Backing up previous release ...
echo.
copy %fw_temp%\updater %fw_temp%\updater-%DATE% 
rd %fw_temp%\updater /S /Q
echo.
Echo Done
echo.
timeout 3 /NOBREAK
goto step1


:check_overlay

if exist "%SSD_dir%" (uwfmgr volume %uwfstat% c:)
%debug%

:Starting_block
echo Killing Explorer process (for best performance)
echo.

taskkill -im explorer.exe /f
taskkill -im x360ce.exe /f

:audio_part
echo unmuting audio
call "%binaries%\nircmd\nircmd.exe" mutesysvolume %Sound_vol%

:exe_launchers
echo.
echo hello i'm launching exes !
echo.
echo Starting Controllers
::start /MIN "D:\Xbox360ce\X360ce.EXE"
start "" "%binaries%\Xbox360ce\x360ce.exe.lnk"
timeout 5
pause



:relauncher
cls
echo Entering Relauncher mode
echo.
echo You have 5 seconds before relaunch.
echo Close this window will let you use O//S 
echo.
call explorer.exe
timeout 5 /NOBREAK
goto step1



:Self_test
echo.
echo an error occured. Let's run auto-check.
echo.
echo testing overlay
echo.
echo Protected
echo.
echo Unprotected mode test : SFC
sfc /scannow
echo Unprotected mode test : chkdsk
echo chkdsk c: /F
echo Unprotected mode test : ping
echo Unprotected mode test : PING
echo Unprotected mode test : SFC
echo Unprotected mode test : SFC
echo.
echo Self Test OK ... Almost
set selftest=OK
echo.
if "%selftest%"=="OK" (goto Starting_block)

echo.
:EOF