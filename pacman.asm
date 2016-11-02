INCLUDE Irvine32.inc

.data

	pacXCoord db 20		; byte used to hold the X-coordinate of PacMan
	pacYCoord db 10		; byte used to hold the Y-coordinate of PacMan

.code

main PROC

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

	exit

main ENDP

; dl = X-coordinate
; dh = Y-coordinate

ShowPac PROC uses eax edx

	mov eax, 0Eh
	call SetTextColor	; set text color to yellow

	mov dl, pacXCoord
	mov dh, pacYCoord
	call Gotoxy			; move cursor to desired X and Y coordinate

	mov eax, 234
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

MovePacUp PROC uses edx

	call UnShowPac

	dec PacYCoord		; move up 1 Y-coordinate

	call ShowPac

	ret

MovePacUp ENDP

MovePacDown PROC uses edx

	call UnShowPac

	inc PacYCoord		; move down 1 Y-coordinate

	call ShowPac

	ret

MovePacDown ENDP

MovePacLeft PROC uses edx

	call UnShowPac

	dec PacXCoord		; move left 1 X-coordinate

	call ShowPac

	ret

MovePacLeft ENDP

MovePacRight PROC uses edx

	call UnShowPac

	inc PacXCoord		; move right 1 X-coordinate

	call ShowPac

	ret

MovePacRight ENDP

end main