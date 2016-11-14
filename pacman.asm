INCLUDE Irvine32.inc

.data

	pacXCoord db 20				; byte used to hold the X-coordinate of PacMan
	pacYCoord db 10				; byte used to hold the Y-coordinate of PacMan
	pacChar db 'V'
	moveInst dd MovePacRight	; holds address of movePacman instruction to execute

	theMap	db "# # # # # # # # # # # # # # # # # # # # # # # # # # # #",0
			db "# . . . . . . . . . . . . # # . . . . . . . . . . . . #",0
			db "# . # # # # . # # # # # . # # . # # # # # . # # # # . #",0
			db "# O #     # . #       # . # # . #       # . #     # O #",0
			db "# . # # # # . # # # # # . # # . # # # # # . # # # # . #",0
			db "# . . . . . . . . . . . . . . . . . . . . . . . . . . #",0
			db "# . # # # # . # # . # # # # # # # # . # # . # # # # . #",0
			db "# . # # # # . # # . # # # # # # # # . # # . # # # # . #",0
			db "# . . . . . . # # . . . . # # . . . . # # . . . . . . #",0
			db "# # # # # # . # # # # #   # #   # # # # # . # # # # # #",0
			db "          # . # # # # #   # #   # # # # # . #          ",0
			db "          # . # #                     # # . #          ",0
			db "          # . # #   # # # _ _ # # #   # # . #          ",0
			db "# # # # # # . # #   #             #   # # . # # # # # #",0
			db "            .       #             #       .            ",0
			db "# # # # # # . # #   #             #   # # . # # # # # #",0
			db "          # . # #   # # # # # # # #   # # . #          ",0
			db "          # . # #                     # # . #          ",0
			db "          # . # #   # # # # # # # #   # # . #          ",0
			db "# # # # # # . # #   # # # # # # # #   # # . # # # # # #",0
			db "# . . . . . . . . . . . . # # . . . . . . . . . . . . #",0
			db "# . # # # # . # # # # # . # # . # # # # # . # # # # . #",0
			db "# . # # # # . # # # # # . # # . # # # # # . # # # # . #",0
			db "# O . . # # . . . . . . .     . . . . . . . # # . . O #",0
			db "# # # . # # . # # . # # # # # # # # . # # . # # . # # #",0
			db "# # # . # # . # # . # # # # # # # # . # # . # # . # # #",0
			db "# . . . . . . # # . . . . # # . . . . # # . . . . . . #",0
			db "# . # # # # # # # # # # . # # . # # # # # # # # # # . #",0
			db "# . # # # # # # # # # # . # # . # # # # # # # # # # . #",0
			db "# . . . . . . . . . . . . . . . . . . . . . . . . . . #",0
			db "# # # # # # # # # # # # # # # # # # # # # # # # # # # #",0
						

.code

main PROC

	call DrawMap

	call ShowPac
	mov eax, 100
	call Delay
	call MovePacUp
	mov eax, 100
	call Delay
	call MovePacRight
	mov eax, 100
	call Delay
	call MovePacDown 
	mov eax, 100
	call Delay
	call MovePacLeft

	LOOPME:
		call ControlLoop
		mov eax, 100
		call Delay
		jmp LOOPME

	exit

main ENDP

DrawMap PROC uses eax

	mov ecx, 1736			; TODO: un-hardcode this
	mov esi, OFFSET theMap

	DRAWMAPLOOP:
		mov eax, 0
		mov al, [esi]
		
		cmp al, "#"
		je PRINTWALL

		cmp al, "."
		je PRINTDOT

		cmp al, "O"
		je PRINTBIGDOT

		cmp al, "_"
		je PRINTGATE

		cmp al, 0
		je CARRIAGERETURN

		call WriteChar
		inc esi
		loop DRAWMAPLOOP

	PRINTWALL:
		mov eax, 9
		call SetTextColor
		mov eax, "#"
		call WriteChar
		inc esi
		loop DRAWMAPLOOP

	PRINTDOT:
		mov eax, 7
		call SetTextColor
		mov eax, "."
		call WriteChar
		inc esi
		loop DRAWMAPLOOP

	PRINTBIGDOT:
		mov eax, 15
		call SetTextColor
		mov eax, "O"
		call WriteChar
		inc esi
		loop DRAWMAPLOOP

	PRINTGATE:
		mov eax, 15
		call SetTextColor
		mov eax, "_"
		call WriteChar
		inc esi
		loop DRAWMAPLOOP

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

	mov eax, 0Eh
	call SetTextColor	; set text color to yellow

	mov dl, pacXCoord
	mov dh, pacYCoord
	call Gotoxy			; move cursor to desired X and Y coordinate

	movzx eax, pacChar	; for direction
	call WriteChar		; SHOW ME THE MANS

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

	ret

UnShowPac ENDP

; move PacMan up one space

MovePacUp PROC uses edx

	call UnShowPac

	mov pacChar, 'V'
	dec PacYCoord		; move up 1 Y-coordinate

	call ShowPac

	ret

MovePacUp ENDP

; move PacMan down one space

MovePacDown PROC uses edx

	call UnShowPac

	mov pacChar, 234
	inc PacYCoord		; move down 1 Y-coordinate

	call ShowPac

	ret

MovePacDown ENDP

; move PacMan left one space

MovePacLeft PROC uses edx

	call UnShowPac

	mov pacChar, '>'
	sub PacXCoord, 2	; move left 1 X-coordinate

	call ShowPac

	ret

MovePacLeft ENDP

; move PacMan right one space

MovePacRight PROC uses edx

	call UnShowPac

	mov pacChar, '<'
	add PacXCoord, 2	; move right 1 X-coordinate

	call ShowPac

	ret

MovePacRight ENDP

ControlLoop PROC uses eax

	call ReadKey
	jz ENDCONTROLLOOP	; if no key is pressed at all

	cmp eax, 4B00h		; on left arrow key press
	je MOVELEFT

	cmp eax, 4800h		; on up arrow key press
	je MOVEUP

	cmp eax, 4D00h		; on right arrow key press
	je MOVERIGHT

	cmp eax, 5000h		; on down arrow key press
	je MOVEDOWN

	jmp ENDCONTROLLOOP

	MOVELEFT:
		mov moveInst, OFFSET MovePacLeft
		jmp ENDCONTROLLOOP

	MOVEUP:
		mov moveInst, OFFSET MovePacUp
		jmp ENDCONTROLLOOP

	MOVERIGHT:
		mov moveInst, OFFSET MovePacRight
		jmp ENDCONTROLLOOP

	MOVEDOWN:
		mov moveInst, OFFSET MovePacDown
		jmp ENDCONTROLLOOP

	ENDCONTROLLOOP:
		mov eax, moveInst
		call NEAR PTR eax
		ret

ControlLoop ENDP

end main