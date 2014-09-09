; Remus Juncu | http://remusjuncu.com/
; ! alt | ^ ctrl | + shift | # win

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force

#Persistent
#include com.ahk
#include VA.ahk

SetBatchLines, 1ms
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

COM_Init()

volume := VA_GetMasterVolume() ; get the master volume of the default playback device.
volume :=ceil(volume) ; round volume to integer
mute := VA_GetMasterMute()

countFolderLoop := 1
loopFolderName:
   newFolderName := countFolderLoop
IfExist, % newFolderName
{
   countFolderLoop++
   Goto, loopFolderName
}
IfNotExist, % newFolderName
{
   FileCreateDir, %newFolderName%
}

Menu, tray, NoStandard
Menu, tray, add, OpenFolder, MenuOpenFolder ; Creates a new menu item.
Menu, tray, add ; Creates a separator line.
Menu, tray, add, Shortcuts, shortcuts ; Creates a new menu item.
Menu, tray, add, Website, website ; Creates a new menu item.
Menu, tray, add, About, about ; Creates a new menu item.
Menu, tray, add ; Creates a separator line.
Menu, tray, add, Refresh, doReload ; Reload the script.
Menu, tray, Default, OpenFolder
Menu, tray, add, Exit, doExit

TrayTip, ScreenShooter, Made by Remus Gabriel Juncu - http://remusjuncu.com/, 1, 1

OnExit, ExitSub
Return

MenuOpenFolder:
   Run, %newFolderName%
Return

shortcuts:
   ;SplashTextOn,,, A MsgBox is about to appear.
   ;Sleep 3000
   ;SplashTextOff
   MsgBox , 0, ScreenShooter Help, Pause = Print Screen`n`nAlt + Pause = Window Print Screen`n`nScrollLock = Open ScreenShoot folder.`n`nShift + ScrollLock = Add to Clipboard the folder path.`n`nCapsLock = Backspace`n`nCtrl + CapsLock = Mute`n`nCtrl + Up = Volume Up`n`nCtrl + Down = Volume Down`n`nWinKey + T = Toggle active window on top`n`nCtrl + Alt + NumPad0 = Paste 50 times (IM spam)`n`nCtrl + Numpad0 = Toggle TaskBar.'n'nCtrl + NumpadDot = Lock Pc.'n'nCtrl + V = Paste in CMD`n`nCtrl + W = Close CMD`n`nCtrl + Shift + SpaceBar = Enter`n`n`nMade by Remus Juncu`nhttp://remusjuncu.com/,
   ;TrayTip, Help, Pause=PrintScreen | alt+Pause=WindowPrintScreen | ctrl+shift+space=Enter | CapsLock=Backspace | ctrl+CapsLock=Mute | ctrl+up/down=volume up/down, 5, 1
Return

website:
   Run,% "http://remusjuncu.com/"
Return

about:
   TrayTip, ScreenShooter, Made by Remus Gabriel Juncu - http://remusjuncu.com/, 3, 1
Return

doReload:
   Reload
Return

doExit:
ExitApp

;~ #UseHook
;~ #InstallKeybdHook

; ScreenShooter Shortcuts -----------------------------------------------------------------
; Pause - Capture Screen.
Pause::
{
   countLoop := 1 ; Reset counter.
   loopFileName: ; Repeat until we have unused name for file.
   countLoopString := countLoop ; Reset string.
   newFileName := newFolderName "\screen" countLoopString ".jpg" ; Form the name of new file.
   IfExist, % newFileName ; Check if file name is taken.
   {
      countLoop++
      Goto, loopFileName
   }
   CaptureScreen(0, True, newFileName, 100) ; Capture screenshot.
   Return
}
Return

; Alt+Pause - Capture current window.
!Pause::
{
   countLoop2 := 1
   loopFileName2:
   countLoopString2 := countLoop2
   newFileName2 := newFolderName "\screen" countLoopString2 ".jpg"
   IfExist, % newFileName2
   {
      countLoop2++
      Goto, loopFileName2
   }
   CaptureScreen(1, True, newFileName2, 100)
   Return
}
Return

; ScrollLock - Open image folder.
ScrollLock::
Run, %newFolderName%
Return

; Shift ScrollLock - Copy to clipboard image folder path.
+ScrollLock::
clipboard = %A_ScriptDir%\%newFolderName%
Return

