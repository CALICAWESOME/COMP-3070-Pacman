INCLUDE Irvine32.inc

.data

	gameoverMessage db "Pacman is kill. You suck.",0
	mapSize dd 1736				; TODO: un-hardcode this
	pacXCoord db 28				; byte used to hold the X-coordinate of PacMan
	pacYCoord db 23				; byte used to hold the Y-coordinate of PacMan
	pacChar1 db ">"
	pacChar2 db "'"
	moveInst dd MovePacLeft		; holds address of movePacman instruction to execute
	moveCache dd MovePacLeft	; holds backup movement instruction in case moveInst is not possible
	fixRightTube db 0
	fixLeftTube db 0
	gameIsOver db 0

	G1XCoord db 26
	G1YCoord db 11
	G1moveInst dd MoveG1Up	; holds address of movePacman instruction to execute
	G1moveCache dd MoveG1Up	; holds backup movement instruction in case moveInst is not possible

	score dd 0
	gameClock dd 0

	theMap	db "788888888888888888888888889 788888888888888888888888889",0
			db "4 . . . . . . . . . . . . 4 4 . . . . . . . . . . . . 4",0
			db "4 . 7888889 . 788888889 . 4 4 . 788888889 . 7888889 . 4",0
			db "4 O 4     4 . 4       4 . 4 4 . 4       4 . 4     4 O 4",0
			db "4 . 1888883 . 188888883 . 183 . 188888883 . 1888883 . 4",0
			db "4 . . . . . . . . . . . . . . . . . . . . . . . . . . 4",0
			db "4 . 7888889 . 789 . 788888888888889 . 789 . 7888889 . 4",0
			db "4 . 1888883 . 4 4 . 1888889 7888883 . 4 4 . 1888883 . 4",0
			db "4 . . . . . . 4 4 . . . . 4 4 . . . . 4 4 . . . . . . 4",0
			db "18888888889 . 4 1888889   4 4   7888883 4 . 78888888883",0
			db "          4 . 4 7888883   183   1888889 4 . 4          ",0
			db "          4 . 4 4                     4 4 . 4          ",0
			db "          4 . 4 4   78888_____88889   4 4 . 4          ",0
			db "88888888883 . 183   4             4   183 . 18888888888",0
			db "<           .       4             4       .           >",0
			db "88888888889 . 789   4             4   789 . 78888888888",0
			db "          4 . 4 4   188888888888883   4 4 . 4          ",0
			db "          4 . 4 4                     4 4 . 4          ",0
			db "          4 . 4 4   788888888888889   4 4 . 4          ",0
			db "78888888883 . 183   1888889 7888883   183 . 18888888889",0
			db "4 . . . . . . . . . . . . 4 4 . . . . . . . . . . . . 4",0
			db "4 . 7888889 . 788888889 . 4 4 . 788888889 . 7888889 . 4",0
			db "4 . 18889 4 . 188888883 . 183 . 188888883 . 4 78883 . 4",0
			db "4 O . . 4 4 . . . . . . .     . . . . . . . 4 4 . . O 4",0
			db "18889 . 4 4 . 789 . 788888888888889 . 789 . 4 4 . 78883",0
			db "78883 . 183 . 4 4 . 1888889 7888883 . 4 4 . 183 . 18889",0
			db "4 . . . . . . 4 4 . . . . 4 4 . . . . 4 4 . . . . . . 4",0
			db "4 . 78888888883 1888889 . 4 4 . 7888883 18888888889 . 4",0
			db "4 . 1888888888888888883 . 183 . 1888888888888888883 . 4",0
			db "4 . . . . . . . . . . . . . . . . . . . . . . . . . . 4",0
			db "1888888888888888888888888888888888888888888888888888883 "
						

.code

main PROC

	call Randomize
	call DrawMap
	call ShowPac
	call ShowG1
	mov eax, 100
	call Delay
	call MoveG1Left
	call MoveG1Up

	LOOPME:
		call ControlLoop
		cmp gameIsOver, 0FFh
		je GAMEOVERDUDE
		mov eax, 100
		call Delay
		jmp LOOPME

	GAMEOVERDUDE:
		call GameOver

	exit

main ENDP

