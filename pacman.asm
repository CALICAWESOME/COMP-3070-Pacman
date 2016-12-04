INCLUDE Irvine32.inc

.data

	gameoverMessage db "Pacman is kill. You suck.",0
	mapSize dd 1736				; TODO: un-hardcode this
	splashSize dd 3570			; TODO: also un-hardcode this maybe
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
	G1moveInst dd MoveG1Left	; holds address of movePacman instruction to execute
	G1moveCache dd MoveG1Left	; holds backup movement instruction in case moveInst is not possible
	G1options dd 0,0,0
	G1NumOpts db 0

	G2XCoord db 28
	G2YCoord db 11
	G2moveInst dd MoveG2Right	; holds address of movePacman instruction to execute
	G2moveCache dd MoveG2Right	; holds backup movement instruction in case moveInst is not possible
	G2options dd 0,0,0
	G2NumOpts db 0

	score dd 0
	gameClock dd 0

	theMap	db "788888888888888888888888889 788888888888888888888888889",0
			db "4 . . . . . . . . . . . . 4 4 . . . . . . . . . . . . 4",0
			db "4 . 7888889 . 788888889 . 4 4 . 788888889 . 7888889 . 4",0
			db "4 ~ 4     4 . 4       4 . 4 4 . 4       4 . 4     4 ~ 4",0
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
			db "4 ~ . . 4 4 . . . . . . .     . . . . . . . 4 4 . . ~ 4",0
			db "18889 . 4 4 . 789 . 788888888888889 . 789 . 4 4 . 78883",0
			db "78883 . 183 . 4 4 . 1888889 7888883 . 4 4 . 183 . 18889",0
			db "4 . . . . . . 4 4 . . . . 4 4 . . . . 4 4 . . . . . . 4",0
			db "4 . 78888888883 1888889 . 4 4 . 7888883 18888888889 . 4",0
			db "4 . 1888888888888888883 . 183 . 1888888888888888883 . 4",0
			db "4 . . . . . . . . . . . . . . . . . . . . . . . . . . 4",0
			db "1888888888888888888888888888888888888888888888888888883 "
						

	splash db " ~ 789 789 789 789 789 789 789 789 789 789 788888888888888888888888888888889 789 789 789 789 789 789 789 789 789 789 ~", 0
		   db " 783 183 183 183 183 183 183 183 183 183 183 wBobby Martin & Jared Conroy  183 183 183 183 183 183 183 183 183 183 189", 0
		   db " 189 7888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888889 783", 0
		   db " 783 4 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4 189", 0
		   db " 189 4 . 78889 . 7888888888888888888888888888888888888888888888888888888888888888888888888888888888889 . 78889 . 4 783", 0
		   db " 783 4 . 4   4 . 4                                                                                   4 . 4   4 . 4 189", 0
		   db " 189 4 . 4   4 . 4    @5555555      5         55555          5         5       5       5    5555     4 . 4   4 . 4 783", 0
		   db " 783 4 . 4   4 . 4    @22222222Z   222      222222226        225     522      222      225  2222     4 . 4   4 . 4 189", 0
		   db " 189 4 . 4   4 . 4    @22222222Z  22222    2222266     5225  22225 52222     22222     222252222     4 . 4   4 . 4 783", 0
		   db " 783 4 . 4   4 . 4    @2222666   2222222   2222255     6226  22222222222    2222222    222222222     4 . 4   4 . 4 189", 0
		   db " 189 4 . 4   4 . 4    @2222     222222222   222222225        22222222222   222222222   222222222     4 . 4   4 . 4 783", 0
		   db " 783 4 . 4   4 . 4    @6666    66666666666    66666          66666666666  66666666666  666666666     4 . 4   4 . 4 189", 0
		   db " 189 4 . 4   4 . 4                                                                                   4 . 4   4 . 4 783", 0
		   db " 783 4 . 18883 . 1888888888888888888888888888888888888888888888888888888888888888888888888888888888883 . 18883 . 4 189", 0
		   db " 189 4 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4 783", 0
		   db " 783 4 . 78889 . 788888888888888888888888888888_________________________888888888888888888888888888889 . 78889 . 4 189", 0
		   db " 189 4 . 4   4 . 4                                                                                   4 . 4   4 . 4 783", 0
		   db " 783 4 . 4   4 . 4                                |    @5/?5/?5                                      4 . 4   4 . 4 189", 0
		   db " 189 4 . 4   4 . 4      =52225        p52225     ||   @22)22)222          ^52225        g52225       4 . 4   4 . 4 783", 0
		   db " 783 4 . 4   4 . 4      =u+u+2        pu+u+2     @65 5Q225c25262Z65       ^2+v+v        g2+v+v       4 . 4   4 . 4 189", 0
		   db " 189 4 . 4   4 . 4      =22222        p22222       @6  25      2  56      ^22222        g22222       4 . 4   4 . 4 783", 0
		   db " 783 4 . 4   4 . 4      =26262        p26262           @625$$56||6        ^26262        g26262       4 . 4   4 . 4 189", 0
		   db " 189 4 . 18883 . 4                                        #  #                                       4 . 18883 . 4 783", 0
		   db " 783 4 . . . . . 4      =INKY         pPINKY           =522  225          ^BLINKY       gCLYDE       4 . . . . . 4 189", 0
		   db " 189 4 . 78889 . 4                                                                                   4 . 78889 . 4 783", 0
		   db " 783 4 . 18883 . 1888888888888888888888888888888888888888888888888888888888888888888888888888888888883 . 18883 . 4 189", 0
		   db " 189 4 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4 783", 0
		   db " 783 1888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888883 189", 0
		   db " 189 789 789 789 789 789 789 789 789 789 789 789wPRESS ANY KEY TO PLAY 789 789 789 789 789 789 789 789 789 789 789 783", 0
		   db " ~ 183 183 183 183 183 183 183 183 183 183 183 1888888888888888888888883 183 183 183 183 183 183 183 183 183 183 183 ~ "

