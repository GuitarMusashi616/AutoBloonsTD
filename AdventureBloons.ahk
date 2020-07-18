#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force

; https://stackoverflow.com/questions/9224404/get-color-name-by-hex-or-rgb
; brofist strategy:
; +f1 +j1 f1. f1. +p1 +n1 p1, p1. p1. p1. p1m +w1 f1n f1n f1m f1m f1m n1n n1n n1, n1, n1, n1n n1n w1, w1m w1m w1n w1n w1n w1m

; ice king / ice wizard stratty:

; super flame - fp wizard 

SetMouseDelay, 100
Global sleepTime := 300
Global locationText := "f 1768 290 j 1898 288 p 1896 418 n 1768 671 w 1768 801 i 1768 543 g 1898 672 m 1901 802",
Global upgradeLeft := "n 206 313 m 207 479 , 207 642 . 206 807 / 198 964"
Global upgradeRight := "n 1470 314 m 1462 471 , 1467 637 . 1463 801 / 1463 963"

Global currentPage := 0
Global towers := []
Global towerLocations := []
Global leftUpgrades := {}
Global rightUpgrades := {}
Global towerNumber := 1

Global locationQueue := []

class Location {
	__New(X, Y)
	{
		This.X := X
		This.Y := Y
	}
}

saveLocation(locationQueue) {
	MouseGetPos, MouseX, MouseY
	locationQueue.Push(new Location(MouseX, MouseY))
}

class Tower {
	__New(Name, X, Y, Page:=0)
	{
		This.Name := Name
		This.X := X
		This.Y := Y
		This.Page := Page
	}
}

lowMediumHigh(singleColor) {
	if (singleColor < 85)
		return "0"
	else if (singleColor < 170)
		return "1"
	else 
		return "2"
}

processColor(hexColor) {
	; split hex value into magnitude of each color
	R := SubStr(hexColor,3,2)
	G := SubStr(hexColor,5,2)
	B := SubStr(hexColor,7,2)
	Rval := lowMediumHigh(R)
	Gval := lowMediumHigh(G)
	Bval := lowMediumHigh(B)
	return Rval Gval Bval
	; determine low med or high of each value
}

colorDisplacement(hexColor) {
	R2 := 0
	G2 := 255
	B2 := 0
	
	R := SubStr(hexColor,3,2)
	G := SubStr(hexColor,5,2)
	B := SubStr(hexColor,7,2)
	
	;~ MsgBox % Abs(R2-hexToInt(R)) + Abs(G2-hexToInt(G)) + Abs(B2-hexToInt(B))
	return Abs(R2-hexToInt(R)) + Abs(G2-hexToInt(G)) + Abs(B2-hexToInt(B))
}

hexToInt(hex) {
	hex1 := SubStr(hex,1,1)
	hex2 := SubStr(hex,2,1)
	hexArray := {0:0,1:1,2:2,3:3,4:4,5:5,6:6,7:7,8:8,9:9,A:10,B:11,C:12,D:13,E:14,F:15}
	;~ MsgBox % hexArray[hex1]*16+hexArray[hex2]
	return hexArray[hex1]*16+hexArray[hex2]
	
}

divideBy255(hex) {
	;~ hex := Format("{:d}", hex)
	;~ return Round(hex/255, 10)
	int := hexToInt(hex)
	return int/255
}

classifyColor(H,S,L) {
	h := Floor(H)
	s := Floor(S)
	l := Floor(L)
	if (s <= 10 and l >= 90) {
		return "White"
	} else if ((s <= 10 and l <= 70) or s === 0) {
		return "Gray"
	} else if (l <= 15) {
		return "Black"
	} else if ((h >= 0 and h <= 15) or h >= 346) {
		return "Red"
	} else if (h >= 16 and h <= 35) {
		if (s < 90) {
			return "Brown"
		} else {
			return "Orange"
		}
	} else if (h >= 36 and h <= 54) {
		if (s < 90) {
			return "Brown"
		} else {
			return "Yellow"
		}
	} else if (h >= 55 and h <= 165) {
		return "Green"
	} else if (h >= 166 and h <= 260) {
		return "Blue"
	} else if (h >= 261 and h <= 290) {
		return "Purple"
	} else if (h >= 291 and h <= 345) {
		return "Pink"
	}
}

