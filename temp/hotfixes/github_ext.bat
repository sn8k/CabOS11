:: main github extention

:: Presentation :
set hotfix_name=GitHub Extention
set hotfix_version=1

:: hotfix welcome message
powershell -command "& {Write-Host '- Loading %hotfix_name% Extention ' -ForegroundColor White}"

:: hotfix content
::if exist "D:\CabOS\temp\updater\CabOS11\launcher.bat" (copy D:\CabOS\temp\updater\CabOS11\launcher.bat D:\CabOS\temp\updater\launcher.bat /Y )

::if exist "D:\CabOS\temp\updater\CabOS11\launcher.cmd" (copy D:\CabOS\temp\updater\CabOS11\Launcher.cmd D:\CabOS\temp\updater\Launcher.cmd /Y )

::if exist "D:\CabOS\temp\updater\CabOS11\launcher.cmd" (copy D:\CabOS\temp\updater\CabOS11\new.fw D:\CabOS\temp\updater\new.fw /Y )

::echo on va dire que ca download.
::echo apres si c'est bon on va afficher un joli OK



:: hotfix end message 

powershell -command "& {Write-Host '- Loaded %hotfix_name% V.%hotfix_version%' -ForegroundColor green}"

:EOF