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
	call MovePacUp
	mov eax, 100
	call Delay
	call MovePacUp
	mov eax, 100
	call Delay
	call MovePacUp

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

	dec PacYCoord

	call ShowPac

	ret

MovePacUp ENDP

end main