hexRGBtoHSL(hexColor) {
	R := SubStr(hexColor,3,2)
	G := SubStr(hexColor,5,2)
	B := SubStr(hexColor,7,2)
	R := divideBy255(R)
	G := divideBy255(G)
	B := divideBy255(B)
	;~ MsgBox % R G B
	
	maxColor := Max(R,G,B)
	minColor := Min(R,G,B)
	
	L := (maxColor + minColor) / 2
	S := 0
	H := 0
	
	if (maxColor != minColor) {
		if (L < 0.5) {
			S := (maxColor - minColor) / (maxColor + minColor)
		} else {
			S := (maxColor - minColor) / (2.0 - maxColor - minColor)
		}
		if (R == maxColor) {
			H := (G-B) / (maxColor - minColor)
		} else if (G == maxColor) {
			H := 2.0 + (B-R) / (maxColor - minColor)
		} else {
			H := 4.0 + (R-G) / (maxColor - minColor)
		}
	}
	L := L*100
	S := S*100
	H := H*60
	if (H<0)
		H := H+360
	
	;~ MsgBox % R ", " G ", " B " min: " minColor " H: " H " S: " S "L: " L " color: " hexColor
	return classifyColor(H,S,L)
}

scroll(down) {
	MouseMove, 1713, 303
	Loop, 11
		if (down)
			Send {WheelDown}
		else
			Send {WheelUp}
}

tabulateString(string, table, page:=0) {
	wordArray := StrSplit(string, A_Space)
	Loop % wordArray.Length() {
		word := wordArray[A_Index]
		if(StrLen(word) == 1) {
			x := wordArray[A_Index+1]
			y := wordArray[A_Index+2]
			;~ PixelGetColor, color, %x%, %y%, RGB
			;~ MsgBox % word " is " color " which is " hexRGBtoHSL(color)
			table.Push(new Tower(word,x,y,page))
		}
	}
}

remove(name, table) {
	Loop % table.length() {
		;~ MsgBox % A_Index " is " towers[A_Index].name " with "towers[A_Index].X " and " towers[A_Index].Y
		if (table[A_Index].name == name) {
			return table.RemoveAt(A_Index)
		}
	}
	MsgBox % name " not found in " table
	return 0
}

find(Key, table) {
	Loop % table.Length() {
		if (table[A_Index].name == Key)
			return table[A_Index]
	}
	MsgBox % Key " not found in " table
}

waitUntilMatching(X, Y, expectedColor) {
	color := ""
	While (color != expectedColor) {
		PixelGetColor, color, X, Y, RGB
		Sleep, 1000
		;~ msgBox % color
	}
}

waitUntilMatchingName(X, Y, expectedColor) {
	color := ""
	While (color != expectedColor) {
		PixelGetColor, hexColor, X, Y, RGB
		color := hexRGBtoHSL(hexColor)
		;~ msgBox % color
		Sleep, 1000
	}
}

waitForTower(tower) {
	;~ tower := find(key, towerLocations)
	if (currentPage != tower.Page) {
		if (currentPage) {
			scroll(0)
			currentPage := 0
		} else {
			scroll(1)
			currentPage := 1
		}
	}
	waitUntilMatching(tower.X, tower.Y, "0x33BB00")
}

waitForUpgrade(X, Y, Key) {
	if (X > 742) {
		upgrade := find(Key, leftUpgrades)
	} else {
		upgrade := find(Key, rightUpgrades)
	}
	waitUntilMatching(upgrade.X, upgrade.Y, "0xFFFFFF")
}

clickOff() {
	MouseMove 912, 43, 40
	Sleep, sleepTime
	Click
	Sleep, sleepTime
}

placeMonkey(X, Y, Key) {
	Sleep, sleepTime
	letters := "uqwertyzxcvbnasdfghjkl"
	if (StrLen(Key) > 1) {
		Key := SubStr(Key,2,1)
	}
	if (not InStr(letters, Key)) {
		MsgBox % key " is not a valid monkey tower shortcut"
		ExitApp
	}
	waitForTower(Key)
	Send % Key
	Sleep, sleepTime
	MouseMove X, Y, 40
	Sleep, sleepTime
	Click
	Sleep, sleepTime
}

