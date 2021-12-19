ChangeResolution(Screen_Width := 1920, Screen_Height := 1080, Color_Depth := 32)
{
	VarSetCapacity(Device_Mode,156,0)
	NumPut(156,Device_Mode,36) 
	DllCall( "EnumDisplaySettingsA", UInt,0, UInt,-1, UInt,&Device_Mode )
	NumPut(0x5c0000,Device_Mode,40) 
	NumPut(Color_Depth,Device_Mode,104)
	NumPut(Screen_Width,Device_Mode,108)
	NumPut(Screen_Height,Device_Mode,112)
	Return DllCall( "ChangeDisplaySettingsA", UInt,&Device_Mode, UInt,0 )
}
ChangeResolution(1920, 1080)

maxWindow(title) {
	WinActivate, % title
	WinSet, Style, -0xC00000, % title
	WinSet, Style, -0x40000, % title
	WinSet, AlwaysOnTop, Off, % title
}

;Wait for window before maximize
WinWait, FPS:,, 20  
Sleep 2000
MouseGetPos, , , win
maxWindow("ahk_id" win)
sleep 1000
Sendinput, !{b}
Sleep 60

ScrollLock::
if (flag := !flag) {
	MouseGetPos, , , hwnd
	Gui Cursor:+Owner%hwnd%
	DllCall("ShowCursor", Int,0)
} else {
	DllCall("ShowCursor", Int,1)
}
Return

;Circle Button
	$Space::
	Send {XButton1 down}
	sleep, 60
	Send {XButton1 up}
Return 

;Triangle Button
	$Enter::
	Send {RButton down}
	Sleep, 60
	Send {MButton down}
	Sleep, 60
	Send {MButton up}
	Send {RButton up}
Return

Esc::
	Sendinput, !{b}
	Sleep 1000
	Sendinput, !{b}
	Sleep 1000
	Sendinput, !{f4}
	Process,Close,rpcs3.exe
	ChangeResolution(3440, 1440)
	Sleep 2000
	ExitApp
Return