DrawMap PROC uses eax

	mov ecx, mapSize			; TODO: un-hardcode this
	mov esi, OFFSET theMap

	DRAWMAPLOOP:
		mov eax, 0
		mov al, [esi]

		call DrawWhatYouSee
		inc esi
		loop DRAWMAPLOOP

	ENDDRAWMAP:
		mov eax, 8
		call SetTextColor

		ret

DrawMap ENDP

DrawWhatYouSee PROC

	cmp al, "7"
	je PRINTWALL7PLS

	cmp al, "9"
	je PRINTWALL9PLS

	cmp al, "1"
	je PRINTWALL1PLS

	cmp al, "3"
	je PRINTWALL3PLS

	cmp al, "8"
	je PRINTWALL8PLS

	cmp al, "4"
	je PRINTWALL4PLS

	cmp al, "."
	je PRINTDOTPLS

	cmp al, "O"
	je PRINTBIGDOTPLS

	cmp al, "_"
	je PRINTGATEPLS

	cmp al, 0
	je CARRIAGERETURNPLS

	mov eax, " "
	call WriteChar
	jmp KEEPDRAWING

	PRINTWALL7PLS:
		call PrintWall7
		jmp KEEPDRAWING

	PRINTWALL9PLS:
		call PrintWall9
		jmp KEEPDRAWING

	PRINTWALL1PLS:
		call PrintWall1
		jmp KEEPDRAWING

	PRINTWALL3PLS:
		call PrintWall3
		jmp KEEPDRAWING

	PRINTWALL8PLS:
		call PrintWall8
		jmp KEEPDRAWING

	PRINTWALL4PLS:
		call PrintWall4
		jmp KEEPDRAWING

	PRINTDOTPLS:
		call PrintDot
		jmp KEEPDRAWING

	PRINTBIGDOTPLS:
		call PrintBigDot
		jmp KEEPDRAWING

	PRINTGATEPLS:
		call PrintGate
		jmp KEEPDRAWING

	CARRIAGERETURNPLS:
		call CarriageReturn

	KEEPDRAWING:

	ret

DrawWhatYouSee ENDP

PrintWall7 PROC

	mov eax, 9
	call SetTextColor
	mov eax, 201
	call WriteChar
	
	ret

PrintWall7 ENDP

PrintWall9 PROC

	mov eax, 9
	call SetTextColor
	mov eax, 187
	call WriteChar
		
	ret

PrintWall9 ENDP

PrintWall1 PROC

	mov eax, 9
	call SetTextColor
	mov eax, 200
	call WriteChar
	
	ret

PrintWall1 ENDP

PrintWall3 PROC

	mov eax, 9
	call SetTextColor
	mov eax, 188
	call WriteChar
	
	ret

PrintWall3 ENDP

PrintWall8 PROC

	mov eax, 9
	call SetTextColor
	mov eax, 205
	call WriteChar
	
	ret

PrintWall8 ENDP

PrintWall4 PROC

	mov eax, 9
	call SetTextColor
	mov eax, 186
	call WriteChar
	
	ret

PrintWall4 ENDP

PrintDot PROC

	mov eax, 7
	call SetTextColor
	mov eax, 250
	call WriteChar
	
	ret

PrintDot ENDP

PrintBigDot PROC
	mov eax, 7
	call SetTextColor
	mov eax, 254
	call WriteChar
	
	ret

PrintBigDot ENDP

PrintGate PROC

	mov eax, 12
	call SetTextColor
	mov eax, 196
	call WriteChar

	ret

PrintGate ENDP

CarriageReturn PROC

	call crlf
	
	ret

CarriageReturn ENDP

; ********************************************************************************************************************************************************************************************************
; PACMAN MOVEMENT PROCEDURES

; dl = X-coordinate
; dh = Y-coordinate

ShowPac PROC uses edx

	mov eax, black+(yellow*16)
	call SetTextColor

	mov dl, pacXCoord
	mov dh, pacYCoord
	call Gotoxy			; move cursor to desired X and Y coordinate

	movzx eax, pacChar1	; for direction
	call WriteChar		; SHOW ME THE MANS
	movzx eax, pacChar2
	call WriteChar

	mov eax, 0Fh
	call SetTextColor	; reset text color

	ret

ShowPac ENDP

