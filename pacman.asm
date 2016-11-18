INCLUDE Irvine32.inc

.data

	mapSize dd 1736
	pacXCoord db 28				; byte used to hold the X-coordinate of PacMan
	pacYCoord db 23				; byte used to hold the Y-coordinate of PacMan
	pacChar1 db ">"
	pacChar2 db "'"
	multiple dd ?
	moveInst dd MovePacLeft		; holds address of movePacman instruction to execute
	moveCache dd MovePacLeft

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
			db "1888888888888888888888888888888888888888888888888888883",0
						

.code

main PROC

	call DrawMap

	call ShowPac

	LOOPME:
		call ControlLoop
		mov eax, 100
		call Delay
		jmp LOOPME
	mov dl, 0
	mov dh, 31
	call GoToXY

	exit

main ENDP

DrawMap PROC uses eax

	mov ecx, mapSize			; TODO: un-hardcode this
	mov esi, OFFSET theMap

	DRAWMAPLOOP:
		mov eax, 0
		mov al, [esi]
		
		cmp al, "7"
		je PRINTWALL7

		cmp al, "9"
		je PRINTWALL9

		cmp al, "1"
		je PRINTWALL1

		cmp al, "3"
		je PRINTWALL3

		cmp al, "8"
		je PRINTWALL8

		cmp al, "4"
		je PRINTWALL4

		cmp al, "."
		je PRINTDOT

		cmp al, "O"
		je PRINTBIGDOT

		cmp al, "_"
		je PRINTGATE

		cmp al, 0
		je CARRIAGERETURN

		mov eax, " "
		call WriteChar
		inc esi
		loop DRAWMAPLOOP

	PRINTWALL7:
		mov eax, 9
		call SetTextColor
		mov eax, 201
		call WriteChar
		inc esi
		loop DRAWMAPLOOP

	PRINTWALL9:
		mov eax, 9
		call SetTextColor
		mov eax, 187
		call WriteChar
		inc esi
		dec ecx				; do a loop jump manually
		jne DRAWMAPLOOP		; because loop is silly and can only jump -128 to +127 bytes

	PRINTWALL1:
		mov eax, 9
		call SetTextColor
		mov eax, 200
		call WriteChar
		inc esi
		dec ecx				; do a loop jump manually
		jne DRAWMAPLOOP		; because loop is silly and can only jump -128 to +127 bytes

	PRINTWALL3:
		mov eax, 9
		call SetTextColor
		mov eax, 188
		call WriteChar
		inc esi
		dec ecx				; do a loop jump manually
		jne DRAWMAPLOOP		; because loop is silly and can only jump -128 to +127 bytes

	PRINTWALL8:
		mov eax, 9
		call SetTextColor
		mov eax, 205
		call WriteChar
		inc esi
		dec ecx				; do a loop jump manually
		jne DRAWMAPLOOP		; because loop is silly and can only jump -128 to +127 bytes

	PRINTWALL4:
		mov eax, 9
		call SetTextColor
		mov eax, 186
		call WriteChar
		inc esi
		dec ecx				; do a loop jump manually
		jne DRAWMAPLOOP		; because loop is silly and can only jump -128 to +127 bytes

	PRINTDOT:
		mov eax, 7
		call SetTextColor
		mov eax, 250
		call WriteChar
		inc esi
		dec ecx				; do a loop jump manually
		jne DRAWMAPLOOP		; because loop is silly and can only jump -128 to +127 bytes

	PRINTBIGDOT:
		mov eax, 7
		call SetTextColor
		mov eax, 254
		call WriteChar
		inc esi
		dec ecx				; do a loop jump manually
		jne DRAWMAPLOOP		; because loop is silly and can only jump -128 to +127 bytes

	PRINTGATE:
		mov eax, 12
		call SetTextColor
		mov eax, 196
		call WriteChar
		inc esi
		dec ecx				; do a loop jump manually
		jne DRAWMAPLOOP		; because loop is silly and can only jump -128 to +127 bytes

	CARRIAGERETURN:
		call crlf
		inc esi
		dec ecx				; do a loop jump manually
		jne DRAWMAPLOOP		; because loop is silly and can only jump -128 to +127 bytes

	ENDDRAWMAP:
		mov eax, 8
		call SetTextColor

		ret

DrawMap ENDP

; dl = X-coordinate
; dh = Y-coordinate

ShowPac PROC uses edx

	mov eax, black+(yellow*16)
	call SetTextColor	; set text color to yellow

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
	call ReadKey
	call WriteHex

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
		call NEAR PTR eax
		cmp ebx, 1
		je PACCANTGOTHERE

		mov eax, moveInst
		mov moveCache, eax
		jmp ENDCONTROLLOOP

	PACCANTGOTHERE:
		mov eax, moveCache
		call NEAR PTR eax

	ENDCONTROLLOOP:
		ret

ControlLoop ENDP

end main