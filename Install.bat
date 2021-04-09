@echo off
color 1f
::Self elevate without PowerShell (by Matt)
:init
setlocal DisableDelayedExpansion
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion
:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )
:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
echo Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
echo args = "ELEV " >> "%vbsGetPrivileges%"
echo For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
echo args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
echo Next >> "%vbsGetPrivileges%"
echo UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
"%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%" %*
exit /B
:gotPrivileges
setlocal & pushd .
cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)
title EzWindSLIC by Exe Csrss
echo EzWindSLIC by Exe Csrss
setlocal EnableDelayedExpansion
:: Declare some variables for convenience
set "_csc=%systemroot%\System32\cscript.exe //nologo"
set "_slm=%_csc% %systemroot%\System32\slmgr.vbs"
set "_nul=1>nul 2>nul"
set "_eline=color 4f & echo ==========ERROR=========="
set "_bcd=%systemroot%\System32\bcdedit.exe"
set "_pak=echo Press any key to exit... & pause %_nul% & cd /d %systemroot% & mountvol %_ltr% /d %_nul% & exit /b 0"
set "_pakerr=echo Press any key to exit... & pause %_nul% & cd /d %systemroot% & mountvol %_ltr% /d %_nul% & exit /b 1"
set "_wmi=%systemroot%\System32\wbem\wmic.exe"
set "_reb=%systemroot%\System32\shutdown.exe -r -t 00 %_nul%"
:: Some variables to control this script
REM CustomKey=XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
REM CustomLtr=X:
REM UseCustomSLICandCert=0





:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::Normally there is no need to change anything below this comment::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::






