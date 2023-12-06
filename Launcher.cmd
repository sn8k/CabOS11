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


if "%1"=="" (goto getAdmin) ELSE (goto redirector)

cd /d %~dp0


:startup
:: Warming up machine ... 
:: BatchGotAdmin
:getAdmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------    



:startup_standalone_version_set
:: Tentes de recuperer la version si elle est bien presente
if exist ".\Settings\version.cmd" (set /P version=<".\Settings\version.cmd") ELSE (set version=uninstalled)

:startup_settings
:: loads external files (main.cmd)

powershell -command "& {Write-Host -NoNewline 'Check for external settings : ' -ForegroundColor White}"

if exist ".\Settings\main.cmd" (
    powershell -command "& {Write-Host 'Found main.cmd. Using it.' -ForegroundColor Green; [Console]::ResetColor()}"
) ELSE (
    powershell -command "& {Write-Host 'not found, using default settings' -ForegroundColor Red; [Console]::ResetColor()}"
)


:startup_folder_test
powershell -command "& {Write-Host -NoNewline 'Check folders presence : ' -ForegroundColor White}"
if exist ".\Settings" (
    powershell -command "& {Write-Host  'Found folders' -ForegroundColor Green; [Console]::ResetColor()}"
) ELSE (
    powershell -command "& {Write-Host  'settings folder not found. A new installation ?' -ForegroundColor Red; [Console]::ResetColor()}"
)



if not exist ".\settings\" (
    Echo.
    echo Creating main folders
    md .\Settings
    md .\Binaries
    md .\temp
    md .\temp\updater
    md .\temp\hotfixes
    md .\temp\uwf_mgr
    echo Folders created.
    echo retrying ...
    goto startup_folder_test
    )



if exist ".\settings\main.cmd" ( 
    call ".\settings\main.cmd" 
    goto step1
    ) ELSE (goto ini_generate)

:ini_generate
:: these are default value
:: from here, a default main.cmd is generated
echo :: generated on %date% > .\Settings\main.cmd
echo :: reason : no main.cmd found >> .\Settings\main.cmd

echo set Sound_vol=0>> .\Settings\main.cmd
echo set time_upd=30>> .\Settings\main.cmd
echo set BASE_DIR=%cd%>> .\Settings\main.cmd
echo set SymLink_Path=C:\Launcher>> .\Settings\main.cmd
echo set SSD_dir=%BASE_DIR%\temp\uwf_mgr>> .\Settings\main.cmd
echo set X360_ctl=%BASE_DIR%\Binaries\Xbox360ce\x360ce.exe>> .\Settings\main.cmd
echo set emul_path=E:\DATA_WIN11\CoinOPS Collections.exe>> .\Settings\main.cmd
echo set aria_path=%BASE_DIR%\binaries\aria2>> .\Settings\main.cmd
echo set upd_path=%BASE_DIR%\temp\updater>> .\Settings\main.cmd
echo set binaries=%BASE_DIR%\binaries>> .\Settings\main.cmd
echo set hotfixes=%BASE_DIR%\temp\hotfixes>> .\Settings\main.cmd
echo set updater_off=true>> .\Settings\main.cmd
echo set update_url=https://github.com/sn8k/CabOS11/zipball/master/ >> .\Settings\main.cmd
echo set runner_url=https://github.com/sn8k/CabOS/raw/main/runner.cmd >> .\Settings\main.cmd

if exist ".\Settings\main.cmd" (
    echo Settings file generated.
    echo Reloading CabOS. Please Wait.
    goto startup_settings
    ) ELSE (
    echo ERROR WRITING MAIN.CMD. CHECK FOLDERS 
    goto EOF
    )


:use_external_settings

:serial
:: this part creates an unique serialNumber. 
:: i will probably use it as licencing option, but for now, it's useless and only there to keep the idea alive.

:Serial_gen

:: a refaire plus tard : prise en charge de l'adresse mac pour generer un SN
:: for /f "tokens=2 delims=: " %%a in ('ipconfig ^| find "Adresse physique"') do (
::    set "mac=%%a"
:: )
:: Remplace les deux-points par des tirets
:: set "mac=!mac::=-!"

:: Generate a serial number if needed
if not exist "%BASE_DIR%\Settings\serial.tmp" (
    set serial=ARC10-%random%-%random%
    ) ELSE (
    set /P serial=<"%BASE_DIR%\Settings\serial.tmp"
    )


:: showing SN. Green if there were already a serial, red if it has been generated.
    powershell -command "& {Write-Host -NoNewline 'Serial number of this Cabinet: ' -ForegroundColor White}"

if exist ".\Settings\serial.tmp" (
    powershell -command "& {Write-Host '!serial!' -ForegroundColor Green; [Console]::ResetColor()}"
) ELSE (
    powershell -command "& {Write-Host '!serial!' -ForegroundColor Red; [Console]::ResetColor()}"
)