.code

main PROC

	call Randomize
	call DrawSplash
	SPLASHSCRN:
		call ReadKey
		cmp eax, 1
		jne STARTGAME
		jmp SPLASHSCRN

	STARTGAME:
	call clrscr
	call DrawMap
	call ShowPac
	call ShowG1
	call ShowG2
	mov eax, 100
	call Delay

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

DrawSplash PROC uses eax

mov ecx, splashSize; TODO: un - hardcode this
mov esi, OFFSET splash

DRAWSPLASHLOOP:
	mov eax, 0
	mov al, [esi]

	call DrawWhatYouSee
	inc esi
	loop DRAWSPLASHLOOP

	mov eax, 8
	call SetTextColor

	ret

DrawSPLASH ENDP

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

	cmp al, "2"
	je PRINTBLOCKPLS

	cmp al, "5"
	je PRINTBOTTOMBLOCKPLS

	cmp al, "6"
	je PRINTTOPBLOCKPLS

	cmp al, "Z"
	je PRINTLEFTBLOCKPLS

	cmp al, "Q"
	je PRINTRIGHTBLOCKPLS

	cmp al, "$"
	je PRINTTONGUEPLS

	cmp al, "#"
	je PRINTLEGPLS

	cmp al, ")"
	je PRINTEYEPLS

	cmp al, "@"
	je SETYELLOW

	cmp al, "^"
	je SETCYAN

	cmp al, "g"
	je SETGREEN

	cmp al, "="
	je SETRED

	cmp al, "p"
	je SETMAGENTA

	cmp al, "w"
	je SETWHITE

	cmp al, "."
	je PRINTDOTPLS

	cmp al, "~"
	je PRINTBIGDOTPLS

	cmp al, "c"
	je PRINTNOSEPLS

	cmp al, "/"
	je PRINTBROWUPPLS

	cmp al, "?"
	je PRINTBROWDOWNPLS

	cmp al, "|"
	je PRINTGLOVEPLS

	cmp al, "+"
	je PRINTOPLS

	cmp al, "u"
	je PRINTEYELEFTPLS

	cmp al, "v"
	je PRINTEYERIGHTPLS

	cmp al, "_"
	je PRINTGATEPLS

	cmp al, ">"
	je PRINTSPACEPLS

	cmp al, "<"
	je PRINTSPACEPLS

	cmp al, 0
	je CARRIAGERETURNPLS

	cmp al, " "
	je PRINTSPACEPLS

	call WriteChar
	jmp KEEPDRAWING

	PRINTSPACEPLS:
		mov eax, " "
		call WriteChar
		jmp KEEPDRAWING

	SETYELLOW:
		mov eax, 14
		call SetTextColor
		jmp PRINTSPACEPLS

	SETCYAN :
		mov eax, 11
		call SetTextColor
		jmp PRINTSPACEPLS

	SETRED :
		mov eax, 12
		call SetTextColor
		jmp PRINTSPACEPLS

	SETMAGENTA :
		mov eax, 13
		call SetTextColor
		jmp PRINTSPACEPLS

	SETGREEN :
		mov eax, 10
		call SetTextColor
		jmp PRINTSPACEPLS
		
	SETWHITE :
		mov eax, 15
		call SetTextColor
		jmp PRINTSPACEPLS

	PRINTNOSEPLS :
		call PrintNose
		jmp KEEPDRAWING

	PRINTTONGUEPLS :
		call PrintTongue
		jmp KEEPDRAWING

	PRINTLEGPLS :
		call PrintLeg
		jmp KEEPDRAWING

	PRINTEYEPLS :
		call PrintEye
		jmp KEEPDRAWING

	PRINTGLOVEPLS :
		call PrintGlove
		jmp KEEPDRAWING

	PRINTOPLS :
		call PrintO
		jmp KEEPDRAWING

	PRINTEYELEFTPLS :
		call PrintEyeLeft
		jmp KEEPDRAWING

	PRINTEYERIGHTPLS :
		call PrintEyeRight
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

	PRINTBLOCKPLS:
		call PrintBlock
		jmp KEEPDRAWING

	PRINTTOPBLOCKPLS :
		call PrintTopBlock
		jmp KEEPDRAWING

	PRINTBOTTOMBLOCKPLS :
		call PrintBottomBlock
		jmp KEEPDRAWING

	PRINTLEFTBLOCKPLS :
		call PrintLeftBlock
		jmp KEEPDRAWING

	PRINTRIGHTBLOCKPLS :
		call PrintRightBlock
		jmp KEEPDRAWING

	PRINTBROWUPPLS :
		call PrintBrowUp
		jmp KEEPDRAWING

	PRINTBROWDOWNPLS :
		call PrintBrowDown
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

