;Use AHK Window Spy to find the pixel information then uncomment the two lines for getting the correct pixel color
;PixelGetColor, pixel1, 804, 325, RGB
;msgbox, % found pixel  pixel1

;Screen:	805, 325 (less often used)
;Window:	804, 325 (default)
;Client:	804, 325 (recommended)
;Color:	940F19 (Red=94 Green=0F Blue=19)

loop,
{
PixelGetColor, pixel1, 804, 325, RGB
winactivate, ahk_exe gs2.exe
sleep,1000
;msgbox, % pixel1
;Msgbox, % pixel1
if pixel1 = 0x940F19
break	
}

;Send 1 to the active window
msgbox, % found pixel  pixel1
send,1
