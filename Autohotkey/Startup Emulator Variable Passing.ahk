;Support for relative Path of the Rom file
;
;Applicaton Path = C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
;Application Parameters = -noprofile -command "Set-Clipboard '%romfile%';sleep 5"
;
;Emulator Settings
;full path without quotes
;Attempt to hide window on startup/Shutdown
;
;Tweak the timing if the copy to paste buffer takes longer then expected

Emulatorexe := "\..\..\emulators\M2emulatorLightgun\emulator_multicpu.exe"

Sleep, 3000
FullFileName := clipboard
   
; To fetch only the bare filename from the above:
SplitPath, FullFileName, name

; To fetch only its directory:
SplitPath, FullFileName,, dir

; To fetch all info:
SplitPath, FullFileName, name, dir, ext, name_no_ext, drive
   
; The above will set the variables as follows:
; name = Address List.txt
; dir = C:\My Documents
; ext = txt
; name_no_ext = Address List
; drive = C:

;Workingdir := emupath
Gamename := name_no_ext,

SplitPath, Emulatorexe,, Workingdir

Run %dir%%Emulatorexe% %Gamename%,%dir%%workingdir%