; Lock,
; Lock SC106 (-1) -- old keyboard
;~ Numpad0 & NumpadDot::
^NumpadDot::
   Run, rundll32.exe user32.dll LockWorkStation
   Sleep, 666
   SendMessage, 0x112, 0xF170, 2,, Program Manager ; monitors sleep
Return

; Unhide taskbar (-2) ;~ SC10A
^Numpad0::
if toggle := !toggle {
	WinHide,ahk_class Shell_TrayWnd
	WinHide,Start ahk_class Button
} else {
	WinShow,ahk_class Shell_TrayWnd
	WinShow,Start ahk_class Button
}
Return

; Close Window SC108 (x button (-4))
;~ SC108::
   ;~ Send !{F4}
   ;WinGetTitle, Title, A
   ;winclose, %title% 
;~ Return

; Ctrl + Alt + Numpad0 - Paste 50 times (spam).
^!Numpad0::
Loop 50 {
   Send ^v
   Send {Enter}
}
Return

; Win+T - toggle the active window on top
#t:: WinSet, AlwaysOnTop, Toggle, A

; CapsLock - BackSpace
CapsLock::BackSpace
Return

; Ctrl + Shift + Space - Enter
^+Space::
   Send {Enter}
Return

; Ctrl + CapsLock - Mute. ;~ ^Numpad1::
; ^CapsLock::
LControl & CapsLock::
   if VA_GetMasterMute() = mute 
   {
      VA_SetMute(True)
      Return
   }
   else
   {
      VA_SetMute(False)
      Return
   }
Return

/*
; Volume control (turn master volume up and down with Ctrl-Alt-Up/Down and 
; toggle mute with Ctrl-Alt-.)
^!Up::Send {Volume_Up}
^!Down::Send {Volume_Down}
^!.::Send {Volume_Mute}
*/

; Ctrl + Up - Volume Up.
; ^Up::
RControl & Up::
if volume = 100
{
   Return
}
if volume <= 99
{
   VA_SetMasterVolume(volume++)
/*
   VA_SetMasterVolume(volume++)
   VA_SetMasterVolume(volume++)
   VA_SetMasterVolume(volume++)
   VA_SetMasterVolume(volume++)
*/
   if volume > 1
   {
      VA_SetMute(False)
   }
   Return
}
Return

; Ctrl + Down - Volume Down.
; ^Down::
RControl & Down::
if volume = 0
{
   VA_SetMute(True)
   Return
}
if volume > .01
{
   VA_SetMasterVolume(volume--)
/*
   VA_SetMasterVolume(volume--)
   VA_SetMasterVolume(volume--)
   VA_SetMasterVolume(volume--)
   VA_SetMasterVolume(volume--)
*/
   Return
}
Return

; Ctrl + V - Paste in command window.
#IfWinActive ahk_class ConsoleWindowClass
^V::
   SendInput {Raw}%clipboard%
return

; Ctrl + W - Close Command Window.
$^w::
   WinGetTitle sTitle
   If (InStr(sTitle, "-")=0) { 
      Send EXIT{Enter}
   } else {
      Send ^w
   }
Return
;~ #IfWinActive ;~~ !?

Exit