PrintNose PROC

	mov eax, 14*16
	call SetTextColor
	mov eax, 67
	call WriteChar
	mov eax, 14 ; reset to yellow
	call SetTextColor

	ret

PrintNose ENDP

PrintGlove PROC

	mov eax, 4
	call SetTextColor
	mov eax, 219
	call WriteChar

	ret

PrintGlove ENDP

PrintO PROC

	Call GetTextColor
	mov bl, al
	mov eax, 3+(15*16)
	Call SetTextColor
	mov eax, 223
	call WriteChar
	mov al, bl
	call SetTextColor

	ret

PrintO ENDP

PrintEyeLeft PROC
	
	Call GetTextColor
	add eax, (16*15)
	Call SetTextColor
	mov eax, 221
	call WriteChar
	call GetTextColor
	sub eax, (16*15)
	call SetTextColor

	ret

PrintEyeLeft ENDP

PrintEyeRight PROC

	Call GetTextColor
	add eax, (16 * 15)
	Call SetTextColor
	mov eax, 222
	call WriteChar
	call GetTextColor
	sub eax, (16 * 15)
	call SetTextColor

	ret

PrintEyeRight ENDP

PrintTongue PROC

	mov eax, 14 + (12 * 16)
	call SetTextColor
	mov eax, 220
	call WriteChar
	mov eax, 14; reset to yellow
	call SetTextColor

	ret

PrintTongue ENDP

PrintLeg PROC

	mov eax, 12 + (14 * 16)
	call SetTextColor
	mov eax, 220
	call WriteChar
	mov eax, 14; reset to yellow
	call SetTextColor

	ret

PrintLeg ENDP

PrintEye PROC

	mov eax, 62
	call WriteChar

	ret

PrintEye endp

PrintBrowUp PROC

	mov eax, 14*16
	call SetTextColor
	mov eax, 47
	call WriteChar

	ret

PrintBrowUp ENDP

PrintBrowDown PROC

	mov eax, 92
	Call WriteChar
	mov eax, 14; reset to yellow
	call SetTextColor

	ret

PrintBrowDown ENDP

PrintBlock PROC

	mov eax, 219
	call WriteChar

	ret

PrintBlock ENDP

PrintTopBlock PROC

	mov eax, 223
	call WriteChar

	ret

PrintTopBlock ENDP

PrintBottomBlock PROC

	mov eax, 220
	call WriteChar

	ret

PrintBottomBlock ENDP

PrintLeftBlock PROC

	mov eax, 221
	call WriteChar

	ret

