@echo off
setlocal ENABLEDELAYEDEXPANSION 

::Starter 2.0
::
:: Launcher CabOS 11
::
:: complete Rewrite of my first CabOS launcher. 
:: cleaner, modulable, and faster.
:: includes an autoupdater
:: An internet connexion is no more required, but it's better to have it activated


:: check if there's an external setting file.
:: the setting must be called "main.cmd" and be placed in the settings folder.




cd /d %~dp0

powershell -command "& {Write-Host -NoNewline 'Check for external settings : ' -ForegroundColor White}"

if exist ".\Settings\main.cmd" (
    powershell -command "& {Write-Host -NoNewline 'Found main.cmd. Using it.' -ForegroundColor Green; [Console]::ResetColor()}"
) ELSE (
    powershell -command "& {Write-Host -NoNewline 'not found, using default settings' -ForegroundColor Red; [Console]::ResetColor()}"
)
Echo.
if not exist ".\settings\" (
    echo settings folder not found. A new installation ?
    Echo.
    echo Creating main folders
    md .\Settings
    md .\Binaries
    md .\temp
    md .\temp\updater
    md .\temp\hotfixes
    md .\temp\uwf_mgr
    echo Folders created.
    pause
    )



if exist ".\settings\main.cmd" ( 
    call ".\settings\main.cmd" 
    goto use_external_settings 
    )


set Version=2.05

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
set updater_off=true
set update_url=https://raw.githubusercontent.com/sn8k/CabOS/main/version.runs
set runner_url=https://github.com/sn8k/CabOS/raw/main/runner.cmd
set zipped_url=https://github.com/sn8k/CabOS/archive/refs/heads/main.zip

:use_external_settings

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
:: it's here only for debugging options if needed.



:: End of Step 1

:admin_check

:: Request admin rights
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotAdmin ) else ( goto getAdmin )

:getAdmin
powershell -command "& {Write-Host -NoNewline 'Request Admin rights : ' -ForegroundColor White}"
powershell -Command "& { Start-Process cmd -ArgumentList '/c %0' -Verb RunAs }"
::exit /b

:gotAdmin

:: We should now have admin rights

::@echo off

(
    powershell -command "& {Write-Host -NoNewline 'ENABLED' -ForegroundColor Green; [Console]::ResetColor()}"
)
Echo.

:hotfixes
:: this whole part will launcher external batch from the hotfixes folder
powershell -command "& {Write-Host 'Checking hotfixes presence : ' -ForegroundColor White}"


:hotfixes_downloader
::a completer.

:hotfixes_launcher

for %%f in (%hotfixes%\*.bat) do (
    call "%%f"
    ) 
    :: a tenter d'activer tot ou tard. '
 ::   ELSE (
 ::   powershell -command "& {Write-Host -NoNewline 'No Hotfixes found ' -ForegroundColor Red}"
 ::    )
pause

:serial
:: this part creates an unique serialNumber. 
:: i will probably use it as licencing option, but for now, it's useless and only there to keep the idea alive.

:Serial_gen


@echo off


for /f "tokens=2 delims=: " %%a in ('ipconfig ^| find "Adresse physique"') do (
    set "mac=%%a"
)

:: Remplace les deux-points par des tirets
:: set "mac=!mac::=-!"

:: Generate a serial number if needed
if not exist ".\Settings\serial.tmp" (
    set serial=%random%-%date%-%random%
    echo %serial%>"%BASE_DIR%\Settings\serial.tmp"
    ) ELSE (
    set /P serial=<"%BASE_DIR%\Settings\serial.tmp"
    )
    
powershell -command "& {Write-Host -NoNewline 'Serial number of this Cabinet: ' -ForegroundColor White}"

if exist ".\Settings\serial.tmp" (
    powershell -command "& {Write-Host -NoNewline '!serial!' -ForegroundColor Green; [Console]::ResetColor()}"
) ELSE (
    powershell -command "& {Write-Host -NoNewline '!serial!' -ForegroundColor Red; [Console]::ResetColor()}"
)

Echo.


:updater
:: CabOS can download its update via github.
:: for advanced download, aria will be a future choice. It's already included in the binaries folder'

:updater_check_update

if not exist "%fw_temp%" ( md "%fw_temp%" )

echo %version%>"%fw_temp%\actual.fw"

Echo Checking if updates are available
echo.
echo Checking %update_url% ....
echo fake loading, will be removed OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOooooooooooooooo
echo.
echo Done. 


:updater_version_compare
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
if "%updater_off%"=="true" (goto updater_off_warning)

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




:updater_off_warning
echo.
Echo WARNING : updater has been disabled in settings.
echo.
goto check_overlay




:check_overlay

if exist "%SSD_dir%" (uwfmgr volume %uwfstat% c:)
%debug%




:Starting_block
echo Killing Explorer process (for best performance)
echo.

taskkill -im explorer.exe /f
taskkill -im x360ce.exe /f




:audio_part
    
powershell -command "& {Write-Host -NoNewline 'Serial number of this Cabinet: ' -ForegroundColor White}"

if exist ".\Settings\serial.tmp" (
    powershell -command "& {Write-Host -NoNewline '!serial!' -ForegroundColor Green; [Console]::ResetColor()}"
) ELSE (
    powershell -command "& {Write-Host -NoNewline '!serial!' -ForegroundColor Red; [Console]::ResetColor()}"
)


echo unmuting audio
call "%binaries%\nircmd\nircmd.exe" mutesysvolume %Sound_vol%


:controller_run
echo.
echo Starting Controllers
:: Starting Xbox360 Controller Emulator

:: note : le start min NE MARCHE PAS, c'est pour ca que j'ai utilis? un raccourci ....
:: start /MIN "D:\Xbox360ce\X360ce.EXE"

start "" "%binaries%\Xbox360ce\x360ce.exe.lnk"


:exe_launcher
echo.
echo hello i'm launching exes !
echo.
pause
cd /D d:\coinops && call "d:\coinops\coins_ops_main.exe"
timeout 5




:relauncher
cls
echo Entering Relauncher mode
echo.
echo You have 10 seconds before relaunch.
echo Close this window will let you use O//S 
echo.
echo If you've just exited coinops, I will relaunch it in 10 seconds. Please Wait.
call explorer.exe
timeout 10 /NOBREAK
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

:Self_test_show

:: this part will show the results of tests.
:: it's here for nothing right now, but i will probably quickly use it !
powershell -command "& {Write-Host -NoNewline 'Testing ... ' -ForegroundColor White}"


if exist "toto.txt" (
    set state=OK
    powershell -command "& {Write-Host -NoNewline '!state!' -ForegroundColor Green; [Console]::ResetColor()}"
) ELSE (
    set state=error
    powershell -command "& {Write-Host -NoNewline '!state!' -ForegroundColor Red; [Console]::ResetColor()}"
)

echo.



powershell -command "& {Write-Host -NoNewline 'Testing ... ' -ForegroundColor White}"

if exist "toto1.txt" (
    set state=OK
    powershell -command "& {Write-Host -NoNewline '!state!' -ForegroundColor Green; [Console]::ResetColor()}"
) ELSE (
    set state=error
    powershell -command "& {Write-Host -NoNewline '!state!' -ForegroundColor Red; [Console]::ResetColor()}"
)

echo.


:EOF