:: Check for occupied drive letters (original idea)
for %%# in (Q W E R T Y U I O P A S D F G H J K L Z X C V B N M) do (
mountvol /? | find /i "%%#:\" %_nul% || set _ltr=%%#:
)
if defined CustomLtr set _ltr=%CustomLtr%
:: Check for existence of 'bin' folder
if not exist "%~dp0bin" (
%_eline%
echo The 'bin' folder was not found in the current location.
echo Most likely, you started this script directly from your ZIP archiver instead of extracting.
echo Extract the entire archive to a temporary folder and run the script from there.
%_pakerr%
)
if defined UseCustomSLICandCert if not defined CustomKey (
%_eline%
echo You must provide a custom key to use a custom SLIC and certificate.
%_pakerr%
)
:: Check OS architecture
for /f "tokens=2 delims==" %%G in ('%_wmi% os get OSArchitecture /format:value') do set _bitness=%%G
if /i %_bitness% NEQ 64-bit (
%_eline%
echo Unsupported OS architecture.
echo WindSLIC only works on AMD64 systems.
%_pakerr%
)
:: Check if system is actually EFI
%_bcd% /enum {current} | find /i ".efi" %_nul% || (
%_eline%
echo This computer's firmware is either not UEFI, or the OS is booted in legacy mode.
%_pakerr%
)
:: Check if there is an unoccupied drive letter
if not defined _ltr (
%_eline%
echo No unoccupied drive letter.
echo A free drive letter is required to mount the EFI System Partition.
%_pakerr%
)
:: Check for permanent activation
%_wmi% path SoftwareLicensingProduct where (LicenseStatus='1' and GracePeriodRemaining='0' and PartialProductKey is NOT NULL) get Name 2>nul | find /i "Windows" %_nul% && (
color 2f
echo Windows is already permanently activated.
echo Press any key to install WindSLIC...
pause >nul
)
:: Detect OS version
for /f "tokens=4,5 delims=[]. " %%G in ('ver') do set osver=%%G.%%H
if %osver% NEQ 6.0 if %osver% NEQ 6.1 (
%_eline%
echo Your OS version is not supported. Please use alternative activation exploits.
%_pakerr%
)
:: Detect OS type
(for /f "tokens=2* skip=2" %%G in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "InstallationType"') do set ostype=%%H) %_nul%
:: Detect OS edition
for /f "tokens=2* skip=2" %%G in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "EditionID"') do set osedition=%%H
:: NT 6.0 doesn't have InstallationType registry value
if not defined ostype (
echo %osedition% | find "Server" %_nul% && set ostype=Server
if not defined ostype set ostype=Client
)
:: Detect OS name
if /i %osver% EQU 6.0 if /i %ostype% EQU Client if /i %osedition% EQU Starter set "fullosname=Windows Vista Starter"
if /i %osver% EQU 6.0 if /i %ostype% EQU Client if /i %osedition% EQU HomeBasic set "fullosname=Windows Vista Home Basic"
if /i %osver% EQU 6.0 if /i %ostype% EQU Client if /i %osedition% EQU HomeBasicN set "fullosname=Windows Vista Home Basic N"
if /i %osver% EQU 6.0 if /i %ostype% EQU Client if /i %osedition% EQU HomePremium set "fullosname=Windows Vista Home Premium"
if /i %osver% EQU 6.0 if /i %ostype% EQU Client if /i %osedition% EQU Business set "fullosname=Windows Vista Business"
if /i %osver% EQU 6.0 if /i %ostype% EQU Client if /i %osedition% EQU BusinessN set "fullosname=Windows Vista Business N"
if /i %osver% EQU 6.0 if /i %ostype% EQU Client if /i %osedition% EQU Ultimate set "fullosname=Windows Vista Ultimate"
if /i %osver% EQU 6.0 if /i %ostype% EQU Server if /i %osedition% EQU ServerSBSPrime set "fullosname=Windows Server 2008 Foundation"
if /i %osver% EQU 6.0 if /i %ostype% EQU Server if /i %osedition% EQU ServerStandard set "fullosname=Windows Server 2008 Standard"
if /i %osver% EQU 6.0 if /i %ostype% EQU Server if /i %osedition% EQU ServerEnterprise set "fullosname=Windows Server 2008 Enterprise"
if /i %osver% EQU 6.0 if /i %ostype% EQU Server if /i %osedition% EQU ServerEnterpriseV set "fullosname=Windows Server 2008 Enterprise without Hyper-V"
if /i %osver% EQU 6.0 if /i %ostype% EQU Server if /i %osedition% EQU ServerSBSStandard set "fullosname=Windows Small Business Server 2008 Standard"
if /i %osver% EQU 6.0 if /i %ostype% EQU Server if /i %osedition% EQU ServerStorageStandard set "fullosname=Windows Storage Server 2008 Standard"
if /i %osver% EQU 6.1 if /i %ostype% EQU Client if /i %osedition% EQU Starter set "fullosname=Windows 7 Starter"
if /i %osver% EQU 6.1 if /i %ostype% EQU Client if /i %osedition% EQU StarterE set "fullosname=Windows 7 Starter E"
if /i %osver% EQU 6.1 if /i %ostype% EQU Client if /i %osedition% EQU HomeBasic set "fullosname=Windows 7 Home Basic"
if /i %osver% EQU 6.1 if /i %ostype% EQU Client if /i %osedition% EQU HomePremium set "fullosname=Windows 7 Home Premium"
if /i %osver% EQU 6.1 if /i %ostype% EQU Client if /i %osedition% EQU HomePremiumE set "fullosname=Windows 7 Home Premium E"
if /i %osver% EQU 6.1 if /i %ostype% EQU Client if /i %osedition% EQU Professional set "fullosname=Windows 7 Professional"
if /i %osver% EQU 6.1 if /i %ostype% EQU Client if /i %osedition% EQU ProfessionalE set "fullosname=Windows 7 Professional E"
if /i %osver% EQU 6.1 if /i %ostype% EQU Client if /i %osedition% EQU Ultimate set "fullosname=Windows 7 Ultimate"
if /i %osver% EQU 6.1 if /i %ostype% EQU Client if /i %osedition% EQU UltimateE set "fullosname=Windows 7 Ultimate E"
if /i %osver% EQU 6.1 if /i %ostype% EQU Server if /i %osedition% EQU ServerWinFoundation set "fullosname=Windows Server 2008 R2 Foundation"
if /i %osver% EQU 6.1 if /i %ostype% EQU Server if /i %osedition% EQU ServerWeb set "fullosname=Windows Server 2008 R2 Web"
if /i %osver% EQU 6.1 if /i %ostype% EQU Server if /i %osedition% EQU ServerStandard set "fullosname=Windows Server 2008 R2 Standard"
if /i %osver% EQU 6.1 if /i %ostype% EQU Server if /i %osedition% EQU ServerEnterprise set "fullosname=Windows Server 2008 R2 Enterprise"
if /i %osver% EQU 6.1 if /i %ostype% EQU Server if /i %osedition% EQU ServerDatacenter set "fullosname=Windows Server 2008 R2 Datacenter"
if /i %osver% EQU 6.1 if /i %ostype% EQU Server if /i %osedition% EQU ServerHomeStandard set "fullosname=Windows Storage Server 2008 R2 Essentials"
if /i %osver% EQU 6.1 if /i %ostype% EQU Server if /i %osedition% EQU ServerSolution set "fullosname=Windows Small Business Server 2011 Essentials"
if /i %osver% EQU 6.1 if /i %ostype% EQU Server if /i %osedition% EQU ServerSBSStandard set "fullosname=Windows Small Business Server 2011 Standard"
if /i %osver% EQU 6.1 if /i %ostype% EQU Server if /i %osedition% EQU ServerHomePremium set "fullosname=Windows Home Server 2011"
echo OS version: %osver%
echo OS type: %ostype%
echo OS edition: %osedition%
if defined fullosname echo OS name: %fullosname%
echo Mounting EFI System Partition to: %_ltr%...
mountvol %_ltr% /s
if not exist %_ltr%\EFI (
%_eline%
echo An error occured while mounting the EFI system partition.
%_pakerr%
)
del "%temp%\key.txt" %_nul%
echo EFI System Partition successfully mounted at %_ltr%.
echo Checking if WindSLIC is already installed...
if exist %_ltr%\EFI\WindSLIC (
echo WindSLIC is already installed.
%_pak%
)
echo WindSLIC not currently installed.
if defined UseCustomSLICandCert (
set slic=custom
goto skipslicprompt
)
echo [1] Acer
echo [2] Alienware
echo [3] Asus
echo [4] Dell
echo [5] Gigabyte
echo [6] HP
echo [7] Lenovo
echo [8] MSI
echo [9] Sony
echo [A] Toshiba
choice /c 123456789a /m "Which SLIC profile would you like to install "
set prof=%errorlevel%
if %prof% EQU 1 set slic=Acer
if %prof% EQU 2 set slic=Alienware
if %prof% EQU 3 set slic=Asus
if %prof% EQU 4 set slic=Dell
if %prof% EQU 5 set slic=Gigabyte
if %prof% EQU 6 set slic=HP
if %prof% EQU 7 set slic=Lenovo
if %prof% EQU 8 set slic=MSI
if %prof% EQU 9 set slic=Sony
if %prof% EQU 10 set slic=Toshiba
:skipslicprompt
if not exist "%~dp0bin\%slic%\slic.BIN" (
echo slic.BIN doesn't exist, make sure all files are intact, and run this again.
echo Press any key to exit...
pause >nul
exit
)
if not exist "%~dp0bin\%slic%\%slic%.XRM-MS" (
echo Certificate doesn't exist, make sure all files are intact, and run this again.
echo Press any key to exit...
pause >nul
exit
)
:: Decide product key to be installed (inspiration from @Windows_Addict's MAS, keys by @Freestyler)
for %%# in (
Acer:6.0:Client:Starter:26VQB-RP3T9-63FVV-VD7RF-H7M2Q
Alienware:6.0:Client:Starter:26VQB-RP3T9-63FVV-VD7RF-H7M2Q
Asus:6.0:Client:Starter:26VQB-RP3T9-63FVV-VD7RF-H7M2Q
Dell:6.0:Client:Starter:26VQB-RP3T9-63FVV-VD7RF-H7M2Q
Gigabyte:6.0:Client:Starter:26VQB-RP3T9-63FVV-VD7RF-H7M2Q
HP:6.0:Client:Starter:223JH-DDMFR-3WBTR-H3V93-28JK8
Lenovo:6.0:Client:Starter:23Q4W-YQPHY-TY89Y-7Q3VX-W72KT
MSI:6.0:Client:Starter:23Q4W-YQPHY-TY89Y-7Q3VX-W72KT
Sony:6.0:Client:Starter:23Q4W-YQPHY-TY89Y-7Q3VX-W72KT
Toshiba:6.0:Client:Starter:23Q4W-YQPHY-TY89Y-7Q3VX-W72KT
Acer:6.0:Client:HomeBasic:2W7FD-9DWCB-Q9CM8-KTDKK-8QXTR
Alienware:6.0:Client:HomeBasic:2W7FD-9DWCB-Q9CM8-KTDKK-8QXTR
Asus:6.0:Client:HomeBasic:762HW-QD98X-TQVXJ-8RKRQ-RJC9V
Dell:6.0:Client:HomeBasic:3YMR2-WMV49-4WD8X-M9WM7-CH4CG
Gigabyte:6.0:Client:HomeBasic:889T3-F4VGX-QK4V7-JH76R-3HHRC
HP:6.0:Client:HomeBasic:2VX48-BVXT6-GD2PK-BD3R2-44MV3
Lenovo:6.0:Client:HomeBasic:2WP98-KHTH2-KC7KG-4YR37-H8PHC
MSI:6.0:Client:HomeBasic:2WP98-KHTH2-KC7KG-4YR37-H8PHC
Sony:6.0:Client:HomeBasic:4DWY4-M6VH9-Y6FX6-D2H3V-3PXM9
Toshiba:6.0:Client:HomeBasic:4DV48-MFJR8-VRW92-3VTYM-HBTPB
Acer:6.0:Client:HomeBasicN:22TC9-RDMDD-VXMXD-2XM2Y-DT6FX
Alienware:6.0:Client:HomeBasicN:22TC9-RDMDD-VXMXD-2XM2Y-DT6FX
Asus:6.0:Client:HomeBasicN:22TC9-RDMDD-VXMXD-2XM2Y-DT6FX
Dell:6.0:Client:HomeBasicN:22TC9-RDMDD-VXMXD-2XM2Y-DT6FX
Gigabyte:6.0:Client:HomeBasicN:22TC9-RDMDD-VXMXD-2XM2Y-DT6FX
HP:6.0:Client:HomeBasicN:22TC9-RDMDD-VXMXD-2XM2Y-DT6FX
Lenovo:6.0:Client:HomeBasicN:22TC9-RDMDD-VXMXD-2XM2Y-DT6FX
MSI:6.0:Client:HomeBasicN:22TC9-RDMDD-VXMXD-2XM2Y-DT6FX
Sony:6.0:Client:HomeBasicN:22TC9-RDMDD-VXMXD-2XM2Y-DT6FX
Toshiba:6.0:Client:HomeBasicN:22TC9-RDMDD-VXMXD-2XM2Y-DT6FX
Acer:6.0:Client:HomePremium:2TYBW-XKCQM-XY9X3-JDXYP-6CJ97
Alienware:6.0:Client:HomePremium:D9CRD-R8YYQ-VYG3W-YG4FK-2CXRF
Asus:6.0:Client:HomePremium:8XPM9-7F9HD-4JJQP-TP64Y-RPFFV
Dell:6.0:Client:HomePremium:4GPTT-6RYC4-F4GJK-KG77H-B9HD2
Gigabyte:6.0:Client:HomePremium:8XPM9-7F9HD-4JJQP-TP64Y-RPFFV
HP:6.0:Client:HomePremium:2R6WF-KYF88-27HYQ-XTKW2-WQD8Q
Lenovo:6.0:Client:HomePremium:34BKK-QK76Y-WWR7C-QF2M7-2TB37
MSI:6.0:Client:HomePremium:86C2J-2M84W-HBMRQ-GBJWJ-VPTRM
Sony:6.0:Client:HomePremium:6JWV3-843DD-4GV68-6D8JB-G6MF9
Toshiba:6.0:Client:HomePremium:6DG3Y-99KMR-JQMWD-2QJRJ-RJ34F
Acer:6.0:Client:Business:2TJTJ-C72D7-7BCYH-FV3HT-JGD4F
Alienware:6.0:Client:Business:2TJTJ-C72D7-7BCYH-FV3HT-JGD4F
Asus:6.0:Client:Business:2TJTJ-C72D7-7BCYH-FV3HT-JGD4F
Dell:6.0:Client:Business:368Y7-49YMQ-VRCTY-3V3RH-WRMG7
Gigabyte:6.0:Client:Business:368Y7-49YMQ-VRCTY-3V3RH-WRMG7
HP:6.0:Client:Business:2Q2WM-VCB98-8C6BG-C9BT2-3XDRY
Lenovo:6.0:Client:Business:2YRV9-YCY3F-FRJ4T-BKD6B-C47PP
MSI:6.0:Client:Business:2X4F8-Y4QGK-Y8RTT-CK6PB-M8X92
Sony:6.0:Client:Business:3W2Y2-GRRYB-VH76X-KPDXX-XFJ4B
Toshiba:6.0:Client:Business:38MK6-4QYC6-GJQQX-9DYQ4-H9MQD
Acer:6.0:Client:BusinessN:2434H-HFRM7-BHGD4-W9TTD-RJVCH
Alienware:6.0:Client:BusinessN:2434H-HFRM7-BHGD4-W9TTD-RJVCH
Asus:6.0:Client:BusinessN:2434H-HFRM7-BHGD4-W9TTD-RJVCH
Dell:6.0:Client:BusinessN:2434H-HFRM7-BHGD4-W9TTD-RJVCH
Gigabyte:6.0:Client:BusinessN:2434H-HFRM7-BHGD4-W9TTD-RJVCH
HP:6.0:Client:BusinessN:2434H-HFRM7-BHGD4-W9TTD-RJVCH
Lenovo:6.0:Client:BusinessN:2434H-HFRM7-BHGD4-W9TTD-RJVCH
MSI:6.0:Client:BusinessN:2434H-HFRM7-BHGD4-W9TTD-RJVCH
Sony:6.0:Client:BusinessN:2434H-HFRM7-BHGD4-W9TTD-RJVCH
Toshiba:6.0:Client:BusinessN:2434H-HFRM7-BHGD4-W9TTD-RJVCH
Acer:6.0:Client:Ultimate:3YDB8-YY3P4-G7FCW-GJMPG-VK48C
Alienware:6.0:Client:Ultimate:7QVFM-MF2DT-WXJ62-XTYX3-P9YTT
Asus:6.0:Client:Ultimate:6F2D7-2PCG6-YQQTB-FWK9V-932CC
Dell:6.0:Client:Ultimate:2QBP3-289MF-9364X-37XGX-24W6P
Gigabyte:6.0:Client:Ultimate:2QBP3-289MF-9364X-37XGX-24W6P
HP:6.0:Client:Ultimate:23CM9-P7MYR-VFWRT-JGH7R-R933G
Lenovo:6.0:Client:Ultimate:24J6Q-YJJBG-V4K4Q-2J8HY-8HBQQ
MSI:6.0:Client:Ultimate:24J6Q-YJJBG-V4K4Q-2J8HY-8HBQQ
Sony:6.0:Client:Ultimate:2KKTK-YGJKV-3WMRR-3MDQW-TJP47
Toshiba:6.0:Client:Ultimate:33G3W-JY3XQ-CQQ7C-TG96R-R6J6Q
Acer:6.0:Server:ServerSBSPrime:MR7KP-M4YKK-6R4BM-RVG79-R874J
Alienware:6.0:Server:ServerSBSPrime:MR7KP-M4YKK-6R4BM-RVG79-R874J
Asus:6.0:Server:ServerSBSPrime:MR7KP-M4YKK-6R4BM-RVG79-R874J
Dell:6.0:Server:ServerSBSPrime:MR7KP-M4YKK-6R4BM-RVG79-R874J
Gigabyte:6.0:Server:ServerSBSPrime:MR7KP-M4YKK-6R4BM-RVG79-R874J
HP:6.0:Server:ServerSBSPrime:MR7KP-M4YKK-6R4BM-RVG79-R874J
Lenovo:6.0:Server:ServerSBSPrime:MR7KP-M4YKK-6R4BM-RVG79-R874J
MSI:6.0:Server:ServerSBSPrime:MR7KP-M4YKK-6R4BM-RVG79-R874J
Sony:6.0:Server:ServerSBSPrime:MR7KP-M4YKK-6R4BM-RVG79-R874J
Toshiba:6.0:Server:ServerSBSPrime:MR7KP-M4YKK-6R4BM-RVG79-R874J
Acer:6.0:Server:ServerStandard:223PV-8KCX6-F9KJX-3W2R7-BB2FH
Alienware:6.0:Server:ServerStandard:223PV-8KCX6-F9KJX-3W2R7-BB2FH
Asus:6.0:Server:ServerStandard:223PV-8KCX6-F9KJX-3W2R7-BB2FH
Dell:6.0:Server:ServerStandard:223PV-8KCX6-F9KJX-3W2R7-BB2FH
Gigabyte:6.0:Server:ServerStandard:223PV-8KCX6-F9KJX-3W2R7-BB2FH
HP:6.0:Server:ServerStandard:28QVP-KR6WC-PW76Q-YVX4X-FM3BM
Lenovo:6.0:Server:ServerStandard:223PV-8KCX6-F9KJX-3W2R7-BB2FH
MSI:6.0:Server:ServerStandard:223PV-8KCX6-F9KJX-3W2R7-BB2FH
Sony:6.0:Server:ServerStandard:223PV-8KCX6-F9KJX-3W2R7-BB2FH
Toshiba:6.0:Server:ServerStandard:223PV-8KCX6-F9KJX-3W2R7-BB2FH
Acer:6.0:Server:ServerEnterprise:26Y2H-YTJY6-CYD4F-DMB6V-KXFCQ
Alienware:6.0:Server:ServerEnterprise:26Y2H-YTJY6-CYD4F-DMB6V-KXFCQ
Asus:6.0:Server:ServerEnterprise:26Y2H-YTJY6-CYD4F-DMB6V-KXFCQ
Dell:6.0:Server:ServerEnterprise:26Y2H-YTJY6-CYD4F-DMB6V-KXFCQ
Gigabyte:6.0:Server:ServerEnterprise:26Y2H-YTJY6-CYD4F-DMB6V-KXFCQ
HP:6.0:Server:ServerEnterprise:26Y2H-YTJY6-CYD4F-DMB6V-KXFCQ
Lenovo:6.0:Server:ServerEnterprise:26Y2H-YTJY6-CYD4F-DMB6V-KXFCQ
MSI:6.0:Server:ServerEnterprise:26Y2H-YTJY6-CYD4F-DMB6V-KXFCQ
Sony:6.0:Server:ServerEnterprise:26Y2H-YTJY6-CYD4F-DMB6V-KXFCQ
Toshiba:6.0:Server:ServerEnterprise:26Y2H-YTJY6-CYD4F-DMB6V-KXFCQ
Acer:6.0:Server:ServerEnterpriseV:2P643-4GWD9-VCHR2-FD99Y-6VYKW
Alienware:6.0:Server:ServerEnterpriseV:2P643-4GWD9-VCHR2-FD99Y-6VYKW
Asus:6.0:Server:ServerEnterpriseV:2P643-4GWD9-VCHR2-FD99Y-6VYKW
Dell:6.0:Server:ServerEnterpriseV:2P643-4GWD9-VCHR2-FD99Y-6VYKW
Gigabyte:6.0:Server:ServerEnterpriseV:2P643-4GWD9-VCHR2-FD99Y-6VYKW
HP:6.0:Server:ServerEnterpriseV:2P643-4GWD9-VCHR2-FD99Y-6VYKW
Lenovo:6.0:Server:ServerEnterpriseV:2P643-4GWD9-VCHR2-FD99Y-6VYKW
MSI:6.0:Server:ServerEnterpriseV:2P643-4GWD9-VCHR2-FD99Y-6VYKW
Sony:6.0:Server:ServerEnterpriseV:2P643-4GWD9-VCHR2-FD99Y-6VYKW
Toshiba:6.0:Server:ServerEnterpriseV:2P643-4GWD9-VCHR2-FD99Y-6VYKW
Acer:6.0:Server:ServerSBSStandard:76GGM-4MQ6T-XCJH9-6R2XQ-PW2D2
Alienware:6.0:Server:ServerSBSStandard:76GGM-4MQ6T-XCJH9-6R2XQ-PW2D2
Asus:6.0:Server:ServerSBSStandard:76GGM-4MQ6T-XCJH9-6R2XQ-PW2D2
Dell:6.0:Server:ServerSBSStandard:76GGM-4MQ6T-XCJH9-6R2XQ-PW2D2
Gigabyte:6.0:Server:ServerSBSStandard:76GGM-4MQ6T-XCJH9-6R2XQ-PW2D2
HP:6.0:Server:ServerSBSStandard:76GGM-4MQ6T-XCJH9-6R2XQ-PW2D2
Lenovo:6.0:Server:ServerSBSStandard:76GGM-4MQ6T-XCJH9-6R2XQ-PW2D2
MSI:6.0:Server:ServerSBSStandard:76GGM-4MQ6T-XCJH9-6R2XQ-PW2D2
Sony:6.0:Server:ServerSBSStandard:76GGM-4MQ6T-XCJH9-6R2XQ-PW2D2
Toshiba:6.0:Server:ServerSBSStandard:76GGM-4MQ6T-XCJH9-6R2XQ-PW2D2
Acer:6.0:Server:ServerStorageStandard:264YC-6W6Q8-2W6M9-Q77M8-QYD4J
Alienware:6.0:Server:ServerStorageStandard:264YC-6W6Q8-2W6M9-Q77M8-QYD4J
Asus:6.0:Server:ServerStorageStandard:264YC-6W6Q8-2W6M9-Q77M8-QYD4J
Dell:6.0:Server:ServerStorageStandard:264YC-6W6Q8-2W6M9-Q77M8-QYD4J
Gigabyte:6.0:Server:ServerStorageStandard:264YC-6W6Q8-2W6M9-Q77M8-QYD4J
HP:6.0:Server:ServerStorageStandard:264YC-6W6Q8-2W6M9-Q77M8-QYD4J
Lenovo:6.0:Server:ServerStorageStandard:264YC-6W6Q8-2W6M9-Q77M8-QYD4J
MSI:6.0:Server:ServerStorageStandard:264YC-6W6Q8-2W6M9-Q77M8-QYD4J
Sony:6.0:Server:ServerStorageStandard:264YC-6W6Q8-2W6M9-Q77M8-QYD4J
Toshiba:6.0:Server:ServerStorageStandard:264YC-6W6Q8-2W6M9-Q77M8-QYD4J
Acer:6.1:Client:Starter:RDJXR-3M32B-FJT32-QMPGB-GCFF6
Alienware:6.1:Client:Starter:RDJXR-3M32B-FJT32-QMPGB-GCFF6
Asus:6.1:Client:Starter:6K6WB-X73TD-KG794-FJYHG-YCJVG
Dell:6.1:Client:Starter:36Q3Y-BBT84-MGJ3H-FT7VD-FG72J
Gigabyte:6.1:Client:Starter:36Q3Y-BBT84-MGJ3H-FT7VD-FG72J
HP:6.1:Client:Starter:BB2KM-PDWW3-99H7J-F7B9R-FXKF6
Lenovo:6.1:Client:Starter:22P26-HD8YH-RD96C-28R8J-DCT28
MSI:6.1:Client:Starter:2W4DJ-JFFJV-DMCPP-2C3X8-883DP
Sony:6.1:Client:Starter:32J2V-TGQCY-9QJXP-Q3FVT-X8BQ7
Toshiba:6.1:Client:Starter:TGBKB-9KBGJ-3Y3J6-K8M2F-J2HJQ
Acer:6.1:Client:StarterE:C3HY9-34XKR-6Y9Y9-RB7TR-84KWG
Alienware:6.1:Client:StarterE:C3HY9-34XKR-6Y9Y9-RB7TR-84KWG
Asus:6.1:Client:StarterE:C3HY9-34XKR-6Y9Y9-RB7TR-84KWG
Dell:6.1:Client:StarterE:C3HY9-34XKR-6Y9Y9-RB7TR-84KWG
Gigabyte:6.1:Client:StarterE:C3HY9-34XKR-6Y9Y9-RB7TR-84KWG
HP:6.1:Client:StarterE:C3HY9-34XKR-6Y9Y9-RB7TR-84KWG
Lenovo:6.1:Client:StarterE:C3HY9-34XKR-6Y9Y9-RB7TR-84KWG
MSI:6.1:Client:StarterE:C3HY9-34XKR-6Y9Y9-RB7TR-84KWG
Sony:6.1:Client:StarterE:C3HY9-34XKR-6Y9Y9-RB7TR-84KWG
Toshiba:6.1:Client:StarterE:C3HY9-34XKR-6Y9Y9-RB7TR-84KWG
Acer:6.1:Client:HomeBasic:MB4HF-2Q8V3-W88WR-K7287-2H4CP
Alienware:6.1:Client:HomeBasic:MB4HF-2Q8V3-W88WR-K7287-2H4CP
Asus:6.1:Client:HomeBasic:89G97-VYHYT-Y6G8H-PJXV6-77GQM
Dell:6.1:Client:HomeBasic:36T88-RT7C6-R38TQ-RV8M9-WWTCY
Gigabyte:6.1:Client:HomeBasic:36T88-RT7C6-R38TQ-RV8M9-WWTCY
HP:6.1:Client:HomeBasic:DX8R9-BVCGB-PPKRR-8J7T4-TJHTH
Lenovo:6.1:Client:HomeBasic:22MFQ-HDH7V-RBV79-QMVK9-PTMXQ
MSI:6.1:Client:HomeBasic:2TY7W-H4DD4-MB62F-BD9C3-88TM6
Sony:6.1:Client:HomeBasic:YV7QQ-RCXQ9-KTBHC-YX3FG-FKRW8
Toshiba:6.1:Client:HomeBasic:9H4FH-VD69Y-TGBD2-4PM4K-DRMMH
Acer:6.1:Client:HomePremium:VQB3X-Q3KP8-WJ2H8-R6B6D-7QJB7
Alienware:6.1:Client:HomePremium:V3Y2W-CMF9W-PGT9C-777KD-32W74
Asus:6.1:Client:HomePremium:2QDBX-9T8HR-2QWT6-HCQXJ-9YQTR
Dell:6.1:Client:HomePremium:6RBBT-F8VPQ-QCPVQ-KHRB8-RMV82
Gigabyte:6.1:Client:HomePremium:3743C-T6892-B4PHM-JHFKY-4BB7W
HP:6.1:Client:HomePremium:4FG99-BC3HD-73CQT-WMF7J-3Q6C9
Lenovo:6.1:Client:HomePremium:27GBM-Y4QQC-JKHXW-D9W83-FJQKD
MSI:6.1:Client:HomePremium:4G3GR-J6JDJ-D96PV-T9B9D-M8X2Q
Sony:6.1:Client:HomePremium:H4JWX-WHKWT-VGV87-C7XPK-CGKHQ
Toshiba:6.1:Client:HomePremium:6B88K-KCCWY-4F8HK-M4P73-W8DQG
Acer:6.1:Client:HomePremiumE:TD77M-HH38J-FBCB8-8QX7Y-P2QH3
Alienware:6.1:Client:HomePremiumE:TD77M-HH38J-FBCB8-8QX7Y-P2QH3
Asus:6.1:Client:HomePremiumE:TD77M-HH38J-FBCB8-8QX7Y-P2QH3
Dell:6.1:Client:HomePremiumE:TD77M-HH38J-FBCB8-8QX7Y-P2QH3
Gigabyte:6.1:Client:HomePremiumE:TD77M-HH38J-FBCB8-8QX7Y-P2QH3
HP:6.1:Client:HomePremiumE:TD77M-HH38J-FBCB8-8QX7Y-P2QH3
Lenovo:6.1:Client:HomePremiumE:TD77M-HH38J-FBCB8-8QX7Y-P2QH3
MSI:6.1:Client:HomePremiumE:TD77M-HH38J-FBCB8-8QX7Y-P2QH3
Sony:6.1:Client:HomePremiumE:TD77M-HH38J-FBCB8-8QX7Y-P2QH3
Toshiba:6.1:Client:HomePremiumE:TD77M-HH38J-FBCB8-8QX7Y-P2QH3
Acer:6.1:Client:Professional:YKHFT-KW986-GK4PY-FDWYH-7TP9F
Alienware:6.1:Client:Professional:4CFBX-7HQ6R-3JYWF-72GXP-4MV6W
Asus:6.1:Client:Professional:2WCJK-R8B4Y-CWRF2-TRJKB-PV9HW
Dell:6.1:Client:Professional:32KD2-K9CTF-M3DJT-4J3WC-733WD
Gigabyte:6.1:Client:Professional:32KD2-K9CTF-M3DJT-4J3WC-733WD
HP:6.1:Client:Professional:74T2M-DKDBC-788W3-H689G-6P6GT
Lenovo:6.1:Client:Professional:237XB-GDJ7B-MV8MH-98QJM-24367
MSI:6.1:Client:Professional:2W3CX-YD4YJ-DF9B2-V27M6-77GMF
Sony:6.1:Client:Professional:H9M26-6BXJP-XXFCY-7BR4V-24X8J
Toshiba:6.1:Client:Professional:2V8P2-QKJWM-4THM3-74PDB-4P2KH
Acer:6.1:Client:ProfessionalE:P42PH-HYD6B-Y3DHY-B79JH-CT8YK
Alienware:6.1:Client:ProfessionalE:P42PH-HYD6B-Y3DHY-B79JH-CT8YK
Asus:6.1:Client:ProfessionalE:P42PH-HYD6B-Y3DHY-B79JH-CT8YK
Dell:6.1:Client:ProfessionalE:P42PH-HYD6B-Y3DHY-B79JH-CT8YK
Gigabyte:6.1:Client:ProfessionalE:P42PH-HYD6B-Y3DHY-B79JH-CT8YK
HP:6.1:Client:ProfessionalE:P42PH-HYD6B-Y3DHY-B79JH-CT8YK
Lenovo:6.1:Client:ProfessionalE:P42PH-HYD6B-Y3DHY-B79JH-CT8YK
MSI:6.1:Client:ProfessionalE:P42PH-HYD6B-Y3DHY-B79JH-CT8YK
Sony:6.1:Client:ProfessionalE:P42PH-HYD6B-Y3DHY-B79JH-CT8YK
Toshiba:6.1:Client:ProfessionalE:P42PH-HYD6B-Y3DHY-B79JH-CT8YK
Acer:6.1:Client:Ultimate:FJGCP-4DFJD-GJY49-VJBQ7-HYRR2
Alienware:6.1:Client:Ultimate:4HMYB-6YHYT-TW2J6-FQBC3-6GBFW
Asus:6.1:Client:Ultimate:2Y4WT-DHTBF-Q6MMK-KYK6X-VKM6G
Dell:6.1:Client:Ultimate:342DG-6YJR8-X92GV-V7DCV-P4K27
Gigabyte:6.1:Client:Ultimate:342DG-6YJR8-X92GV-V7DCV-P4K27
HP:6.1:Client:Ultimate:MHFPT-8C8M2-V9488-FGM44-2C9T3
Lenovo:6.1:Client:Ultimate:6K2KY-BFH24-PJW6W-9GK29-TMPWP
MSI:6.1:Client:Ultimate:6K2KY-BFH24-PJW6W-9GK29-TMPWP
Sony:6.1:Client:Ultimate:YJJYR-666KV-8T4YH-KM9TB-4PY2W
Toshiba:6.1:Client:Ultimate:2XQ63-J3P67-9G3JC-FHQ68-8Q2F3
Acer:6.1:Client:UltimateE:278MV-DKMGJ-F3P9F-TD7Y3-W6G3M
Alienware:6.1:Client:UltimateE:278MV-DKMGJ-F3P9F-TD7Y3-W6G3M
Asus:6.1:Client:UltimateE:278MV-DKMGJ-F3P9F-TD7Y3-W6G3M
Dell:6.1:Client:UltimateE:278MV-DKMGJ-F3P9F-TD7Y3-W6G3M
Gigabyte:6.1:Client:UltimateE:278MV-DKMGJ-F3P9F-TD7Y3-W6G3M
HP:6.1:Client:UltimateE:278MV-DKMGJ-F3P9F-TD7Y3-W6G3M
Lenovo:6.1:Client:UltimateE:278MV-DKMGJ-F3P9F-TD7Y3-W6G3M
MSI:6.1:Client:UltimateE:278MV-DKMGJ-F3P9F-TD7Y3-W6G3M
Sony:6.1:Client:UltimateE:278MV-DKMGJ-F3P9F-TD7Y3-W6G3M
Toshiba:6.1:Client:UltimateE:278MV-DKMGJ-F3P9F-TD7Y3-W6G3M
Acer:6.1:Server:ServerWinFoundation:VMYRB-8BRVQ-KXWFF-334J3-F2WHJ
Alienware:6.1:Server:ServerWinFoundation:VMYRB-8BRVQ-KXWFF-334J3-F2WHJ
Asus:6.1:Server:ServerWinFoundation:VMYRB-8BRVQ-KXWFF-334J3-F2WHJ
Dell:6.1:Server:ServerWinFoundation:VMYRB-8BRVQ-KXWFF-334J3-F2WHJ
Gigabyte:6.1:Server:ServerWinFoundation:VMYRB-8BRVQ-KXWFF-334J3-F2WHJ
HP:6.1:Server:ServerWinFoundation:VMYRB-8BRVQ-KXWFF-334J3-F2WHJ
Lenovo:6.1:Server:ServerWinFoundation:VMYRB-8BRVQ-KXWFF-334J3-F2WHJ
MSI:6.1:Server:ServerWinFoundation:VMYRB-8BRVQ-KXWFF-334J3-F2WHJ
Sony:6.1:Server:ServerWinFoundation:VMYRB-8BRVQ-KXWFF-334J3-F2WHJ
Toshiba:6.1:Server:ServerWinFoundation:VMYRB-8BRVQ-KXWFF-334J3-F2WHJ
Acer:6.1:Server:ServerWeb:FBP7P-TBFFF-DQ8HF-33QJM-MT2BK
Alienware:6.1:Server:ServerWeb:FBP7P-TBFFF-DQ8HF-33QJM-MT2BK
Asus:6.1:Server:ServerWeb:FBP7P-TBFFF-DQ8HF-33QJM-MT2BK
Dell:6.1:Server:ServerWeb:FBP7P-TBFFF-DQ8HF-33QJM-MT2BK
Gigabyte:6.1:Server:ServerWeb:FBP7P-TBFFF-DQ8HF-33QJM-MT2BK
HP:6.1:Server:ServerWeb:FBP7P-TBFFF-DQ8HF-33QJM-MT2BK
Lenovo:6.1:Server:ServerWeb:FBP7P-TBFFF-DQ8HF-33QJM-MT2BK
MSI:6.1:Server:ServerWeb:FBP7P-TBFFF-DQ8HF-33QJM-MT2BK
Sony:6.1:Server:ServerWeb:FBP7P-TBFFF-DQ8HF-33QJM-MT2BK
Toshiba:6.1:Server:ServerWeb:FBP7P-TBFFF-DQ8HF-33QJM-MT2BK
Acer:6.1:Server:ServerStandard:D7TCH-6P8JP-KRG4P-VJKYY-P9GFF
Alienware:6.1:Server:ServerStandard:D7TCH-6P8JP-KRG4P-VJKYY-P9GFF
Asus:6.1:Server:ServerStandard:D7TCH-6P8JP-KRG4P-VJKYY-P9GFF
Dell:6.1:Server:ServerStandard:D7TCH-6P8JP-KRG4P-VJKYY-P9GFF
Gigabyte:6.1:Server:ServerStandard:D7TCH-6P8JP-KRG4P-VJKYY-P9GFF
HP:6.1:Server:ServerStandard:D7TCH-6P8JP-KRG4P-VJKYY-P9GFF
Lenovo:6.1:Server:ServerStandard:D7TCH-6P8JP-KRG4P-VJKYY-P9GFF
MSI:6.1:Server:ServerStandard:D7TCH-6P8JP-KRG4P-VJKYY-P9GFF
Sony:6.1:Server:ServerStandard:D7TCH-6P8JP-KRG4P-VJKYY-P9GFF
Toshiba:6.1:Server:ServerStandard:D7TCH-6P8JP-KRG4P-VJKYY-P9GFF
Acer:6.1:Server:ServerEnterprise:BKCJJ-J6G9Y-4P7YF-8D4J7-7TCWD
Alienware:6.1:Server:ServerEnterprise:BKCJJ-J6G9Y-4P7YF-8D4J7-7TCWD
Asus:6.1:Server:ServerEnterprise:BKCJJ-J6G9Y-4P7YF-8D4J7-7TCWD
Dell:6.1:Server:ServerEnterprise:BKCJJ-J6G9Y-4P7YF-8D4J7-7TCWD
Gigabyte:6.1:Server:ServerEnterprise:BKCJJ-J6G9Y-4P7YF-8D4J7-7TCWD
HP:6.1:Server:ServerEnterprise:BKCJJ-J6G9Y-4P7YF-8D4J7-7TCWD
Lenovo:6.1:Server:ServerEnterprise:BKCJJ-J6G9Y-4P7YF-8D4J7-7TCWD
MSI:6.1:Server:ServerEnterprise:BKCJJ-J6G9Y-4P7YF-8D4J7-7TCWD
Sony:6.1:Server:ServerEnterprise:BKCJJ-J6G9Y-4P7YF-8D4J7-7TCWD
Toshiba:6.1:Server:ServerEnterprise:BKCJJ-J6G9Y-4P7YF-8D4J7-7TCWD
Acer:6.1:Server:ServerDatacenter:26FXG-KYC7Q-XG29P-T2HFQ-KPF96
Alienware:6.1:Server:ServerDatacenter:26FXG-KYC7Q-XG29P-T2HFQ-KPF96
Asus:6.1:Server:ServerDatacenter:26FXG-KYC7Q-XG29P-T2HFQ-KPF96
Dell:6.1:Server:ServerDatacenter:26FXG-KYC7Q-XG29P-T2HFQ-KPF96
Gigabyte:6.1:Server:ServerDatacenter:26FXG-KYC7Q-XG29P-T2HFQ-KPF96
HP:6.1:Server:ServerDatacenter:26FXG-KYC7Q-XG29P-T2HFQ-KPF96
Lenovo:6.1:Server:ServerDatacenter:26FXG-KYC7Q-XG29P-T2HFQ-KPF96
MSI:6.1:Server:ServerDatacenter:26FXG-KYC7Q-XG29P-T2HFQ-KPF96
Sony:6.1:Server:ServerDatacenter:26FXG-KYC7Q-XG29P-T2HFQ-KPF96
Toshiba:6.1:Server:ServerDatacenter:26FXG-KYC7Q-XG29P-T2HFQ-KPF96
Acer:6.1:Server:ServerHomeStandard:24HKG-38D9W-TCG2V-K4G44-RQ2CC
Alienware:6.1:Server:ServerHomeStandard:24HKG-38D9W-TCG2V-K4G44-RQ2CC
Asus:6.1:Server:ServerHomeStandard:24HKG-38D9W-TCG2V-K4G44-RQ2CC
Dell:6.1:Server:ServerHomeStandard:24HKG-38D9W-TCG2V-K4G44-RQ2CC
Gigabyte:6.1:Server:ServerHomeStandard:24HKG-38D9W-TCG2V-K4G44-RQ2CC
HP:6.1:Server:ServerHomeStandard:24HKG-38D9W-TCG2V-K4G44-RQ2CC
Lenovo:6.1:Server:ServerHomeStandard:24HKG-38D9W-TCG2V-K4G44-RQ2CC
MSI:6.1:Server:ServerHomeStandard:24HKG-38D9W-TCG2V-K4G44-RQ2CC
Sony:6.1:Server:ServerHomeStandard:24HKG-38D9W-TCG2V-K4G44-RQ2CC
Toshiba:6.1:Server:ServerHomeStandard:24HKG-38D9W-TCG2V-K4G44-RQ2CC
Acer:6.1:Server:ServerSolution:6PJGG-PHG6F-PF94R-RB7QT-PP7KV
Alienware:6.1:Server:ServerSolution:6PJGG-PHG6F-PF94R-RB7QT-PP7KV
Asus:6.1:Server:ServerSolution:6PJGG-PHG6F-PF94R-RB7QT-PP7KV
Dell:6.1:Server:ServerSolution:6PJGG-PHG6F-PF94R-RB7QT-PP7KV
Gigabyte:6.1:Server:ServerSolution:6PJGG-PHG6F-PF94R-RB7QT-PP7KV
HP:6.1:Server:ServerSolution:6PJGG-PHG6F-PF94R-RB7QT-PP7KV
Lenovo:6.1:Server:ServerSolution:6PJGG-PHG6F-PF94R-RB7QT-PP7KV
MSI:6.1:Server:ServerSolution:6PJGG-PHG6F-PF94R-RB7QT-PP7KV
Sony:6.1:Server:ServerSolution:6PJGG-PHG6F-PF94R-RB7QT-PP7KV
Toshiba:6.1:Server:ServerSolution:6PJGG-PHG6F-PF94R-RB7QT-PP7KV
Acer:6.1:Server:ServerHomePremium:2M74M-6DJHT-Y49MG-22FGH-B6XFP
Alienware:6.1:Server:ServerHomePremium:2M74M-6DJHT-Y49MG-22FGH-B6XFP
Asus:6.1:Server:ServerHomePremium:2M74M-6DJHT-Y49MG-22FGH-B6XFP
Dell:6.1:Server:ServerHomePremium:2M74M-6DJHT-Y49MG-22FGH-B6XFP
Gigabyte:6.1:Server:ServerHomePremium:2M74M-6DJHT-Y49MG-22FGH-B6XFP
HP:6.1:Server:ServerHomePremium:2M74M-6DJHT-Y49MG-22FGH-B6XFP
Lenovo:6.1:Server:ServerHomePremium:2M74M-6DJHT-Y49MG-22FGH-B6XFP
MSI:6.1:Server:ServerHomePremium:2M74M-6DJHT-Y49MG-22FGH-B6XFP
Sony:6.1:Server:ServerHomePremium:2M74M-6DJHT-Y49MG-22FGH-B6XFP
Toshiba:6.1:Server:ServerHomePremium:2M74M-6DJHT-Y49MG-22FGH-B6XFP
) do (
for /f "tokens=1-5 delims=:" %%G in ("%%#") do if /i %slic% EQU %%G if /i %osver% EQU %%H if /i %ostype% EQU %%I if /i %osedition% EQU %%J set "key=%%K"
)
if defined CustomKey set key=%customkey%
if not defined key (
%_eline%
echo Your OS edition is not supported.
echo Please use alternative activation exploits.
%_pakerr%
)
echo Copying files...
(<nul (set /p _temp_key=%key%)) > "%temp%\key.txt"
md %_ltr%\EFI\WindSLIC %_nul%
copy /y "%~dp0bin\WindSLIC.efi" %_ltr%\EFI\WindSLIC %_nul%
copy /y "%~dp0bin\%slic%\slic.BIN" %_ltr%\EFI\WindSLIC %_nul%
copy /y "%temp%\key.txt" %_ltr%\EFI\WindSLIC %_nul%
echo Installing certificate...
%_slm% -ilc "%~dp0bin\%slic%\%slic%.XRM-MS"
echo Installing product key...
%_slm% -ipk %key%
echo Installing bootloader...
%_bcd% /store "%_ltr%\EFI\Microsoft\Boot\BCD" /set {bootmgr} PATH \EFI\WindSLIC\WindSLIC.efi %_nul%
%_bcd% /set {bootmgr} PATH \EFI\WindSLIC\WindSLIC.efi
echo Cleaning up...
del "%temp%\key.txt" %_nul%
echo A reboot is required to finish activation.
echo Press any key to reboot...
pause >nul
cd /d %systemroot%
mountvol %_ltr% /d
%_reb%
exit /b 0