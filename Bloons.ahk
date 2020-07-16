#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force

; u hero, q dart, w boomerang, e bomb, r tack, t ice, y glue
; z sniper, x sub, c boat, v plane, b heli, n mortar
; a wizard, s super, d ninja, f alchemist, g druid
; h farm, j spactory, k village, l engi

Global locations := []
Global monkeyTypes := ["q","d","g","d","d","q","d","d","d","d"]
Global lastTime := 0
Global towers := []

saveLocation()
{
	MouseGetPos, xPos, yPos
	locations.push(new XY(xPos, yPos))
	
}

showLocations()
{
	Loop % locations.length()
		MsgBox % locations[A_Index].X ", " locations[A_Index].Y
}

snapLocation()
{
	MouseGetPos, xPos, yPos
	MsgBox % xPos ", " yPos
}

placeMonkey(X, Y, Key) {
	letters := "uqwertyzxcvbnasdfghjkl"
	if (StrLen(Key) > 1) {
		Key := SubStr(Key,2,1)
	}
	if (not InStr(letters, Key)) {
		MsgBox % key " is not a valid monkey tower shortcut"
		ExitApp
	}
	
	Sleep, 100
	MouseMove X, Y, 40
	Sleep, 100
	Send % Key
	Sleep, 100
	Click
	Sleep, 100
	lastTime := lastTime + .4
}

upgradeMonkey(X, Y, upgrade) {
	Sleep, 100
	MouseMove X, Y, 40
	Sleep, 100
	Click
	Sleep, 100
	Send % upgrade
	Sleep, 100
	Send {ESC} 
	Sleep, 100
	lastTime := lastTime + .5
}

sellMonkey(X, Y) {
	Sleep, 100
	MouseMove X, Y, 40
	Sleep, 100
	Click
	Sleep, 100
	Send {BACKSPACE}
	Sleep, 100
	lastTime := lastTime + .4
}

pressTab(X, Y, tabPresses) {
	Sleep, 100
	MouseMove X, Y, 40
	Sleep, 100
	Click
	Sleep, 100
	Loop % tabPresses {
		Send {TAB}
		Sleep, 100
	}
	Send {ESC} 
	Sleep, 100
	lastTime := lastTime + .4 + tabPresses/10
}

startRound() {
	Sleep, 100
	Send {Space}
	Sleep, 100
	Send {Space}
	Sleep, 100
	lastTime := lastTime + .3
}

priorityShift(X, Y, setPriority, prevPriority = "f") {
	priorities := {f: 0, l: 1, c: 2, s: 3}
	setIndex := priorities[setPriority]
	prevIndex := priorities[prevPriority]
	while (setIndex < prevIndex) {
		setIndex := setIndex + 4
	}
	tabPresses := setIndex - prevIndex
	MsgBox % tabPresses
	;~ pressTab(X, Y, tabPresses)
}

class XY {
	__New(X, Y)
	{
		this.X := X
		this.Y := Y
	}
}

class Tower {
	__New(Name, X, Y)
	{
		This.Name := Name
		This.X := X
		This.Y := Y
	}
}

testStruct()
{
	Coords := []
	Coords.Push(new XY(55,120))
	Coords.Push(new XY(190,180))
	
	;~ For index, value in Coords
		;~ MsgBox % "Item " index " is '" value "'"
	
	Loop % Coords.Length()
		MsgBox % Coords[A_Index].X ", " Coords[A_Index].Y
}

convertToSeconds(timeRemaining) {
	minuteSeconds := StrSplit(timeRemaining, ":")
	return minuteSeconds[1]*60+minuteSeconds[2]
}

wait(timeRemaining)
{
	if (lastTime == 0) {
		lastTime := convertToSeconds(timeRemaining)
		startRound()
	}
	else {
		convertedSeconds := convertToSeconds(timeRemaining)
		sleepTime := (convertedSeconds-lastTime)*1000
		Sleep % sleepTime
		lastTime := convertedSeconds
	}
	
}

findMonkey(name, towers) {
	Loop % towers.length() {
		;~ MsgBox % A_Index " is " towers[A_Index].name " with "towers[A_Index].X " and " towers[A_Index].Y
		if (towers[A_Index].name == name) {
			return towers[A_Index]
		}
	}
	MsgBox no monkeys of name %name% were found 
	return 0
}

removeMonkey(name, towers) {
	Loop % towers.length() {
		;~ MsgBox % A_Index " is " towers[A_Index].name " with "towers[A_Index].X " and " towers[A_Index].Y
		if (towers[A_Index].name == name) {
			return towers.RemoveAt(A_Index)
		}
	}
	MsgBox no monkeys of name %name% in towers 
	return 0
}

