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
set "uiver=2.2 Release Candidate 1"
title EzWindSLIC %uiver% by Exe Csrss
echo EzWindSLIC %uiver% by Exe Csrss
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
:: Check for occupied drive letters (original idea)
for %%# in (Q W E R T Y U I O P A S D F G H J K L Z X C V B N M) do (
mountvol /? | find /i "%%#:\" %_nul% || set _ltr=%%#:
)
:: Check if there is an unoccupied drive letter
if not defined _ltr (
%_eline%
echo No unoccupied drive letter.
echo A free drive letter is required to mount the EFI System Partition.
%_pakerr%
)
:: Detect OS version
for /f "tokens=4,5 delims=[]. " %%G in ('ver') do set osver=%%G.%%H
if %osver% NEQ 6.0 if %osver% NEQ 6.1 (
%_eline%
echo Your OS version is not supported. Please use alternative activation exploits.
%_pakerr%
)
:: Detect OS type by @abbodi1406
if exist "%SystemRoot%\Servicing\Packages\Microsoft-Windows-Server*Edition~*.mum" (
set ostype=Server
)
if not defined ostype set ostype=Client
::Detect OS edition
for /f "tokens=2* skip=2" %%G in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "EditionID"') do set osedition=%%H
:: NT 6.0 doesn't have InstallationType registry value
if not defined ostype (
echo %osedition% | find "Server" %_nul% && set ostype=Server
if not defined ostype set ostype=Client
)
echo Mounting EFI System Partition to: %_ltr%...
mountvol %_ltr% /s
if not exist %_ltr%\EFI (
%_eline%
echo An error occured while mounting the EFI system partition.
%_pakerr%
)
echo EFI System Partition successfully mounted at %_ltr%.
echo Checking if WindSLIC is installed...
if not exist %_ltr%\EFI\WindSLIC (
echo WindSLIC is not installed.
%_pak%
)
echo WindSLIC is currently installed.
:: Decide product key to be installed (inspiration from @Windows_Addict's MAS)
for %%# in (
6.0:Client:Starter:X9PYV-YBQRV-9BXWV-TQDMK-QDWK4
6.0:Client:HomeBasic:RCG7P-TX42D-HM8FM-TCFCW-3V4VD
6.0:Client:HomePremium:X9HTF-MKJQQ-XK376-TJ7T4-76PKF
6.0:Client:Business:4D2XH-PRBMM-8Q22B-K8BM3-MRW4W
6.0:Client:Ultimate:VMCB9-FDRV6-6CDQM-RV23K-RP8F7
6.0:Server:ServerStandard:TM24T-X9RMF-VWXK6-X8JC9-BFGM2
6.0:Server:ServerEnterprise:YQGMW-MPWTJ-34KDK-48M3W-X4Q6V
6.1:Client:Starter:7Q28W-FT9PC-CMMYT-WHMY2-89M6G
6.1:Client:StarterE:BRQCV-K7HGQ-CKXP6-2XP7K-F233B
6.1:Client:HomeBasic:YGFVB-QTFXQ-3H233-PTWTJ-YRYRV
6.1:Client:HomePremium:RHPQ2-RMFJH-74XYM-BH4JX-XM76F
6.1:Client:HomePremiumE:76BRM-9Q4K3-QDJ48-FH4F3-9WT2R
6.1:Client:Professional:HYF8J-CVRMY-CM74G-RPHKF-PW487
6.1:Client:ProfessionalE:3YHKG-DVQ27-RYRBX-JMPVM-WG38T
6.1:Client:Ultimate:D4F6K-QK3RD-TMVMJ-BBMRX-3MBMV
6.1:Client:UltimateE:TWMF7-M387V-XKW4Y-PVQQD-RK7C8
6.1:Server:ServerWinFoundation:36RXV-4Y4PJ-B7DWH-XY4VW-KQXDQ
6.1:Server:ServerWeb:YGTGP-9XH8D-8BVGY-BVK4V-3CPRF
6.1:Server:ServerStandard:HMG6P-C7VGP-47GJ9-TWBD4-2YYCD
6.1:Server:ServerEnterprise:7P8GH-FV2FF-8FDCR-YK49D-D7P97
6.1:Server:ServerDatacenter:7X29B-RDCR7-J6R29-K27FF-H9CR9
6.1:Server:ServerHomeStandard:BTMWJ-8KHD9-B9BX8-J7JQ9-7M6J2
6.1:Server:ServerSolution:VVWPG-XFYWQ-4HBR7-DYGCW-TF7XW
6.1:Server:ServerSBSStandard:YT76W-VD3W9-QDCK4-9QFPX-WQY4J
6.1:Server:ServerHomePremium:YQXDR-G2MBV-63VW2-JX8J2-FVTVG
) do (
for /f "tokens=1-4 delims=:" %%G in ("%%#") do if /i %osver% EQU %%G if /i %ostype% EQU %%H if /i %osedition% EQU %%I set "grkey=%%J"
)
if defined grkey (
echo Installing grace product key...
%_slm% -ipk %grkey%
)
echo Uninstalling bootloader...
%_bcd% /store "%_ltr%\EFI\Microsoft\Boot\BCD" /set {bootmgr} PATH \EFI\Microsoft\Boot\bootmgfw.efi %_nul%
%_bcd% /set {bootmgr} PATH \EFI\Microsoft\Boot\bootmgfw.efi
echo Removing WindSLIC...
rd %_ltr%\EFI\WindSLIC /s /q %_nul%
echo A reboot is required to clear SLIC from memory.
echo Press any key to reboot...
pause >nul
cd /d %systemroot%
mountvol %_ltr% /d
%_reb%
exit /b 0