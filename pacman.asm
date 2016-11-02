INCLUDE Irvine32.inc

.data

	yo db "Hello World!",0

.code

main PROC

	mov edx, OFFSET yo
	call WriteString
	call crlf

	exit

main ENDP

end main