; takes current x and y coords of PacMan and sets that coord to a space

UnShowPac PROC

	mov dl, pacXCoord
	mov dh, pacYCoord
	call Gotoxy			; move cursor to desired X and Y coordinate

	mov eax, 32
	call WriteChar		; UNSHOW ME THE MANS
	call WriteChar

	ret

UnShowPac ENDP

; move PacMan up one space

MovePacUp PROC uses edx

	movzx eax, pacYCoord
	movzx ebx, pacXCoord
	call CheckAbove

	cmp al, 30h
	jl CARRYONUP

	cmp al, 39h
	jg CARRYONUP

	mov ebx, 1
	jmp ENDUP

	CARRYONUP:
		call UnShowPac

		mov pacChar1, 'v'
		mov pacChar2, ':'
		dec PacYCoord		; move up 1 Y-coordinate

		call ShowPac

	ENDUP:
		ret

MovePacUp ENDP

; move PacMan down one space

MovePacDown PROC uses edx

	movzx eax, pacYCoord
	movzx ebx, pacXCoord
	call CheckBelow

	cmp al, 30h
	jl CARRYONDOWN

	cmp al, 5Fh
	je ENDDOWN

	cmp al, 39h
	jg CARRYONDOWN

	mov ebx, 1
	jmp ENDDOWN

	CARRYONDOWN:
		call UnShowPac

		mov pacChar1, 239
		mov pacChar2, ':'
		inc PacYCoord		; move down 1 Y-coordinate

		call ShowPac

	ENDDOWN:
		ret

MovePacDown ENDP

; move PacMan left one space

MovePacLeft PROC uses edx

	movzx eax, pacYCoord
	movzx ebx, pacXCoord
	call CheckLeft

	cmp al, 30h
	jl CARRYONLEFT

	cmp al, 39h
	jg CARRYONLEFT

	mov ebx, 1
	jmp ENDLEFT

	CARRYONLEFT:
		call UnShowPac

		mov pacChar1, '>'
		mov pacChar2, "'"
		sub PacXCoord, 2	; move left 1 X-coordinate

		call ShowPac
	
	ENDLEFT:
		ret

MovePacLeft ENDP

; move PacMan right one space

MovePacRight PROC uses edx

	movzx eax, pacYCoord
	movzx ebx, pacXCoord
	call CheckRight

	cmp al, 30h
	jl CARRYONRIGHT

	cmp al, 39h
	jg CARRYONRIGHT

	mov ebx, 1
	jmp ENDRIGHT

	CARRYONRIGHT:
		call UnShowPac

		mov pacChar1, "'"
		mov pacChar2, '<'
		add PacXCoord, 2	; move right 1 X-coordinate

		call ShowPac

	ENDRIGHT:
		ret

MovePacRight ENDP

IsPacKill PROC

	mov al, pacXCoord
	cmp al, G1XCoord
	jne HELIVES

	mov al, pacYCoord
	cmp al, G1YCoord
	jne HELIVES

	mov gameIsOver, 0FFh

	HELIVES:
		ret

IsPacKill ENDP

; ********************************************************************************************************************************************************************************************************
; G1 MOVEMENT PROCEDURES

ShowG1 PROC

	mov eax, white+(red*16)
	call SetTextColor

	mov dl, G1XCoord
	mov dh, G1YCoord
	call Gotoxy

	mov eax, 248
	call WriteChar
	call WriteChar

	mov eax, 0Fh
	call SetTextColor

	ret

ShowG1 ENDP

UnShowG1 PROC

	mov dl, G1XCoord
	mov dh, G1YCoord
	call Gotoxy			; move cursor to desired X and Y coordinate

	mov esi, OFFSET theMap
	movzx eax, G1YCoord
	movzx ebx, G1XCoord
	call CheckPos
	call DrawWhatYouSee
	inc esi
	call DrawWhatYouSee

	ret

UnShowG1 ENDP

; move PacMan up one space

MoveG1Up PROC uses edx

	movzx eax, G1YCoord
	movzx ebx, G1XCoord
	call CheckAbove

	cmp al, 30h
	jl CARRYG1UP

	cmp al, 39h
	jg CARRYG1UP

	mov ebx, 1
	jmp ENDG1UP

	CARRYG1UP:
		call UnShowG1
		dec G1YCoord		; move up 1 Y-coordinate

		call ShowG1

	ENDG1UP:
		ret

