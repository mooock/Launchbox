Gamename := "Hodzero-Win64-Shipping.exe"
Gamepath := "Hodzero\WindowsNoEditor\Hodzero\Binaries\Win64"

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

runwait,%a_scriptdir%\%Gamepath%\%Gamename%,%a_scriptdir%\%Gamepath%

$Esc::
    ChangeResolution(OldRes[1],OldRes[2],OldRes[3],OldRes[4])
       Process, Close, amdaemon.exe
       Process, Close, Hodzero-Win64-Shipping.exe
    ExitApp
return