:: write serial in file. 
:: IT MUST BE PLACED here, else it might lead to an (unimportant) error "echo is deactivated" instead of the serial/
    echo %serial% >"%BASE_DIR%\Settings\serial.tmp"
    
    
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
::NET FILE 1>NUL 2>NUL
::if '%errorlevel%' == '0' ( goto gotAdmin ) else ( goto getAdmin )

::getAdmin
::powershell -command "& {Write-Host -NoNewline 'Request Admin rights : ' -ForegroundColor White}"
::powershell -Command "& { Start-Process cmd -ArgumentList '/c %0' -Verb RunAs }"
::exit /b

::gotAdmin

:: We should now have admin rights



::(
::    powershell -command "& {Write-Host 'ENABLED' -ForegroundColor Green; [Console]::ResetColor()}"::
::)


:check_mklink
if not exist "%SymLink_Path%" (goto check_mklink_create) ELSE (goto audio_part)

:check_mklink_create
mklink /D %SymLink_Path% %BASE_DIR% 

:check_mklink_present
if exist "%SymLink_Path%" (
    echo SymLink OK
    echo clearing config file
    ren %BASE_DIR%\Settings\main.cmd main.install
    Echo.
    echo relaunching from C
    cd /D %symlink_path%
    start "" %symlink_path%\launcher.cmd
    exit /b
    ) 
    
:audio_part
    
powershell -command "& {Write-Host -NoNewline 'Unmuting audio : ' -ForegroundColor White}"

if exist "%binaries%\nircmd\nircmd.exe" (
    call "%binaries%\nircmd\nircmd.exe" mutesysvolume %Sound_vol%
    powershell -command "& {Write-Host  'OK' -ForegroundColor Green; [Console]::ResetColor()}"
) ELSE (
    powershell -command "& {Write-Host  'ERROR' -ForegroundColor Red; [Console]::ResetColor()}"
)

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


:updater
:: CabOS can download its update via github.
:: for advanced download, aria will be a future choice. It's already included in the binaries folder'

:updater_check_update

if not exist "%upd_path%" ( md "%upd_path%" )

echo %version%>"%upd_path%\actual.fw"

powershell -command "& {Write-Host -NoNewline 'Checking for updates : ' -ForegroundColor White}"
if exist (%upd_path%\)

powershell -command "& {Write-Host -NoNewline 'Done ' -ForegroundColor Green}"

:updater_version_compare
powershell -command "& {Write-Host -NoNewline 'comparing version : ' -ForegroundColor White}" 


if exist "%upd_path%\actual.fw" (
    set /P version=<"%upd_path%\actual.fw"
    )
    
if exist "%upd_path%\new.fw" (
    set /P new_version=<"%upd_path%\new.fw"
    ) ELSE (
    set new_version=not found download error
    )

if exist "%upd_path%\dummy.txt" ( 
    set version=9.99
    )

if exist "%upd_path%\dummy.txt" ( 
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
echo timeout 5 > %upd_path%\run.cmd
echo copy %base_dir%\launcher.cmd %upd_path%\launcher-%version%.tmp >> %upd_path%\run.cmd

echo copy %upd_path%\launcher.tmp %base_dir%\launcher.cmd  >> %upd_path%\run.cmd
echo start %BASE_DIR%\launcher.cmd noupdate >> %upd_path%\run.cmd

timeout 5
start "%upd_path%\run.cmd"
goto EOF




:updated
cls
Echo this version has been updated to %new_version%
Echo Backing up previous release ...
echo.
copy %upd_path%\updater %upd_path%\updater-%DATE% 
rd %upd_path%\updater /S /Q
echo.
Echo Done
echo.
timeout 3 /NOBREAK
goto step1


:updater_rework
if exist "%upd_path%\main_orig.cmd" (
    fc "%upd_path%\main_orig.cmd" 
    del "%upd_path%\lastest.zip" /Y
    )


if exist "%upd_path%\lastest.zip" (
    %zipit% "%upd_path%\lastest.zip" 
    del "%upd_path%\lastest.zip" /Y
    )

:updater_off_warning
echo.
Echo WARNING : updater has been disabled in settings.
echo.
goto check_overlay




:check_overlay

if exist "%SSD_dir%" (uwfmgr volume %uwfstat% c:)
%debug%




:Starting_block
powershell -command "& {Write-Host -NoNewline 'Closing Explorer : ' -ForegroundColor White}"
 (
    START /wait taskkill -im explorer.exe /f
START /wait taskkill -im x360ce.exe /f

powershell -command "& {Write-Host 'Done' -ForegroundColor Green; [Console]::ResetColor()}"
)






pause
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


:redirector
if "%1"=="noupdate" ( cls & goto updated )
if "%1"=="?" ( goto :helper )
if "%1"=="help" ( goto :helper )
if "%1"=="protect" ( echo protect >%SSD_dir%\uwfstat.tmp )
if "%1"=="unprotect" ( echo unprotect >%SSD_dir%\uwfstat.tmp )
if "%1"=="debug" ( echo on && set debug=pause )
if "%1"=="update" ( cls & goto updater_compare )

:EOF