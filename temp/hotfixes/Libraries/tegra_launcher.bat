::echo hotfix : Starting TegraRCM
::start /MIN "" "C:\Program Files (x86)\TegraRcmGUI\tegraRCMGUI.exe"

:: TegraLauncherRCM extention

:: Presentation :
set hotfix_name=TegraRCM Extention
set hotfix_version=1

:: hotfix welcome message
powershell -command "& {Write-Host '- Loading %hotfix_name% Extention ' -ForegroundColor White}"

cd %hotfixes%\TegraRcmGUI_v2.6_portable
start /MIN "" tegra.lnk
::cd %BASE_DIR%


:: hotfix end message 

powershell -command "& {Write-Host '- Loaded %hotfix_name% V.%hotfix_version%' -ForegroundColor green}"

:EOF