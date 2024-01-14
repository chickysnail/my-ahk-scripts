#Requires AutoHotkey v2.0

Class LeaderKey{
    leader := ""
    , keys := Map()
    , timeout := 2000
    , boundmeth := {}
    , _enabled := false

    __New(_leader:="!,", _timeout:=2000) {
        this.leader := _leader
        this.timeout := Abs(_timeout)
        this.boundmeth.activate := ObjBindMethod(this, "Activate")
        this.boundmeth.deactivate := ObjBindMethod(this, "Deactivate")
    }

    Enabled {
        Get => this._enabled
        Set {
            if !!Value and !this._enabled
                Hotkey this.leader, this.boundmeth.activate, "On"
            else if !Value and !!this._enabled
                Hotkey this.leader, this.boundmeth.activate, "Off"
            this._enabled := !!Value
        }
    }

    Activate(*) {
        SetTimer this.boundmeth.deactivate, ((-1) * this.timeout)
        for _key, _action in this.keys
            ; MsgBox _action
            HotString _key, _action, "On"
    }

    Deactivate(*) {
        for _key, _action in this.keys
            HotString _key, _action, "Off"
    }

    BindKey(_key, _action) {
        this.keys[_key] := _action
    }
}