; On exit delete folder if empty.
ExitSub:
; if A_ExitReason not in Logoff,Shutdown   Avoid spaces around the comma in this line.
{
   SetBatchLines, -1  ; Make the operation run at maximum speed.
   /*
   FolderSizeKB = 0
   Loop, %newFolderName%\*.*, , 1
       FolderSizeKB += %A_LoopFileSizeKB%
   if (%FolderSizeKB% = 0) 
   */
   FileRemoveDir, %newFolderName%
}
ExitApp  ; The only way for an OnExit script to terminate itself is to use ExitApp in the OnExit subroutine.
/*
Esc::
SetCapsLockState, off
Suspend On
Send, {ESC}
Suspend Off
return
*/
/*
 *-------------------------------------------------------------------------------------
 *   Screen Capture with Transparent Windows and Mouse Cursor:
 *         http://www.autohotkey.com/forum/topic18146.html
 *-------------------------------------------------------------------------------------
   CaptureScreen(aRect, bCursor, sFileTo, nQuality)
      1) If the optional parameter bCursor is True, captures the cursor too.
      2) If the optional parameter sFileTo is 0, set the image to Clipboard.
         If it is omitted or "", saves to screen.bmp in the script folder,
         otherwise to sFileTo which can be BMP/JPG/PNG/GIF/TIF.
      3) The optional parameter nQuality is applicable only when sFileTo is JPG. Set it to the desired quality level of the resulting JPG, an integer between 0 - 100.
      4) If aRect is 0/1/2/3, captures the entire desktop/active window/active client area/active monitor.
      5) aRect can be comma delimited sequence of coordinates, e.g., "Left, Top, Right, Bottom" or "Left, Top, Right, Bottom, Width_Zoomed, Height_Zoomed".
         In this case, only that portion of the rectangle will be captured. Additionally, in the latter case, zoomed to the new width/height, Width_Zoomed/Height_Zoomed.

   Example:
      CaptureScreen(0)
      CaptureScreen(1)
      CaptureScreen(2)
      CaptureScreen(3)
      CaptureScreen("100, 100, 200, 200")
      CaptureScreen("100, 100, 200, 200, 400, 400")   ; Zoomed

   Convert:
      Convert(sFileFr, sFileTo, nQuality)
      Convert("C:\image.bmp", "C:\image.jpg")
      Convert("C:\image.bmp", "C:\image.jpg", 95)
      Convert(0, "C:\clip.png")   ; Save the bitmap in the clipboard to sFileTo if sFileFr is "" or 0.
*/

/*
pToken := Gdip_Startup()
Gdip_SaveBitmapToFile(pBitmap := Gdip_BitmapFromScreen(), A_Now ".jpg")
Gdip_DisposeImage(pBitmap)
Gdip_Shutdown(pToken)
*/

;CaptureScreen()
;Return

