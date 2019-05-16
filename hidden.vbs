' //***************************************************************************
' // ***** Script Header *****
' //
' // File:      Hidden.vbs
' //
' // Purpose:   Launching in silent mode
' //
' // ***** End Header *****
' //***************************************************************************

Dim objWshShell
Set objWshShell = WScript.CreateObject("WScript.Shell")
objWshShell.Run "resetSUSClientID.bat", 0, false
Set objWshShell = Nothing


