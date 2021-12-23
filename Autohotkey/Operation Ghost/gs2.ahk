;Stores current Resolution and change to 1080P
;Run DemulShooter otherwise Calibration will not work when running from teknoparrot
;freeplay only works when nothing i set in teknoparrot demulshooting has its own config
;controls for lightgun don't work in teknoparrot when using demul, See documentation for demulshooter
;Testmode in teknoparrot don't save settings, don't waste your time
;Customrez are need for patching the gs2.exe to run 1920x1080
;Very strict rom set are needed, not use of ALL AH exe or other jvc configs in the directory.

run, ..\..\..\Utilities\DemulShooter\DemulShooter.exe -target=ringwide -rom=og
NewRes := Array(32,1920,1080,60)
OldRes := Array(32,A_ScreenWidth,A_ScreenHeight,120)

ChangeResolution( cD, sW, sH, rR ) {
  VarSetCapacity(dM,156,0), NumPut(156,2,&dM,36)
  DllCall( "EnumDisplaySettingsA", UInt,0, UInt,-1, UInt,&dM ), 
  NumPut(0x5c0000,dM,40)
  NumPut(cD,dM,104), NumPut(sW,dM,108), NumPut(sH,dM,112), NumPut(rR,dM,120)
  Return DllCall( "ChangeDisplaySettingsA", UInt,&dM, UInt,0 )
}

ChangeResolution(NewRes[1],NewRes[2],NewRes[3],NewRes[4])

sleep, 1000

run, ..\..\..\Emulators\TeknoParrot Lightgun\TeknoParrotUi.exe --profile=og.xml,,,pid
Winwait, GameRunning
sleep, 1000
winhide, GameRunning

process, wait, SteamChild.exe
sleep,1000
winhide,ahk_exe SteamChild.exe

process, waitclose, % pid
ChangeResolution(OldRes[1],OldRes[2],OldRes[3],OldRes[4])
