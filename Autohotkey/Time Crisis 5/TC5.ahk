;Do not change DPI settings to application as many guides says on the exe file or it will mess up the shooting ingame
;No not use virtual Keys in Demulshooting
;Don't Activate player two in demulshooter

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

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

SetWorkingDir "%A_WorkingDir%"

Run, Util\DemulShooter\demulshooterX64.exe -target=es3 -rom=tc5,"%A_WorkingDir%"
sleep, 2000

Run, TC5\Binaries\Win64\TimeCrisisGame-Win64-Shipping.exe -NOINI -Language=JPN -playside=1,"%A_WorkingDir%"

;Right Pedal
1::y

;Left Pedal
space::t

;Insert Coin
up::<+t

;Crosshair On/Off
5::<+h

;Middel Mouse
down::c

;Bypass screen button
MButton::
WheelUpDown:                        
    Send,{WheelDown 1}
Return

$Esc::
    ChangeResolution(OldRes[1],OldRes[2],OldRes[3],OldRes[4])
    Process,Close,TimeCrisisGame-Win64-Shipping.exe
    sleep, 2000
    Process,Close,biped2.exe
    ExitApp
return