dragPlaceMonkey(iconX, iconY, X, Y) {
	Sleep, sleepTime
	MouseMove iconX-50, iconY-50, 40
	Sleep, sleepTime
	Click
	Sleep, sleepTime
	MouseMove X, Y, 40
	Sleep, sleepTime
	Click
	Sleep, sleepTime
}

upgradeMonkey(X, Y, upgrade) {
	Sleep, sleepTime
	MouseMove X, Y, 40
	Sleep, sleepTime
	Click
	Sleep, sleepTime
	waitForUpgrade(X,Y,upgrade)
	Send % upgrade
	Sleep, sleepTime
	clickOff()
	Sleep, sleepTime
}

sellMonkey(X, Y) {
	Sleep, sleepTime
	MouseMove X, Y, 40
	Sleep, sleepTime
	Click
	Sleep, sleepTime
	Send {BACKSPACE}
	Sleep, sleepTime
}

pressTab(X, Y, tabPresses) {
	Sleep, sleepTime
	MouseMove X, Y, 40
	Sleep, sleepTime
	Click
	Sleep % sleepTime*5
	Loop % tabPresses {
		Send {TAB}
		Sleep % sleepTime*5
	}
	clickOff()
	Sleep, sleepTime
}

startRound() {
	Sleep, sleepTime
	Send {Space}
	Sleep, sleepTime
	Send {Space}
	Sleep, sleepTime
}

priorityShift(X, Y, setPriority, prevPriority = "f") {
	priorities := {f: 0, l: 1, c: 2, s: 3}
	setIndex := priorities[setPriority]
	prevIndex := priorities[prevPriority]
	while (setIndex < prevIndex) {
		setIndex := setIndex + 4
	}
	tabPresses := setIndex - prevIndex
	;~ MsgBox % tabPresses
	pressTab(X, Y, tabPresses)
}