MoveG1Up ENDP

; move G1 down one space

MoveG1Down PROC uses edx

	movzx eax, G1YCoord
	movzx ebx, G1XCoord
	call CheckBelow

	cmp al, 30h
	jl CARRYG1DOWN

	cmp al, 5Fh
	je ENDG1DOWN

	cmp al, 39h
	jg CARRYG1DOWN

	mov ebx, 1
	jmp ENDG1DOWN

	CARRYG1DOWN:
		call UnShowG1
		inc G1YCoord		; move down 1 Y-coordinate

		call ShowG1

	ENDG1DOWN:
		ret

MoveG1Down ENDP

; move G1 left one space

MoveG1Left PROC uses edx

	movzx eax, G1YCoord
	movzx ebx, G1XCoord
	call CheckLeft

	cmp al, 30h
	jl CARRYONG1LEFT

	cmp al, 39h
	jg CARRYONG1LEFT

	mov ebx, 1
	jmp ENDG1LEFT

	CARRYONG1LEFT:
		call UnShowG1
		sub G1XCoord, 2	; move left 1 X-coordinate

		call ShowG1
	
	ENDG1LEFT:
		ret

MoveG1Left ENDP

; move G1 right one space

MoveG1Right PROC uses edx

	movzx eax, G1YCoord
	movzx ebx, G1XCoord
	call CheckRight

	cmp al, 30h
	jl CARRYONG1RIGHT

	cmp al, 39h
	jg CARRYONG1RIGHT

	mov ebx, 1
	jmp ENDG1RIGHT

	CARRYONG1RIGHT:
		call UnShowG1
		add G1XCoord, 2	; move right 1 X-coordinate

		call ShowG1

	ENDG1RIGHT:
		ret

MoveG1Right ENDP

G1Think PROC

	mov eax, 3
	call RandomRange

	cmp eax, 0
	je G1CLOCKWISE

	cmp eax, 1
	je G1COUNTERCLK

	jmp TRYG1MOVE

	G1CLOCKWISE:
		cmp G1MoveCache, OFFSET MoveG1Up
		je G1GORIGHT

		cmp G1MoveCache, OFFSET MoveG1Right
		je G1GODOWN

		cmp G1MoveCache, OFFSET MoveG1Down
		je G1GOLEFT

		cmp G1MoveCache, OFFSET MoveG1Left
		je G1GOUP

	G1COUNTERCLK:
		cmp G1MoveCache, OFFSET MoveG1Up
		je G1GOLEFT

		cmp G1MoveCache, OFFSET MoveG1Right
		je G1GOUP

		cmp G1MoveCache, OFFSET MoveG1Down
		je G1GORIGHT

		cmp G1MoveCache, OFFSET MoveG1Left
		je G1GODOWN

	G1GOUP:
		mov G1MoveInst, OFFSET MoveG1Up
		jmp TRYG1MOVE

	G1GORIGHT:
		mov G1moveInst, OFFSET MoveG1Right
		jmp TRYG1MOVE

	G1GODOWN:
		mov G1MoveInst, OFFSET MoveG1Down
		jmp TRYG1MOVE

	G1GOLEFT:
		mov G1MoveInst, OFFSET MoveG1Left
		jmp TRYG1MOVE

	TRYG1MOVE:
		mov eax, G1moveInst
		call NEAR PTR eax		; Try executing G1moveInst
		cmp ebx, 1				; If G1moveInst failed
		je G1CANTGOTHERE		; G1 can't go there

		mov eax, G1moveInst		; Move desired instruction back into eax
		mov G1moveCache, eax	; Movement succeeded, store the movement we just made in moveCache
		ret						; you did it

	G1CANTGOTHERE:
		mov eax, G1moveCache	; move the cached movement into eax (we know it will execute because it was stored in the cache in the first place, see above)
		call NEAR PTR eax		; DOIT

	ret

G1Think ENDP

; ********************************************************************************************************************************************************************************************************

; eax = y coordinate
; ebx = x coordinate

CheckAbove PROC uses esi

	dec eax
	call CheckPos

	ret

CheckAbove ENDP