PrintLeftBlock ENDP

PrintRightBlock PROC

	mov eax, 222
	call WriteChar

	ret

PrintRightBlock ENDP

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

	call CanIGoHere
	cmp ebx, 1
	je ENDUP
	
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

	call CanIGoHere
	cmp ebx, 1
	je ENDDOWN

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

	call CanIGoHere
	cmp ebx, 1
	je ENDLEFT

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

	call CanIGoHere
	cmp ebx, 1
	je ENDRIGHT

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
	mov bl, pacYCoord
	
	cmp al, G1XCoord
	jne SAFEFROMG1

	cmp bl, G1YCoord
	jne SAFEFROMG1

	jmp HEDEAD

	SAFEFROMG1:
		cmp al, G2XCoord
		jne SAFEFROMG2

		cmp bl, G2YCoord
		jne SAFEFROMG2

		jmp HEDEAD

	SAFEFROMG2:
		jmp HELIVES

	HEDEAD:
		mov gameIsOver, 0FFh

	HELIVES:
		ret

IsPacKill ENDP

; ********************************************************************************************************************************************************************************************************
; G1 MOVEMENT PROCEDURES

ShowG1 PROC

	mov eax, white+(lightred*16)
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
	mov al, [esi]
	call DrawWhatYouSee

	ret

UnShowG1 ENDP

; move PacMan up one space

MoveG1Up PROC uses edx

	movzx eax, G1YCoord
	movzx ebx, G1XCoord
	call CheckAbove

	call CanIGoHere
	cmp ebx, 1
	je ENDG1UP

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

	call CanIGoHere
	cmp ebx, 1
	je ENDG1DOWN

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

	call CanIGoHere
	cmp ebx, 1
	je ENDG1LEFT

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

	call CanIGoHere
	cmp ebx, 1
	je ENDG1RIGHT

	CARRYONG1RIGHT:
		call UnShowG1
		add G1XCoord, 2	; move right 1 X-coordinate

		call ShowG1

	ENDG1RIGHT:
		ret

MoveG1Right ENDP

G1Think PROC

	mov edi, OFFSET G1Options
	mov G1NumOpts, 0

	G1TRYUP:
		cmp G1MoveCache, OFFSET MoveG1Down
		je G1TRYDOWN

		movzx eax, G1YCoord
		movzx ebx, G1XCoord
		call CheckAbove
		call CanIGoHere
		cmp ebx, 1
		je G1TRYDOWN

		mov [edi], OFFSET MoveG1Up
		add edi, 4
		inc G1NumOpts

	G1TRYDOWN:
		cmp G1MoveCache, OFFSET MoveG1Up
		je G1TRYLEFT

		movzx eax, G1YCoord
		movzx ebx, G1XCoord
		call CheckBelow
		call CanIGoHere
		cmp ebx, 1
		je G1TRYLEFT

		mov [edi], OFFSET MoveG1Down
		add edi, 4
		inc G1NumOpts

	G1TRYLEFT:
		cmp G1MoveCache, OFFSET MoveG1Right
		je G1TRYRIGHT

		movzx eax, G1YCoord
		movzx ebx, G1XCoord
		call CheckLeft
		call CanIGoHere
		cmp ebx, 1
		je G1TRYRIGHT

		mov [edi], OFFSET MoveG1Left
		add edi, 4
		inc G1NumOpts

	G1TRYRIGHT:
		cmp G1MoveCache, OFFSET MoveG1Left
		je G1PREDECISION

		movzx eax, G1YCoord
		movzx ebx, G1XCoord
		call CheckRight
		call CanIGoHere
		cmp ebx, 1
		je G1PREDECISION

		mov [edi], OFFSET MoveG1Right
		add edi, 4
		inc G1NumOpts

	G1PREDECISION:
		cmp G1NumOpts, 0
		jne G1DECIDE

		inc G1NumOpts
		mov eax, G1MoveCache
		mov G1options, eax

	G1DECIDE:
		movzx eax, G1NumOpts
		call RandomRange
		mov bl, 4
		mul bl
		mov esi, OFFSET G1Options
		add esi, eax
		mov eax, [esi]
		mov G1MoveInst, eax

	TRYG1MOVE:
		mov eax, OFFSET MoveG1Up
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

	movzx eax, G1YCoord
	movzx ebx, G1XCoord
	call CheckPos

	cmp al, ">"
	je G1TRAVERSERIGHTTUBE

	cmp al, "<"
	je G1TRAVERSELEFTTUBE

	jmp G1ENDCHARCHECK

	G1TRAVERSELEFTTUBE:
		mov fixRightTube, 0FFh
		mov fixLeftTube, 0ffh
		mov G1XCoord, 54
		mov G1YCoord, 14
		call ShowG1
		jmp G1ENDCHARCHECK

	G1TRAVERSERIGHTTUBE:
		mov fixRightTube, 0FFh
		mov fixLeftTube, 0ffh
		mov G1XCoord, 0
		mov G1YCoord, 14
		call ShowG1
		jmp G1ENDCHARCHECK

	G1ENDCHARCHECK:
		ret

