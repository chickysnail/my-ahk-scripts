KeyboardLED(LEDvalue, Cmd, Kbd := 0)
{
	fn := SetUnicodeStr("\Device\KeyBoardClass" Kbd)
	h_device := NtCreateFile(fn, 0+0x00000100+0x00000080+0x00100000, 1, 1, 0x00000040+0x00000020, 0)

	If Cmd == "switch"	;switches every LED according to LEDvalue
		KeyLED := LEDvalue
	If Cmd == "on"	;forces all choosen LED's to ON (LEDvalue= 0 ->LED's according to keystate)
		KeyLED := LEDvalue | (GetKeyState("ScrollLock", "T") + 2 * GetKeyState("NumLock", "T") + 4 * GetKeyState("CapsLock", "T"))
	If Cmd == "off"	;forces all choosen LED's to OFF (LEDvalue= 0 ->LED's according to keystate)
	{
		LEDvalue := LEDvalue ^ 7
		KeyLED := LEDvalue & (GetKeyState("ScrollLock", "T") + 2 * GetKeyState("NumLock", "T") + 4 * GetKeyState("CapsLock", "T"))
	}

	success := DllCall("DeviceIoControl"
			, "Ptr", h_device
			, "UInt", CTL_CODE(0x0000000b	; FILE_DEVICE_KEYBOARD
				, 2
				, 0	; METHOD_BUFFERED
				, 0)	; FILE_ANY_ACCESS
			, "Int*", KeyLED << 16
			, "UInt", 4
			, "Ptr", 0
			, "UInt", 0
			, "Ptr*", output_actual := 0
			, "Ptr", 0)

	NtCloseFile(h_device)
	Return success
}

CTL_CODE(p_device_type, p_function, p_method, p_access)
{
	Return (p_device_type << 16) | (p_access << 14) | (p_function << 2) | p_method
}

NtCreateFile(wfilename, desiredaccess, sharemode, createdist, flags, fattribs)
{
	objattrib := Buffer(6 * A_PtrSize, 0)
	io := Buffer(2 * A_PtrSize, 0)
	pus := Buffer(2 * A_PtrSize)

	DllCall("ntdll\RtlInitUnicodeString", "Ptr", pus, "Ptr", wfilename)
	NumPut("UInt", 6 * A_PtrSize, objattrib, 0)
	NumPut("UInt", pus.Ptr, objattrib, 2 * A_PtrSize)

	status := DllCall("ntdll\ZwCreateFile",
				"Ptr*", &fh := 0,
				"UInt", desiredaccess,
				"Ptr", objattrib, 
				"Ptr", io,
				"Ptr", 0,  ; AllocationSize
				"UInt", fattribs,
				"UInt", sharemode,
				"UInt", createdist, 
				"UInt", flags,  ; CreateOptions
				"Ptr", 0,  ; EaBuffer
				"UInt", 0,  ; EaLength
				"UInt")

	Return fh
}

NtCloseFile(handle)
{
	Return DllCall("ntdll\ZwClose", "Ptr", handle)
}

SetUnicodeStr(str)
{
	out := Buffer(2 * StrPut(str, "UTF-16"))
	StrPut(str, out, "UTF-16")
	Return out
}

Test(str){
	MsgBox str
}