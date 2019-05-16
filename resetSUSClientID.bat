:: ==================================================================================
:: NAME:	Reset WSUS Client ID.
:: AUTHOR:	Manuel Gil.
:: ==================================================================================

echo off
title Reset WSUS Client ID.
cls

set args=%*

openfiles>nul 2>&1

if {%errorlevel%}=={0} (
	if {%*}=={/s} (
		goto SILENT_MODE
	) else (
		goto CONTINUE_SCRIPT
	)
)

ver
echo.Reset WSUS Client ID.
echo.
echo.    Reloading the Script with elevation,
echo.    click on the "Allow" or "Yes" button to continue.
echo.
timeout /t 9 /nobreak

start wscript //nologo "%~dp0elevate.vbs"

goto :EOF

:SILENT_MODE

start wscript //nologo "%~dp0hidden.vbs"

goto :EOF

:CONTINUE_SCRIPT

ver
echo.Reset WSUS Client ID.
echo.

echo.Canceling the Windows Update process.
echo.

taskkill /im wuauclt.exe /f

echo.Stopping the Windows Update services.
echo.

net stop bits
net stop wuauserv
net stop appidsvc
net stop cryptsvc

echo.Checking the services status.
echo.

sc query bits | findstr /I /C:"STOPPED"
if %errorlevel% NEQ 0 echo Failed to stop the bits service. & pause & goto :eof

sc query wuauserv | findstr /I /C:"STOPPED"
if %errorlevel% NEQ 0 echo Failed to stop the wuauserv service. & pause & goto :eof

sc query appidsvc | findstr /I /C:"STOPPED"
if %errorlevel% NEQ 0 sc query appidsvc | findstr /I /C:"OpenService FAILED 1060"
if %errorlevel% NEQ 0 echo Failed to stop the appidsvc service. & pause & goto :eof

sc query cryptsvc | findstr /I /C:"STOPPED"
if %errorlevel% NEQ 0 echo Failed to stop the cryptsvc service. & pause & goto :eof

echo.Deleting the qmgr*.dat files.
echo.

del /s /q /f "%ALLUSERSPROFILE%\Application Data\Microsoft\Network\Downloader\qmgr*.dat"
del /s /q /f "%ALLUSERSPROFILE%\Microsoft\Network\Downloader\qmgr*.dat"

echo.Renaming the softare distribution folders backup copies.
echo.

rmdir /s /q "%SYSTEMROOT%\SoftwareDistribution.bak"
ren "%SYSTEMROOT%\SoftwareDistribution" SoftwareDistribution.bak
if exist "%SYSTEMROOT%\SoftwareDistribution" echo Failed to rename the SoftwareDistribution folder. & pause & goto :eof

rmdir /s /q "%SYSTEMROOT%\system32\Catroot2.bak"
ren "%SYSTEMROOT%\system32\Catroot2" Catroot2.bak

del /s /q /f "%SYSTEMROOT%\winsxs\pending.xml.bak"
ren "%SYSTEMROOT%\winsxs\pending.xml" pending.xml.bak

del /s /q /f "%SYSTEMROOT%\WindowsUpdate.log.bak"
ren "%SYSTEMROOT%\WindowsUpdate.log" WindowsUpdate.log.bak

echo.Reset the BITS service and the Windows Update service to the default security descriptor.
echo.

sc.exe sdset wuauserv D:(A;;CCLCSWLOCRRC;;;AU)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCDCLCSWRPWPDTLCRSDRCWDWO;;;SO)(A;;CCLCSWRPWPDTLOCRRC;;;SY)S:(AU;FA;CCDCLCSWRPWPDTLOCRSDRCWDWO;;WD)
sc.exe sdset bits D:(A;;CCLCSWLOCRRC;;;AU)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCDCLCSWRPWPDTLCRSDRCWDWO;;;SO)(A;;CCLCSWRPWPDTLOCRRC;;;SY)S:(AU;FA;CCDCLCSWRPWPDTLOCRSDRCWDWO;;WD)
sc.exe sdset cryptsvc D:(A;;CCLCSWLOCRRC;;;AU)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCDCLCSWRPWPDTLCRSDRCWDWO;;;SO)(A;;CCLCSWRPWPDTLOCRRC;;;SY)S:(AU;FA;CCDCLCSWRPWPDTLOCRSDRCWDWO;;WD)
sc.exe sdset trustedinstaller D:(A;;CCLCSWLOCRRC;;;AU)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCDCLCSWRPWPDTLCRSDRCWDWO;;;SO)(A;;CCLCSWRPWPDTLOCRRC;;;SY)S:(AU;FA;CCDCLCSWRPWPDTLOCRSDRCWDWO;;WD)

echo.Reregister the BITS files and the Windows Update files.
echo.

regsvr32.exe /s atl.dll
regsvr32.exe /s urlmon.dll
regsvr32.exe /s mshtml.dll
regsvr32.exe /s shdocvw.dll
regsvr32.exe /s browseui.dll
regsvr32.exe /s jscript.dll
regsvr32.exe /s vbscript.dll
regsvr32.exe /s scrrun.dll
regsvr32.exe /s msxml.dll
regsvr32.exe /s msxml3.dll
regsvr32.exe /s msxml6.dll
regsvr32.exe /s actxprxy.dll
regsvr32.exe /s softpub.dll
regsvr32.exe /s wintrust.dll
regsvr32.exe /s dssenh.dll
regsvr32.exe /s rsaenh.dll
regsvr32.exe /s gpkcsp.dll
regsvr32.exe /s sccbase.dll
regsvr32.exe /s slbcsp.dll
regsvr32.exe /s cryptdlg.dll
regsvr32.exe /s oleaut32.dll
regsvr32.exe /s ole32.dll
regsvr32.exe /s shell32.dll
regsvr32.exe /s initpki.dll
regsvr32.exe /s wuapi.dll
regsvr32.exe /s wuaueng.dll
regsvr32.exe /s wuaueng1.dll
regsvr32.exe /s wucltui.dll
regsvr32.exe /s wups.dll
regsvr32.exe /s wups2.dll
regsvr32.exe /s wuweb.dll
regsvr32.exe /s qmgr.dll
regsvr32.exe /s qmgrprxy.dll
regsvr32.exe /s wucltux.dll
regsvr32.exe /s muweb.dll
regsvr32.exe /s wuwebv.dll


echo.Deleting values in the Registry.
echo.
reg Delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate /v PingID /f
reg Delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate /v AccountDomainSid /f
reg Delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate /v SusClientId /f
reg Delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate /v SusClientIDValidation /f

echo.Resetting Winsock and WinHTTP Proxy.
echo.

netsh winsock reset
netsh winhttp reset proxy

echo.Resetting the services as automatics.
echo.

sc.exe config wuauserv start= auto
sc.exe config bits start= delayed-auto
sc.exe config cryptsvc start= auto
sc.exe config TrustedInstaller start= demand
sc.exe config DcomLaunch start= auto

echo.Starting the Windows Update services.
echo.

net start bits
net start wuauserv
net start appidsvc
net start cryptsvc
net start DcomLaunch

echo.Forcing updates.
echo.
wuauclt.exe /resetauthorization /detectnow

echo.The operation completed successfully.
echo.Please reboot your computer.
pause
goto :eof