; eax = y coordinate
; ebx = x coordinate

CheckBelow PROC

	inc eax
	call CheckPos

	ret

CheckBelow ENDP

; eax = y coordinate
; ebx = x coordinate

CheckLeft PROC

	sub ebx, 2
	call CheckPos

	ret

CheckLeft ENDP

; eax = y coordinate
; ebx = x coordinate

CheckRight PROC

	add ebx, 2
	call CheckPos

	ret

CheckRight ENDP

; eax = y coordinate
; ebx = x coordinate

CheckPos PROC

	mov esi, OFFSET theMap
	push ebx
	mov ebx, LENGTHOF theMap
	mul ebx
	pop ebx
	add eax, ebx
	add esi, eax
	mov al, [esi]

	ret

CheckPos ENDP

ControlLoop PROC uses eax

	mov edx, 100
	call Gotoxy
	mov eax, score
	call WriteDec

	call IsPacKill

	cmp fixLeftTube, 0FFh
	jne DONTFIXLEFT
	mov dl, 54
	mov dh, 14
	call Gotoxy
	mov eax, " "
	call WriteChar
	call WriteChar
	mov fixLeftTube, 0
	DONTFIXLEFT:

	cmp fixRightTube, 0FFh
	jne DONTFIXRIGHT
	mov dl, 0
	mov dh, 14
	call Gotoxy
	mov eax, " "
	call WriteChar
	call WriteChar
	mov fixRightTube, 0
	DONTFIXRIGHT:

	call ReadKey

	cmp eax, 4B00h		; on left arrow key press
	je MOVELEFT

	cmp eax, 4800h		; on up arrow key press
	je MOVEUP

	cmp eax, 4D00h		; on right arrow key press
	je MOVERIGHT

	cmp eax, 5000h		; on down arrow key press
	je MOVEDOWN

	jmp TRYMOVE

	MOVELEFT:
		mov moveInst, OFFSET MovePacLeft
		jmp TRYMOVE

	MOVEUP:
		mov moveInst, OFFSET MovePacUp
		jmp TRYMOVE

	MOVERIGHT:
		mov moveInst, OFFSET MovePacRight
		jmp TRYMOVE

	MOVEDOWN:
		mov moveInst, OFFSET MovePacDown
		jmp TRYMOVE

	TRYMOVE:
		mov eax, moveInst
		call NEAR PTR eax	; Try executing moveInst
		cmp ebx, 1			; If moveInst failed
		je PACCANTGOTHERE	; Pacman can't go there

		mov eax, moveInst	; Move desired instruction back into eax
		mov moveCache, eax	; Movement succeeded, store the movement we just made in moveCache
		jmp ENDMOVEMENT		; you did it

	PACCANTGOTHERE:
		mov eax, moveCache	; move the cached movement into eax (we know it will execute because it was stored in the cache in the first place, see above)
		call NEAR PTR eax	; DOIT

	ENDMOVEMENT:

	call G1Think

	movzx eax, pacYCoord
	movzx ebx, pacXCoord
	call CheckPos
	mov edx, " "

	cmp al, "."
	je SCOREDOT

	cmp al, "O"
	je SCOREBIGDOT

	cmp al, ">"
	je TRAVERSERIGHTTUBE

	cmp al, "<"
	je TRAVERSELEFTTUBE

	jmp ENDCHARCHECK

	SCOREDOT:
		add score, 10
		mov [esi], dl
		jmp ENDCHARCHECK

	SCOREBIGDOT:
		add score, 50
		mov [esi], dl
		jmp ENDCHARCHECK

	TRAVERSELEFTTUBE:
		mov fixRightTube, 0FFh
		mov pacXCoord, 54
		mov pacYCoord, 14
		call ShowPac
		jmp ENDCHARCHECK

	TRAVERSERIGHTTUBE:
		mov fixLeftTube, 0FFh
		mov pacXCoord, 0
		mov pacYCoord, 14
		call ShowPac
		jmp ENDCHARCHECK

	ENDCHARCHECK:

	inc gameClock
	ret

ControlLoop ENDP

GameOver PROC

	call ClrScr
	mov edx, OFFSET gameoverMessage
	call WriteString
	call crlf

	ret

GameOver ENDP

end main