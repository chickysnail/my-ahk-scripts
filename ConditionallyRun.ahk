#Requires AutoHotkey v2.0
#Include "LED.ahk"
; global PersionLayout := False


#SuspendExempt True ; all code below will NOT suspend
#n:: Run "notepad.exe"
\::Enter
; CapsLock's led will indicate script is suspended
; Key pressing order MATTERS!
RControl & LControl::{ 
    KeyboardLED(7, "on")
    Suspend 1
    MsgBox "Scripts are suspended"
}
LControl & RControl::{
    KeyboardLED(7, "off")
    Suspend 0
    MsgBox "Scripts are working"
}
#SuspendExempt False ; all code below WILL suspend

; set capslock to behave as ctrl in all cases
*CapsLock::
{
    Send "{LControl down}"
}
*CapsLock up::
{
    Send "{LControl Up}"
    SetCapsLockState "Off"
}
; CapsLock::lCtrl


; Activate many hotstrings for 3 seconds when Win+b is pressed
#Include "LeaderKey_class.ahk"
win_b_leader := LeaderKey("#b", 3000)
win_b_leader.Enabled := True

win_b_leader.BindKey(
    ":?*X:test",
    (*)=> ( MsgBox("Hotstring is working") )
)
win_b_leader.BindKey(
    ":?*:docs",
    (*)=> ( Run("brave.exe https://docs.google.com/spreadsheets/d/18kTAcfDE3Z4FOM1lNQoPtnrduPY5JyktCuBFtmVHfKs/edit?ouid=104958673030297823946&usp=sheets_home&ths=true") )
)
win_b_leader.BindKey(
    ":*:artem",
    "artem.m.tronin@gmail.com"
)