parseString()
{
	;~ springSpringCHIMPS := "1:20 +q1 1245 576 +x1 1403 648 2:35 +u1 284 561 2:46 x1, 3:15 x1, 3:39 x1/ 4:13 x1/ 4:25 +x2 1451 488 4:31 x2, x2, 4:45 q1/ q1/ 4:50 +q2 557 169 q2/ q2/ 5:04 +q3 531 945 5:11 q3/ q3/ 5:22 x2/ 5:35 x2/ 6:40 +g1 322 502 +g2 298 629 6:49 +g3 361 561 +g4 401 504 +g5 376 627 7:05 +g6 370 441 7:30 g1. g1/ g2. g2/ g3. g3/ g4. g4/ g5. g5/ g6. g6/ 7:44 +k1 494 479 k1/ 8:01 +k2 472 613 8:05 k2/ 8:25 k1/ k2/ 8:30 k1. 8:45 k1. 9:00 k2, k2, 9:45 g1/ g1/ g2/ g2/ g3/ g3/ g4/ g4/ g5/ g5/ g6/ g6/ 10:15 g1/ 10:25 g2/ 10:30 g3/ 10:45 g4/ 11:00 g5/ 11:20 g6/ 12:00 k1. 12:20 +f1 434 408 f1, f1/ f1, f1/ f1, 12:40 f1, 13:15 +f2 548 565 f2, f2/ f2, f2/ f2, f2, 14:10 +f3 586 493 f3, f3, f3/ f3/ f3, f3, 18:30 g1/ 18:50 +j1 1334 388 j1/ j1/ ~j1 c j1/ j1/ j1. j1. 19:13 +f4 1425 225 f4, f4, 21:00 j1/ 21:10 f4, f4, f4/ f4/"
	InputBox, string, AutoBloons, % "Input a string to describe order of tower placements `n`nie ""1:20 +q1 1245 576 +x1 1403 648 2:35 +q2 284 561 2:46 x1, 3:15 q2/ -q1 ~x1 c 3:30 ~x1 fc"" `n`n - ""1:20"" sets and starts the clock at 1:20 (1 minute 20 seconds), `n - ""+q1 1245 576"" create new tower with q hotkey called q1 at location 1245 576, `n - ""2:35"" waits until the clock is 2:35, `n - ""+x1 1403 648"" create new tower with x hotkey at 1403 648 called x1, `n - ""+q2 284 561"" create another tower with q hotkey at 284 561 called q2 (""2"" is how many ""q"" towers there are), `n - ""2:46"" waits until clock is 2:46, `n - ""x1,"" selects tower x1 and presses , (left path upgrade), `n - ""3:15"" waits until 3:15, `n - ""q2/"" selects tower q2 and does right path upgrade, `n - ""-q1"" deletes tower q1, `n - ""~x1 c"" selects tower x1 and shifts priority to close (assuming it's already set to first), `n - ""3:30"" waits until 3:30, `n - ""~x1 fc"" selects tower x1 and shifts priority from close to first",,700,450
	wordArray := StrSplit(string, A_Space)
	
	
	
	Loop % wordArray.Length() {
		word := wordArray[A_Index]
		; if the word has a colon it is time
		if (InStr(word, ":")) {
			;~ MsgBox % word " is time"
			wait(word)
		}
		; if the word has a + it is a new tower
		else if (InStr(word, "+")) {
			X := wordArray[A_Index+1]
			Y := wordArray[A_Index+2]
			placeMonkey(X,Y,word)
			name := SubStr(word, 2)
			towers.push(new Tower(name,X,Y))
			;~ MsgBox % name " is a tower placement at " X " and " Y 
		}
		; if the word has a [,./] it is an upgrade
		else if (InStr(word, ",") or InStr(word, ".") or InStr(word, "/")) {
			;~ MsgBox % word " is an upgrade"
			name := SubStr(word,1,StrLen(word)-1)
			upgrade := SubStr(word,StrLen(word),1)
			monkey := findMonkey(name, towers)
			upgradeMonkey(monkey.X, monkey.Y, upgrade)
			;~ MsgBox % "upgrade monkey at " monkey.X " and " monkey.Y " with path "upgrade
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
			if (StrLen(nextWord) > 2 or not InStr(acceptable, nextWord)) {
				MsgBox % "expected 1 or 2 character string instead got: " nextWord 
				ExitAPP
			}
			else if (StrLen(nextWord) > 1) {
				from := SubStr(nextWord, 2, 1)
			}
			monkey := findMonkey(name, towers)
			priorityShift(monkey.X, monkey.Y, to, from)
			;~ MsgBox % monkey.X " and " monkey.Y " going to " to " from " from
			
		}
		; if the word has a - it means sell
		else if (InStr(word, "-")) {
			name := SubStr(word, 2)
			monkey := removeMonkey(name, towers)
			;~ MsgBox % "remove monkey at " monkey.X " and " monkey.Y
			sellMonkey(monkey.X, monkey.Y)
			
		}
	}
	; expects a time first
	; then expects a variable
	; if variable is not recognized then expects x y position and places tower
	; if variable is recognized then expects a , . / following it for the specified upgrade
	; handles consecutive tower placements and upgrades until new time is indicated, waits for specified time (first time sets the time at start)
}

;~ priorityShift(982,468,"l","c")
; normal close far, todo: spam abilities
MsgBox % "AutoBloons is Running, `n - Press alt-o after starting a match to start placing towers, `n - Press control-o to stop placing towers, `n - Press alt-p to snapshot the x y coordinate of the mouse for use in the input string"
^o::Reload
;~ wait("1:20")
;~ wait("1:30")
!o::parseString()
;~ !a::saveLocation()
;~ !s::showLocations()
!p::snapLocation()