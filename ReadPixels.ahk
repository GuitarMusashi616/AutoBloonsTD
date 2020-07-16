#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force

^z::  ; Control+Alt+Z hotkey.
MouseGetPos, MouseX, MouseY
PixelGetColor, color, %MouseX%, %MouseY%, RGB
MsgBox The color at the current cursor position is %color%.
return

; detecting if tower can be placed:
; see if significant bit of red changes when trying to place tower
; make sure red value is low? (doesnt work in red tower placing environments)
; check pixel location value before putting tower, compare with after putting tower, if sig bit of red doesnt change then it is good (doesn't work for bright red but creators probably avoided this)


; detecting if tower can be bought
; exact same colors in btd adventure time, shaded but similar colors in btd6, determine if grey or green should be easy (grey similar values of r and g and b while green has low r high g low b)
; 0-127 low, 128-255 high
; 0-84 low, 85-169 medium, 170-255 high

;00-54 low, 55-A9 medium, AA-FF high


; queue for buying towers, upgrading towers, changing priority, and selling towers 
; waits only when tower or upgrade can't be bought
; if tower cant be placed at location, finds minimum distance away where tower can be placed
; https://static-api.nkstatic.com/appdocs/16/assets/assets/BATTD_steam_keyboard_hotkeys.png?0.9104274708083326 - btd adventure time hotkeys
; play in 1920x1080 no fullscreen! - optional resizing for resolution possible (not solution yet for fullscreen but not a huge limitation so low priority)

; grey / green detector function
; debug (towers) tells you which towers can be bought and which cannot (how many scrolls that actually do something) input variable for now
; debug (monkey) tells you which upgrade paths available (white $ is buyable, red $ not buyable, assume that locked / not available paths will not be queued)