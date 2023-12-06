@echo off

:: External Settings for CabOS
:: Introduced in 2.04 on 12-5-2023
::
:: it's meant to be called by CabOS main script.

:: Version Number
set Version=2.05

:: Audio Volume (values are inverted, 0 is default) 
set Sound_vol=0

:: Time before relaunching update ? in fact, i can't remember what's the use of this setting.
set time_upd=30




:: Paths

:: BASE_DIR is the main folder.
set BASE_DIR=.\
:: SSD_dir is used to check uwfmgr status
set SSD_dir=.\temp\uwf_mgr
:: X360_ctl is where is stored X360CE
set X360_ctl=.\Binaries\Xbox360ce\x360ce.exe
:: emul_path is the exe location of the FrontEnd (usually coinops)
set emul_path=E:\DATA_WIN11\CoinOPS Collections.exe
:: aria_path is where aria is located. it's embedded in binaries folder
set aria_path=.\binaries\aria
:: upd_path is the updater temporary folder
set upd_path=.\temp\updater
:: binaries are 3rd party exe location
set binaries=.\binaries
:: fw_temp is updater working folder.
set fw_temp=.\temp\updater
:: hotfixes folder location.
set hotfixes=.\temp\hotfixes


:: Updater settings

:: If updater_off set to true, updates will disabled.
set updater_off=true

:: Updates URL (usually CaBoS11 github). NOTE : managed by CabOS github Extention
set update_url=https://raw.githubusercontent.com/sn8k/CabOS11/main/Settings/version.run
set runner_url=https://github.com/sn8k/CabOS/raw/main/runner.cmd
set zipped_url=https://github.com/sn8k/CabOS/archive/refs/heads/main.zip

:: hotfixes settings

:: enable or disable hotfixes (default true) // not in use yet.
set use_hotfix=true