G1Think ENDP

; ********************************************************************************************************************************************************************************************************
; G2 MOVEMENT PROCEDURES

ShowG2 PROC

	mov eax, white+(13*16)
	call SetTextColor

	mov dl, G2XCoord
	mov dh, G2YCoord
	call Gotoxy

	mov eax, 248
	call WriteChar
	call WriteChar

	mov eax, 0Fh
	call SetTextColor

	ret

ShowG2 ENDP

UnShowG2 PROC

	mov dl, G2XCoord
	mov dh, G2YCoord
	call Gotoxy			; move cursor to desired X and Y coordinate

	mov esi, OFFSET theMap
	movzx eax, G2YCoord
	movzx ebx, G2XCoord
	call CheckPos
	call DrawWhatYouSee
	inc esi
	mov al, [esi]
	call DrawWhatYouSee

	ret

UnShowG2 ENDP

; move PacMan up one space

MoveG2Up PROC uses edx

	movzx eax, G2YCoord
	movzx ebx, G2XCoord
	call CheckAbove

	call CanIGoHere
	cmp ebx, 1
	je ENDG2UP

	CARRYG2UP:
		call UnShowG2
		dec G2YCoord		; move up 1 Y-coordinate

		call ShowG2

	ENDG2UP:
		ret

MoveG2Up ENDP

; move G2 down one space

MoveG2Down PROC uses edx

	movzx eax, G2YCoord
	movzx ebx, G2XCoord
	call CheckBelow

	call CanIGoHere
	cmp ebx, 1
	je ENDG2DOWN

	CARRYG2DOWN:
		call UnShowG2
		inc G2YCoord		; move down 1 Y-coordinate

		call ShowG2

	ENDG2DOWN:
		ret

MoveG2Down ENDP

; move G2 left one space

MoveG2Left PROC uses edx

	movzx eax, G2YCoord
	movzx ebx, G2XCoord
	call CheckLeft

	call CanIGoHere
	cmp ebx, 1
	je ENDG2LEFT

	CARRYONG2LEFT:
		call UnShowG2
		sub G2XCoord, 2	; move left 1 X-coordinate

		call ShowG2
	
	ENDG2LEFT:
		ret

MoveG2Left ENDP

; move G2 right one space

MoveG2Right PROC uses edx

	movzx eax, G2YCoord
	movzx ebx, G2XCoord
	call CheckRight

	call CanIGoHere
	cmp ebx, 1
	je ENDG2RIGHT

	CARRYONG2RIGHT:
		call UnShowG2
		add G2XCoord, 2	; move right 1 X-coordinate

		call ShowG2

	ENDG2RIGHT:
		ret

MoveG2Right ENDP

