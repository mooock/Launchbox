SendMode input
FullFileName = "%1%"

;Splits path to get basename from full path
SplitPath, FullFileName, name, dir, ext, basename

;Stores current resolution to restore on exit
NewRes := Array(32,1280,960,60)
OldRes := Array(32,A_ScreenWidth,A_ScreenHeight,120)

ChangeResolution( cD, sW, sH, rR ) {
  VarSetCapacity(dM,156,0), NumPut(156,2,&dM,36)
  DllCall( "EnumDisplaySettingsA", UInt,0, UInt,-1, UInt,&dM ), 
  NumPut(0x5c0000,dM,40)
  NumPut(cD,dM,104), NumPut(sW,dM,108), NumPut(sH,dM,112), NumPut(rR,dM,120)
  Return DllCall( "ChangeDisplaySettingsA", UInt,&dM, UInt,0 )
}

ChangeResolution(NewRes[1],NewRes[2],NewRes[3],NewRes[4])

SetWorkingDir "%A_WorkingDir%"

;Copying Nuvee configuration to ini
FileCopy, NuveeProfiles\%basename%.ini, inis\nuvee_ps2_usb_guncon1.ini, 1

;Run rom file from launchbox
run,pcsx2.exe --nogui --fullscreen "%1%","%A_WorkingDir%"

;will try to run load from save state
winactivate, ahk_exe pcsx2.exe
sleep 10000
sendinput, {F3}

$Esc::
    Process,Close,pcsx2.exe
    ChangeResolution(OldRes[1],OldRes[2],OldRes[3],OldRes[4])
    ExitApp
Return

Process, WaitClose, pcsx2.exe
ChangeResolution(OldRes[1],OldRes[2],OldRes[3],OldRes[4])
