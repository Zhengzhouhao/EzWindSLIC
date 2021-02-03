setlocal ENABLEDELAYEDEXPANSION
cls
@echo off
color 1f
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
color 1f
title EzWindSLIC by Exe Csrss
echo EzWindSLIC by Exe Csrss
cd /d V: >nul 2>&1 && (
echo WARNING^!
echo The drive letter V: is already occupied, press any key to temporarily dismount drive V...
pause >nul
C:
mountvol V: /d
mountvol V: /s
cd %windir%\system32 >nul 2>&1
)
mountvol V: /s >nul 2>&1
if exist V:\EFI\Microsoft\Boot\bootmgfw.efi (
echo EFI System Partition successfully mounted at V:
) else (
echo Failed to mount EFI System Partition or bootloader is incompatible with EFI.
echo Press any key to exit...
pause >nul
exit
)
FOR /F "tokens=2* skip=2" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "ProductName"') do set truos=%%b
echo Detected OS: %truos%
set os="%truos%"
if exist V:\EFI\WindSLIC\WindSLIC.efi (
echo WindSLIC seems to be already installed. Press any key to uninstall...
pause >nul
echo Uninstalling WindSLIC...
echo Restoring bootloader...
bcdedit /set {bootmgr} path \EFI\Microsoft\Boot\bootmgfw.efi
echo Cleaning files...
rd V:\efi\windslic /s /q >nul 2>&1
echo Uninstalling certificate...
cscript //nologo %windir%\system32\slmgr.vbs -rilc >nul 2>&1
echo Installing grace product key for: %truos%...
if /i %os% EQU "Windows Vista (TM) Home Basic" set key=RCG7P-TX42D-HM8FM-TCFCW-3V4VD
if /i %os% EQU "Windows Vista (TM) Home Premium" set key=X9HTF-MKJQQ-XK376-TJ7T4-76PKF
if /i %os% EQU "Windows Vista (TM) Business" set grkey=4D2XH-PRBMM-8Q22B-K8BM3-MRW4W
if /i %os% EQU "Windows Vista (TM) Ultimate" set grkey=VMCB9-FDRV6-6CDQM-RV23K-RP8F7
if /i %os% EQU "Windows 7 Home Basic" set grkey=YGFVB-QTFXQ-3H233-PTWTJ-YRYRV
if /i %os% EQU "Windows 7 Home Premium" set grkey=RHPQ2-RMFJH-74XYM-BH4JX-XM76F
if /i %os% EQU "Windows 7 Professional" set grkey=HYF8J-CVRMY-CM74G-RPHKF-PW487
if /i %os% EQU "Windows 7 Professional E" set grkey=P42PH-HYD6B-Y3DHY-B79JH-CT8YK
if /i %os% EQU "Windows 7 Ultimate" set grkey=D4F6K-QK3RD-TMVMJ-BBMRX-3MBMV
cscript //nologo %windir%\system32\slmgr.vbs -ipk !grkey! >nul 2>&1
echo Press any key to reboot to clear SLIC from memory...
mountvol V: /d >nul 2>&1
pause >nul
shutdown -r -f -t 00
exit
)
echo Current activation status:
cscript //nologo %windir%\system32\slmgr.vbs -dlv
if /i %os% EQU "Windows Vista (TM) Home Basic" set key=2W7FD-9DWCB-Q9CM8-KTDKK-8QXTR
if /i %os% EQU "Windows Vista (TM) Home Basic N" set key=22TC9-RDMDD-VXMXD-2XM2Y-DT6FX
if /i %os% EQU "Windows Vista (TM) Home Premium" set key=2TYBW-XKCQM-XY9X3-JDXYP-6CJ97
if /i %os% EQU "Windows Vista (TM) Business" set key=2TJTJ-C72D7-7BCYH-FV3HT-JGD4F
if /i %os% EQU "Windows Vista (TM) Business N" set key=2434H-HFRM7-BHGD4-W9TTD-RJVCH
if /i %os% EQU "Windows Vista (TM) Ultimate" set key=3YDB8-YY3P4-G7FCW-GJMPG-VK48C
if /i %os% EQU "Windows 7 Home Basic" set key=MB4HF-2Q8V3-W88WR-K7287-2H4CP
if /i %os% EQU "Windows 7 Home Premium" set key=VQB3X-Q3KP8-WJ2H8-R6B6D-7QJB7
if /i %os% EQU "Windows 7 Home Premium E" set key=TD77M-HH38J-FBCB8-8QX7Y-P2QH3
if /i %os% EQU "Windows 7 Professional" set key=YKHFT-KW986-GK4PY-FDWYH-7TP9F
if /i %os% EQU "Windows 7 Professional E" set key=P42PH-HYD6B-Y3DHY-B79JH-CT8YK
if /i %os% EQU "Windows 7 Ultimate" set key=FJGCP-4DFJD-GJY49-VJBQ7-HYRR2
if /i %os% EQU "Windows 7 Ultimate E" set key=278MV-DKMGJ-F3P9F-TD7Y3-W6G3M
if /i %os% EQU "Windows Server (R) 2008 Standard" set key=223PV-8KCX6-F9KJX-3W2R7-BB2FH
if /i %os% EQU "Windows Server (R) 2008 Enterprise" set key=26Y2H-YTJY6-CYD4F-DMB6V-KXFCQ
if /i %os% EQU "Windows Server 2008 R2 Standard" set key=D7TCH-6P8JP-KRG4P-VJKYY-P9GFF
if /i %os% EQU "Windows Server 2008 R2 Datacenter" set key=26FXG-KYC7Q-XG29P-T2HFQ-KPF96
if /i %os% EQU "Windows Server 2008 R2 Enterprise" set key=BKCJJ-J6G9Y-4P7YF-8D4J7-7TCWD
if /i "%~1" EQU "-custom" set /p key="Enter your custom product key: "
if not defined key (
echo ERROR
echo Unsupported OS!
echo Press any key to exit...
pause >nul
mountvol V: /d >nul 2>&1
exit
)
echo [1] Acer
echo [2] Asus
echo [3] HP
echo [4] Dell
echo [5] Alienware
echo [6] Toshiba
echo [7] Lenovo
echo [8] MSI
echo [9] Gigabyte
echo [A] Sony
choice /c 123456789a /m "Which SLIC profile would you like to install "
set prof=%errorlevel%
if %prof% EQU 1 set slic=Acer
if %prof% EQU 2 set slic=Asus
if %prof% EQU 3 set slic=HP
if %prof% EQU 4 set slic=Dell
if %prof% EQU 5 set slic=Alienware
if %prof% EQU 6 set slic=Toshiba
if %prof% EQU 7 set slic=Lenovo
if %prof% EQU 8 set slic=MSI
if %prof% EQU 9 set slic=Gigabyte
if %prof% EQU 10 set slic=Sony
if not exist "%~dp0bin\%slic%\slic.BIN" (
echo SLIC doesn't exist, make sure all files are intact, and run this again.
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
cscript //nologo %windir%\system32\slmgr.vbs -ckms >nul 2>&1
(<nul (set /p _temp_key=%key%)) > %temp%\key.txt
echo Copying files...
md V:\EFI\WindSLIC >nul 2>&1
copy /y "%~dp0bin\WindSLIC.efi" V:\EFI\WindSLIC >nul 2>&1
copy /y "%~dp0bin\%slic%\slic.BIN" V:\EFI\WindSLIC >nul 2>&1
copy /y "%temp%\key.txt" V:\EFI\WindSLIC >nul 2>&1
echo Installing bootloader...
bcdedit /set {bootmgr} path \EFI\WindSLIC\WindSLIC.efi
echo Installing certificate...
cscript //nologo %windir%\system32\slmgr.vbs -ilc "%~dp0bin\%slic%\%slic%.XRM-MS"
echo Installing product key for: %truos%...
cscript //nologo %windir%\system32\slmgr.vbs -ipk %key%
echo Cleaning up...
del /f /q %temp%\key.txt >nul 2>&1
echo A reboot is required to finish activation. Press any key to reboot...
pause >nul
mountvol V: /d >nul 2>&1
shutdown -r -f -t 00 >nul 2>&1