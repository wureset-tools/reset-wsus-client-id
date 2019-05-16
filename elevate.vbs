' //***************************************************************************
' // ***** Script Header *****
' //
' // File:      Elevate.vbs
' //
' // Purpose:   Launching with elevation (Run as Administrator).
' //
' // ***** End Header *****
' //***************************************************************************

Dim objShell
Set objShell = CreateObject("Shell.Application")
objShell.ShellExecute "resetSUSClientID.bat", "", "", "runas"
Set objShell = Nothing