G2Think PROC

	mov edi, OFFSET G2Options
	mov G2NumOpts, 0

	G2TRYUP:
		cmp G2MoveCache, OFFSET MoveG2Down
		je G2TRYDOWN

		movzx eax, G2YCoord
		movzx ebx, G2XCoord
		call CheckAbove
		call CanIGoHere
		cmp ebx, 1
		je G2TRYDOWN

		mov [edi], OFFSET MoveG2Up
		add edi, 4
		inc G2NumOpts

	G2TRYDOWN:
		cmp G2MoveCache, OFFSET MoveG2Up
		je G2TRYLEFT

		movzx eax, G2YCoord
		movzx ebx, G2XCoord
		call CheckBelow
		call CanIGoHere
		cmp ebx, 1
		je G2TRYLEFT

		mov [edi], OFFSET MoveG2Down
		add edi, 4
		inc G2NumOpts

	G2TRYLEFT:
		cmp G2MoveCache, OFFSET MoveG2Right
		je G2TRYRIGHT

		movzx eax, G2YCoord
		movzx ebx, G2XCoord
		call CheckLeft
		call CanIGoHere
		cmp ebx, 1
		je G2TRYRIGHT

		mov [edi], OFFSET MoveG2Left
		add edi, 4
		inc G2NumOpts

	G2TRYRIGHT:
		cmp G2MoveCache, OFFSET MoveG2Left
		je G2PREDECISION

		movzx eax, G2YCoord
		movzx ebx, G2XCoord
		call CheckRight
		call CanIGoHere
		cmp ebx, 1
		je G2PREDECISION

		mov [edi], OFFSET MoveG2Right
		add edi, 4
		inc G2NumOpts

	G2PREDECISION:
		cmp G2NumOpts, 0
		jne G2DECIDE

		inc G2NumOpts
		mov eax, G2MoveCache
		mov G2options, eax

	G2DECIDE:
		movzx eax, G2NumOpts
		call RandomRange
		mov bl, 4
		mul bl
		mov esi, OFFSET G2Options
		add esi, eax
		mov eax, [esi]
		mov G2MoveInst, eax

	TRYG2MOVE:
		mov eax, OFFSET MoveG2Up
		mov eax, G2moveInst
		call NEAR PTR eax		; Try executing G2moveInst
		cmp ebx, 1				; If G2moveInst failed
		je G2CANTGOTHERE		; G2 can't go there

		mov eax, G2moveInst		; Move desired instruction back into eax
		mov G2moveCache, eax	; Movement succeeded, store the movement we just made in moveCache
		ret						; you did it

	G2CANTGOTHERE:
		mov eax, G2moveCache	; move the cached movement into eax (we know it will execute because it was stored in the cache in the first place, see above)
		call NEAR PTR eax		; DOIT

	movzx eax, G2YCoord
	movzx ebx, G2XCoord
	call CheckPos

	cmp al, ">"
	je G2TRAVERSERIGHTTUBE

	cmp al, "<"
	je G2TRAVERSELEFTTUBE

	jmp G2ENDCHARCHECK

	G2TRAVERSELEFTTUBE:
		mov fixRightTube, 0FFh
		mov fixLeftTube, 0ffh
		mov G2XCoord, 54
		mov G2YCoord, 14
		call ShowG2
		jmp G2ENDCHARCHECK

	G2TRAVERSERIGHTTUBE:
		mov fixRightTube, 0FFh
		mov fixLeftTube, 0ffh
		mov G2XCoord, 0
		mov G2YCoord, 14
		call ShowG2
		jmp G2ENDCHARCHECK

	G2ENDCHARCHECK:
		ret

G2Think ENDP

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

; eax = character to check

CanIGoHere PROC

	cmp al, 30h
	jl YEAHYOUCAN

	cmp al, 5Fh
	je NOYOUCANT

	cmp al, 39h
	jg YEAHYOUCAN

	NOYOUCANT:

	mov ebx, 1

	YEAHYOUCAN:

	ret

CanIGoHere ENDP

FixLeftTubePls PROC

	mov dl, 54
	mov dh, 14
	call Gotoxy
	mov eax, " "
	call WriteChar
	call WriteChar
	mov fixLeftTube, 0

	ret

FixLeftTubePls ENDP

FixRightTubePls PROC

	mov dl, 0
	mov dh, 14
	call Gotoxy
	mov eax, " "
	call WriteChar
	call WriteChar
	mov fixRightTube, 0

	ret

FixRightTubePls ENDP

ControlLoop PROC uses eax

	mov edx, 100
	call Gotoxy
	mov eax, score
	call WriteDec

	cmp fixLeftTube, 0FFh
	jne DONTFIXLEFT
	call FixLeftTubePls
	DONTFIXLEFT:

	cmp fixRightTube, 0FFh
	jne DONTFIXRIGHT
	call FixRightTubePls
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

	call IsPacKill

	call G1Think
	call G2Think

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
		mov fixLeftTube, 0ffh
		mov pacXCoord, 54
		mov pacYCoord, 14
		call ShowPac
		jmp ENDCHARCHECK

	TRAVERSERIGHTTUBE:
		mov fixRightTube, 0FFh
		mov fixLeftTube, 0ffh
		mov pacXCoord, 0
		mov pacYCoord, 14
		call ShowPac
		jmp ENDCHARCHECK

	ENDCHARCHECK:

	call IsPacKill

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