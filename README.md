# EzWindSLIC
An activator for Windows 7 for UEFI-GPT systems, based on WindSLIC but this one is more user friendly.
Using this activator is very simple. Open the batch file, the script will self-elevate and will automatically detect your OS. The script will install an OEM SLP product key, a custom bootloader and an XRML certificate.

If you get an error running the activator then:
Make sure that you have a UEFI motherboard and are NOT booted into legacy mode. Try using Daz' Windows Loader. Your OS may not be supported.

To uninstall this activator:
Run uninstall.bat. Reboot when prompted.

To use a custom product key:
Open install.bat in a text editor and uncomment the line which sets the CustomKey variable.

To use custom SLIC and cert:
Open install.bat in a text editor and uncomment the line which sets the UseCustomSLICAndCert variable. Drop the SLIC and Cert as slic.BIN and Custom.XRM-MS in \bin\Custom.