CaptureScreen(aRect = 0, bCursor = false, sFile = "", nQuality = "")
{
   If   !aRect
   {
      SysGet, nL, 76
      SysGet, nT, 77
      SysGet, nW, 78
      SysGet, nH, 79
   }
   Else If   aRect = 1
      WinGetPos, nL, nT, nW, nH, A
   Else If   aRect = 2
   {
      WinGet, hWnd, ID, A
      VarSetCapacity(rt, 16, 0)
      DllCall("GetClientRect" , "Uint", hWnd, "Uint", &rt)
      DllCall("ClientToScreen", "Uint", hWnd, "Uint", &rt)
      nL := NumGet(rt, 0, "int")
      nT := NumGet(rt, 4, "int")
      nW := NumGet(rt, 8)
      nH := NumGet(rt,12)
   }
   Else If   aRect = 3
   {
      VarSetCapacity(mi, 40, 0)
      DllCall("GetCursorPos", "int64P", pt)
      DllCall("GetMonitorInfo", "Uint", DllCall("MonitorFromPoint", "int64", pt, "Uint", 2), "Uint", NumPut(40,mi)-4)
      nL := NumGet(mi, 4, "int")
      nT := NumGet(mi, 8, "int")
      nW := NumGet(mi,12, "int") - nL
      nH := NumGet(mi,16, "int") - nT
   }
   Else
   {
      StringSplit, rt, aRect, `,, %A_Space%%A_Tab%
      nL := rt1
      nT := rt2
      nW := rt3 - rt1
      nH := rt4 - rt2
      znW := rt5
      znH := rt6
   }

   mDC := DllCall("CreateCompatibleDC", "Uint", 0)
   hBM := CreateDIBSection(mDC, nW, nH)
   oBM := DllCall("SelectObject", "Uint", mDC, "Uint", hBM)
   hDC := DllCall("GetDC", "Uint", 0)
   DllCall("BitBlt", "Uint", mDC, "int", 0, "int", 0, "int", nW, "int", nH, "Uint", hDC, "int", nL, "int", nT, "Uint", 0x40000000 | 0x00CC0020)
   DllCall("ReleaseDC", "Uint", 0, "Uint", hDC)
   If   bCursor
      CaptureCursor(mDC, nL, nT)
   DllCall("SelectObject", "Uint", mDC, "Uint", oBM)
   DllCall("DeleteDC", "Uint", mDC)
   If   znW && znH
      hBM := Zoomer(hBM, nW, nH, znW, znH)
   If   sFile = 0
      SetClipboardData(hBM)
   Else   Convert(hBM, sFile, nQuality), DllCall("DeleteObject", "Uint", hBM)
}

CaptureCursor(hDC, nL, nT)
{
   VarSetCapacity(mi, 20, 0)
   mi := Chr(20)
   DllCall("GetCursorInfo", "Uint", &mi)
   bShow   := NumGet(mi, 4)
   hCursor := NumGet(mi, 8)
   xCursor := NumGet(mi,12)
   yCursor := NumGet(mi,16)

   VarSetCapacity(ni, 20, 0)
   DllCall("GetIconInfo", "Uint", hCursor, "Uint", &ni)
   xHotspot := NumGet(ni, 4)
   yHotspot := NumGet(ni, 8)
   hBMMask  := NumGet(ni,12)
   hBMColor := NumGet(ni,16)

   If   bShow
      DllCall("DrawIcon", "Uint", hDC, "int", xCursor - xHotspot - nL, "int", yCursor - yHotspot - nT, "Uint", hCursor)
   If   hBMMask
      DllCall("DeleteObject", "Uint", hBMMask)
   If   hBMColor
      DllCall("DeleteObject", "Uint", hBMColor)
}

Zoomer(hBM, nW, nH, znW, znH)
{
   mDC1 := DllCall("CreateCompatibleDC", "Uint", 0)
   mDC2 := DllCall("CreateCompatibleDC", "Uint", 0)
   zhBM := CreateDIBSection(mDC2, znW, znH)
   oBM1 := DllCall("SelectObject", "Uint", mDC1, "Uint",  hBM)
   oBM2 := DllCall("SelectObject", "Uint", mDC2, "Uint", zhBM)
   DllCall("SetStretchBltMode", "Uint", mDC2, "int", 4)
   DllCall("StretchBlt", "Uint", mDC2, "int", 0, "int", 0, "int", znW, "int", znH, "Uint", mDC1, "int", 0, "int", 0, "int", nW, "int", nH, "Uint", 0x00CC0020)
   DllCall("SelectObject", "Uint", mDC1, "Uint", oBM1)
   DllCall("SelectObject", "Uint", mDC2, "Uint", oBM2)
   DllCall("DeleteDC", "Uint", mDC1)
   DllCall("DeleteDC", "Uint", mDC2)
   DllCall("DeleteObject", "Uint", hBM)
   Return   zhBM
}

Convert(sFileFr = "", sFileTo = "", nQuality = "")
{
   If   sFileTo  =
      sFileTo := A_ScriptDir . "\screen.bmp"
   SplitPath, sFileTo, , sDirTo, sExtTo, sNameTo

   If Not   hGdiPlus := DllCall("LoadLibrary", "str", "gdiplus.dll")
      Return   sFileFr+0 ? SaveHBITMAPToFile(sFileFr, sDirTo . "\" . sNameTo . ".bmp") : ""
   VarSetCapacity(si, 16, 0), si := Chr(1)
   DllCall("gdiplus\GdiplusStartup", "UintP", pToken, "Uint", &si, "Uint", 0)

   If   !sFileFr
   {
      DllCall("OpenClipboard", "Uint", 0)
      If    DllCall("IsClipboardFormatAvailable", "Uint", 2) && (hBM:=DllCall("GetClipboardData", "Uint", 2))
      DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Uint", hBM, "Uint", 0, "UintP", pImage)
      DllCall("CloseClipboard")
   }
   Else If   sFileFr Is Integer
      DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Uint", sFileFr, "Uint", 0, "UintP", pImage)
   Else   DllCall("gdiplus\GdipLoadImageFromFile", "Uint", Unicode4Ansi(wFileFr,sFileFr), "UintP", pImage)

   DllCall("gdiplus\GdipGetImageEncodersSize", "UintP", nCount, "UintP", nSize)
   VarSetCapacity(ci,nSize,0)
   DllCall("gdiplus\GdipGetImageEncoders", "Uint", nCount, "Uint", nSize, "Uint", &ci)
   Loop, %   nCount
      If   InStr(Ansi4Unicode(NumGet(ci,76*(A_Index-1)+44)), "." . sExtTo)
      {
         pCodec := &ci+76*(A_Index-1)
         Break
      }
   If   InStr(".JPG.JPEG.JPE.JFIF", "." . sExtTo) && nQuality<>"" && pImage && pCodec
   {
   DllCall("gdiplus\GdipGetEncoderParameterListSize", "Uint", pImage, "Uint", pCodec, "UintP", nSize)
   VarSetCapacity(pi,nSize,0)
   DllCall("gdiplus\GdipGetEncoderParameterList", "Uint", pImage, "Uint", pCodec, "Uint", nSize, "Uint", &pi)
   Loop, %   NumGet(pi)
      If   NumGet(pi,28*(A_Index-1)+20)=1 && NumGet(pi,28*(A_Index-1)+24)=6
      {
         pParam := &pi+28*(A_Index-1)
         NumPut(nQuality,NumGet(NumPut(4,NumPut(1,pParam+0)+20)))
         Break
      }
   }

   If   pImage
      pCodec   ? DllCall("gdiplus\GdipSaveImageToFile", "Uint", pImage, "Uint", Unicode4Ansi(wFileTo,sFileTo), "Uint", pCodec, "Uint", pParam) : DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Uint", pImage, "UintP", hBitmap, "Uint", 0) . SetClipboardData(hBitmap), DllCall("gdiplus\GdipDisposeImage", "Uint", pImage)

   DllCall("gdiplus\GdiplusShutdown" , "Uint", pToken)
   DllCall("FreeLibrary", "Uint", hGdiPlus)
}

CreateDIBSection(hDC, nW, nH, bpp = 32, ByRef pBits = "")
{
   NumPut(VarSetCapacity(bi, 40, 0), bi)
   NumPut(nW, bi, 4)
   NumPut(nH, bi, 8)
   NumPut(bpp, NumPut(1, bi, 12, "UShort"), 0, "Ushort")
   NumPut(0,  bi,16)
   Return   DllCall("gdi32\CreateDIBSection", "Uint", hDC, "Uint", &bi, "Uint", 0, "UintP", pBits, "Uint", 0, "Uint", 0)
}

SaveHBITMAPToFile(hBitmap, sFile)
{
   DllCall("GetObject", "Uint", hBitmap, "int", VarSetCapacity(oi,84,0), "Uint", &oi)
   hFile:=   DllCall("CreateFile", "Uint", &sFile, "Uint", 0x40000000, "Uint", 0, "Uint", 0, "Uint", 2, "Uint", 0, "Uint", 0)
   DllCall("WriteFile", "Uint", hFile, "int64P", 0x4D42|14+40+NumGet(oi,44)<<16, "Uint", 6, "UintP", 0, "Uint", 0)
   DllCall("WriteFile", "Uint", hFile, "int64P", 54<<32, "Uint", 8, "UintP", 0, "Uint", 0)
   DllCall("WriteFile", "Uint", hFile, "Uint", &oi+24, "Uint", 40, "UintP", 0, "Uint", 0)
   DllCall("WriteFile", "Uint", hFile, "Uint", NumGet(oi,20), "Uint", NumGet(oi,44), "UintP", 0, "Uint", 0)
   DllCall("CloseHandle", "Uint", hFile)
}

SetClipboardData(hBitmap)
{
   DllCall("GetObject", "Uint", hBitmap, "int", VarSetCapacity(oi,84,0), "Uint", &oi)
   hDIB :=   DllCall("GlobalAlloc", "Uint", 2, "Uint", 40+NumGet(oi,44))
   pDIB :=   DllCall("GlobalLock", "Uint", hDIB)
   DllCall("RtlMoveMemory", "Uint", pDIB, "Uint", &oi+24, "Uint", 40)
   DllCall("RtlMoveMemory", "Uint", pDIB+40, "Uint", NumGet(oi,20), "Uint", NumGet(oi,44))
   DllCall("GlobalUnlock", "Uint", hDIB)
   DllCall("DeleteObject", "Uint", hBitmap)
   DllCall("OpenClipboard", "Uint", 0)
   DllCall("EmptyClipboard")
   DllCall("SetClipboardData", "Uint", 8, "Uint", hDIB)
   DllCall("CloseClipboard")
}

Unicode4Ansi(ByRef wString, sString)
{
   nSize := DllCall("MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", 0, "int", 0)
   VarSetCapacity(wString, nSize * 2)
   DllCall("MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", &wString, "int", nSize)
   Return   &wString
}

Ansi4Unicode(pString)
{
   nSize := DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "Uint", 0, "int",  0, "Uint", 0, "Uint", 0)
   VarSetCapacity(sString, nSize)
   DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "str", sString, "int", nSize, "Uint", 0, "Uint", 0)
   Return   sString
}


/*
 *====================================================================================
 *                           END OF FILE
 *====================================================================================
 */