parseString()
{
	; checklist 1) scroll up, 2) put autostart on 3) copy code 4) click back to game, press alt-o, paste, and hit ok
	;~ springSpringCHIMPS := "+q1 1253 601 +x1 1407 675 +u1 295 591 x1, x1, x1/ x1/ +x2 1464 510 x2, x2, q1/ q1/ +q2 564 191 q2/ q2/ +q3 542 967 q3/ q3/ x2/ x2/ +g1 316 528 +g2 320 653 +g3 371 600 +g4 408 541 +g5 396 668 +g6 393 475 g1. g1/ g2. g2/ g3. g3/ g4. g4/ g5. g5/ g6. g6/ +k1 506 542 k1/ +k2 498 647 k2/ k1/ k2/ k1. k1. k2, k2, g1/ g1/ g2/ g2/ g3/ g3/ g4/ g4/ g5/ g5/ g6/ g6/ g1/ g2/ g3/ g4/ g5/ g6/ k1. +f1 465 457 f1, f1/ f1, f1/ f1, f1, +f2 346 711 f2, f2/ f2, f2/ f2, f2, +f3 535 459 f3, f3, f3/ f3/ f3, f3, g1/ +j1 1339 431 j1/ j1/ ~j1 c j1/ j1/ j1. j1. +f4 1426 259 f4, f4, j1/ f4, f4, f4/ f4/"
	InputBox, string, AutoBloons, % "Input a string to describe order of tower placements `n`nie ""1:20 +q1 1245 576 +x1 1403 648 2:35 +q2 284 561 2:46 x1, 3:15 q2/ -q1 ~x1 c 3:30 ~x1 fc"" `n`n - ""1:20"" sets and starts the clock at 1:20 (1 minute 20 seconds), `n - ""+q1 1245 576"" create new tower with q hotkey called q1 at location 1245 576,`n - ""+x1 1403 648"" create new tower with x hotkey at 1403 648 called x1,`n - ""2:35"" waits until the clock is at 2:35,`n - ""+q2 284 561"" create another tower with q hotkey at 284 561 called q2 (""2"" is how many ""q"" towers there are), `n - ""2:46"" waits until clock is at 2:46, `n - ""x1,"" selects tower x1 and presses , (left path upgrade), `n - ""3:15"" waits until 3:15, `n - ""q2/"" selects tower q2 and does right path upgrade, `n - ""-q1"" deletes tower q1, `n - ""~x1 c"" selects tower x1 and shifts priority to close (assuming it's already set to first), `n - ""3:30"" waits until 3:30, `n - ""~x1 fc"" selects tower x1 and shifts priority from close to first",,700,450
	wordArray := StrSplit(string, A_Space)
	
	tabulateString(locationText, towerLocations, 0)
	tabulateString(upgradeLeft, leftUpgrades)
	tabulateString(upgradeRight, rightUpgrades)
	
	if (wordArray.Length() > 1)
  		startRound()
	
	Loop % wordArray.Length() {
		word := wordArray[A_Index]
		; if the word has a + it is a new tower
		if (InStr(word, "+")) {
			X := locationQueue[towerNumber].X
			Y := locationQueue[towerNumber].Y
			name := SubStr(word, 2)
			key := SubStr(word, 2, 1)
			monkey := find(key, towerLocations)
			waitForTower(monkey)
			dragPlaceMonkey(monkey.X, monkey.Y, X, Y)
			towers.push(new Tower(name,X,Y))
			towerNumber := towerNumber + 1
			;~ MsgBox % name " is a tower placement at " X " and " Y 
		}
		; if the word has a ~ it is a priority shift [f,l,c,s]
		; q1 s (change q1 prio to strong), q1 cs (change q1 prio from strong to close)
		else if (InStr(word, "~")) {
			;~ MsgBox % word " is a priority shift"
			acceptable := "flcs"
			nextWord := wordArray[A_Index+1]
			name := SubStr(word, 2)
			to := SubStr(nextWord, 1, 1)
			from := "f"
			if (StrLen(nextWord) > 2) {
				MsgBox % "expected 1 or 2 character string instead got: " nextWord 
				ExitAPP
			}
			else if (StrLen(nextWord) > 1) {
				from := SubStr(nextWord, 2, 1)
			}
			monkey := find(name, towers)
			priorityShift(monkey.X, monkey.Y, to, from)
			;~ MsgBox % monkey.X " and " monkey.Y " going to " to " from " from
			
		}
		; if the word has a - it means sell
		else if (InStr(word, "-")) {
			name := SubStr(word, 2)
			monkey := remove(name, towers)
			;~ MsgBox % "remove monkey at " monkey.X " and " monkey.Y
			sellMonkey(monkey.X, monkey.Y)
			
		}
		; if the word has a [,./] it is an upgrade
		else if (InStr(word, "n") or InStr(word, "m") or InStr(word, ",") or InStr(word, ".") or InStr(word, "/")) {
			;~ MsgBox % word " is an upgrade"
			name := SubStr(word,1,StrLen(word)-1)
			upgrade := SubStr(word,StrLen(word),1)
			monkey := find(name, towers)
			upgradeMonkey(monkey.X, monkey.Y, upgrade)
			;~ MsgBox % "upgrade monkey at " monkey.X " and " monkey.Y " with path "upgrade
		}
	}
	; expects a time first
	; then expects a variable
	; if variable is not recognized then expects x y position and places tower
	; if variable is recognized then expects a , . / following it for the specified upgrade
	; handles consecutive tower placements and upgrades until new time is indicated, waits for specified time (first time sets the time at start)
}

getColor(X, Y) {
	PixelGetColor, color, %X%, %Y%, RGB
	Return color
}

test() {
	
	Loop % towerLocations.Length() {
		MsgBox % towerLocations[A_Index].name ": "getColor(towerLocations[A_Index].X, towerLocations[A_Index].Y)
	}
	
}

;~ tabulateString(locationText, towerLocations, 0)
;~ tabulateString(upgradeLeft, leftUpgrades)
;~ tabulateString(upgradeRight, rightUpgrades)

MsgBox AutoBloons is Running, Press alt-q to mark tower locations and alt-e to begin 
!q::saveLocation(locationQueue)
!w::Reload


!e::parseString()

!^w::ExitApp

^!z::  ; Control+Alt+Z hotkey.
MouseGetPos, MouseX, MouseY
PixelGetColor, color, %MouseX%, %MouseY%, RGB
MsgBox The color at the current cursor position is %color% at %MouseX% and %MouseY%
