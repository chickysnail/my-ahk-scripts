#Requires AutoHotkey v2.0
Persistent

secondsMultiplier := 60 ; if set to 60, the precision of timer is one minute
app := "ahk_exe javaw.exe"
threadPriority := 21474836 ; if set to 0, will not work with some games (see: ahk setTimer priority)

play := PlayTimer()
rest := RestTimer()

Loop {
if WinWaitActive(app) 
    if rest.Enough() {
        play.allow := True
        play.count := 0
        OutputDebug "play timer is set to 0"
    }
    if play.allow
    {
        OutputDebug "You are allowed to play"
        play.Start
        rest.Stop
        rest.count := 0
    }
    else
    {
        OutputDebug "Not allowed to play yet. Wait " rest.allowLimit-rest.count " intervals" 
        WinKill app 
        MsgBox "Подожди еще"
    }
 
if WinWaitNotActive(app) ;
    play.Stop
    rest.Start
    OutputDebug "App is not active. play=" play.count ", rest=" rest.count
}


class RestTimer {
    __New(){
        this.allowLimit := 15
        
        this.interval := 1000 * secondsMultiplier
        this.count := 0
        ; Tick() has an implicit parameter "this" which is a reference to
        ; the object, so we need to create a function which encapsulates
        ; "this" and the method to call:
        this.timer := ObjBindMethod(this, "Tick")
    }
    Enough() {
        if this.count >= this.allowLimit 
            return True
        return False
    }
    Start() {
        SetTimer this.timer, this.interval, threadPriority
        ; ToolTip "rest Counter started"
    }
    Stop() {
        ; To turn off the timer, we must pass the same object as before:
        SetTimer this.timer, 0, threadPriority
        ; ToolTip "rest Counter stopped at " this.count
    }
    Tick(){
        ++this.count
        DebugUpdate()
        ; ToolTip this.count
    }
}

class PlayTimer {
    __New(){
        this.warningLimit := 70
        this.limit := 76
        this.warning := "Приложение закроется через " this.limit-this.count " минут! Лучше выйти сейчас, чтобы сохраниться"
        this.allow := True

        this.interval := 1000 * secondsMultiplier
        this.count := 0

        ; Tick() has an implicit parameter "this" which is a reference to
        ; the object, so we need to create a function which encapsulates
        ; "this" and the method to call:
        this.timer := ObjBindMethod(this, "Tick")
    }
    Start() {
        SetTimer this.timer, this.interval, threadPriority
        ; ToolTip "Counter started"
    }
    Stop() {
        ; To turn off the timer, we must pass the same object as before:
        SetTimer this.timer, 0, threadPriority
        ; ToolTip "Counter stopped at " this.count
    }
    Tick(){
        ++this.count
        ; ToolTip this.count
        if this.count = this.warningLimit
            MsgBox this.warning
        if this.count = this.limit {
            this.count := 0
            this.allow := False
            WinClose app
            
            SetTimer () => EnsureClose() , -5000, threadPriority
            
            MsgBox "Приложение было закрыто автоматически"
        }
        DebugUpdate()
    }
    
}
EnsureClose(){
    if WinExist(app)
        WinKill 
    play.count := 0
}

DebugUpdate(){
    OutputDebug "CURRENT STATUS:"
    OutputDebug "play.count = " play.count
    OutputDebug "rest.count = " rest.count
    OutputDebug "play.allow = " play.allow
    OutputDebug "rest.Enough() = " rest.Enough()
}