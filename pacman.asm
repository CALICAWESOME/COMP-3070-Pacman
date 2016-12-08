INCLUDE Irvine32.inc
 
include \masm32\include\winmm.inc
includelib \masm32\lib\winmm.lib

.data

	;:: THESE VARIABLES MAKE THINGS LOOK NICE ::
	mapSize dd 3719				; Fixed size of array containing map characters
	splashSize dd 3570			; Fixed size of array containing opening splash screen characters
	endSize dd 3570				; Fixed size of array containing game over splash screen characters
	fixRightTube db 0			; set to 0FFh when right tube is traversed through, used to make tube traversal look nice
	fixLeftTube db 0			; set to 0FFh when left tube is traversed through, used to make tube traversal look nice
	gameIsOver db 0				; set to 0FFh when pacman dies and is out of lives, used to display game over splash screen
	ready db "R E A D Y",0		; "Ready" text, shown under Ghost pen before game starts

	;:: PACMAN ASSOCIATED VARIABLES ::
	pacXCoord db 28				; byte used to hold the X-coordinate of PacMan
	pacYCoord db 23				; byte used to hold the Y-coordinate of PacMan
	pacChar1 db ">"				; byte used to hold the leftmost character of pacman's face
	pacChar2 db "'"				; byte used to hold thr rightmost character of pacman's face
	moveInst dd MovePacLeft		; holds address of movePacman instruction to execute
	moveCache dd MovePacLeft	; holds backup movement instruction in case moveInst is not possible

	;:: G1 ASSOCIATED VARIABLES ::
	G1XCoord db 26				; byte used to hold the X-coordinate of G1
	G1YCoord db 11				; byte used to hold the Y-coordinate of G1
	G1moveInst dd MoveG1Left	; holds address of moveG1 instruction to execute
	G1moveCache dd MoveG1Left	; holds backup movement instruction in case G1moveInst is not possible
	G1options dd 0,0,0			; holds addresses of move instructions that G1 can execute without going backwards or through a wall
	G1NumOpts db 0				; holds the number of directions G1 can move in without going backwards or through a wall

	;:: G2 ASSOCIATED VARIABLES::
	; see G1 associated variables for info on each one
	G2XCoord db 28
	G2YCoord db 11
	G2moveInst dd MoveG2Right
	G2moveCache dd MoveG2Right
	G2options dd 0,0,0
	G2NumOpts db 0

	;:: G3 ASSOCIATED VARIABLES::
	; see G1 associated variables for info on each one
	G3XCoord db 28
	G3YCoord db 11
	G3moveInst dd MoveG3Right
	G3moveCache dd MoveG3Right
	G3options dd 0,0,0
	G3NumOpts db 0

	;:: G4 ASSOCIATED VARIABLES::
	; see G1 associated variables for info on each one
	G4XCoord db 28
	G4YCoord db 11
	G4moveInst dd MoveG4Right
	G4moveCache dd MoveG4Right
	G4options dd 0,0,0
	G4NumOpts db 0

	;:: GENERAL GAME FLOW VARIABLES ::
	score dd 0					; Player's score, increases with number of dots and fruit eaten
	level dd 1					; Level that player is playing, increases with every 244 dots eaten
	lives db 3					; Player's lives, decremented every time pacman lands in the same X and Y coordinate as a ghost
	dotsEaten db 0				; Dots pacman has eaten in a level, reset to 0 upon every new level
	gameClock dd 0				; Incremented every iteration of ControlLoop, used to show cherry and make ghosts trickle out of ghost pen
	wallColor db 9				; Holds color to draw level walls with, changes every new level
	shouldWaka db 0				; if 1, play waka sound

	beginSound BYTE "C:\Irvine\pacman_beginning.wav", 0
	endSound BYTE "C:\Irvine\pacman_death.wav", 0
	wakaSound BYTE "C:\Irvine\waka.wav", 0
	bigDotSound BYTE "C:\Irvine\bigdot.wav", 0
	cherrySound BYTE "C:\Irvine\cherry.wav", 0

	mapTemp	db "788888888888888888888888889 788888888888888888888888889 788888888888888888888888888888888888888888888888888888888888889", 0
			db "4 . . . . . . . . . . . . 4 4 . . . . . . . . . . . . 4 4wSCORE:                                                LVL   4", 0
			db "4 . 7888889 . 788888889 . 4 4 . 788888889 . 7888889 . 4 188888888888888888888888888888888888888888888888888888888888883", 0
			db "4 ~ 4     4 . 4       4 . 4 4 . 4       4 . 4     4 ~ 4                                                                ", 0
			db "4 . 1888883 . 188888883 . 183 . 188888883 . 1888883 . 4   @555555     5        5555    5       5      5      5    555  ", 0
			db "4 . . . . . . . . . . . . . . . . . . . . . . . . . . 4   @2222222   222     22222266  225   522     222     225  222  ", 0
			db "4 . 7888889 . 789 . 788888888888889 . 789 . 7888889 . 4   @2222226  22222   Q2222      222252222    22222    22225222  ", 0
			db "4 . 1888883 . 4 4 . 1888889 7888883 . 4 4 . 1888883 . 4   @222     2222222   22222255  222222222   2222222   22222222  ", 0
			db "4 . . . . . . 4 4 . . . . 4 4 . . . . 4 4 . . . . . . 4   @666    666666666    6666    666666666  666666666  66666666  ", 0
			db "18888888889 . 4 1888889   4 4   7888883 4 . 78888888883                               wby Bobby Martin & Jared Conroy  ", 0
			db "          4 . 4 7888883   183   1888889 4 . 4                                                                          ", 0
			db "          4 . 4 4                     4 4 . 4           788888888888888888888888888888888888888888888888888888888888889", 0
			db "          4 . 4 4   78888_____88889   4 4 . 4           4wRULES:                                                      4", 0
			db "88888888883 . 183   4             4   183 . 18888888888 4                                                             4", 0
			db "<           .       4             4       .           > 4w- USE THE ARROW KEYS TO MOVE PACMAN                         4", 0
			db "88888888889 . 789   4             4   789 . 78888888888 4w- DON'T MAKE CONTACT WITH THE GHOSTS                        4", 0
			db "          4 . 4 4   188888888888883   4 4 . 4           4w- EAT ALL THE DOTS TO MOVE TO THE NEXT LEVEL                4", 0
			db "          4 . 4 4                     4 4 . 4           4                                                             4", 0
			db "          4 . 4 4   788888888888889   4 4 . 4           4wVALUE:                                                      4", 0
			db "78888888883 . 183   1888889 7888883   183 . 18888888889 4                                                             4", 0
			db "4 . . . . . . . . . . . . 4 4 . . . . . . . . . . . . 4 4 . w!0 POINTS                                                4", 0
			db "4 . 7888889 . 788888889 . 4 4 . 788888889 . 7888889 . 4 4 ~ wf0 POINTS                                                4", 0
			db "4 . 18889 4 . 188888883 . 183 . 188888883 . 4 78883 . 4 4=%w!00 POINTS                                                4", 0
			db "4 ~ . . 4 4 . . . . . . .     . . . . . . . 4 4 . . ~ 4 188888888888888888888888888888888888888888888888888888888888883", 0
			db "18889 . 4 4 . 789 . 788888888888889 . 789 . 4 4 . 78883                                                                ", 0
			db "78883 . 183 . 4 4 . 1888889 7888883 . 4 4 . 183 . 18889                                                                ", 0
			db "4 . . . . . . 4 4 . . . . 4 4 . . . . 4 4 . . . . . . 4                                                                ", 0
			db "4 . 78888888883 1888889 . 4 4 . 7888883 18888888889 . 4  wLIVES:                                                       ", 0
			db "4 . 1888888888888888883 . 183 . 1888888888888888883 . 4                                                                ", 0
			db "4 . . . . . . . . . . . . . . . . . . . . . . . . . . 4                                                                ", 0
			db "1888888888888888888888888888888888888888888888888888883                                                                 "

	theMap  db "788888888888888888888888889 788888888888888888888888889 788888888888888888888888888888888888888888888888888888888888889", 0
			db "4 . . . . . . . . . . . . 4 4 . . . . . . . . . . . . 4 4wSCORE:                                                LVL   4", 0
			db "4 . 7888889 . 788888889 . 4 4 . 788888889 . 7888889 . 4 188888888888888888888888888888888888888888888888888888888888883", 0
			db "4 ~ 4     4 . 4       4 . 4 4 . 4       4 . 4     4 ~ 4                                                                ", 0
			db "4 . 1888883 . 188888883 . 183 . 188888883 . 1888883 . 4   @555555     5        5555    5       5      5      5    555  ", 0
			db "4 . . . . . . . . . . . . . . . . . . . . . . . . . . 4   @2222222   222     22222266  225   522     222     225  222  ", 0
			db "4 . 7888889 . 789 . 788888888888889 . 789 . 7888889 . 4   @2222226  22222   Q2222      222252222    22222    22225222  ", 0
			db "4 . 1888883 . 4 4 . 1888889 7888883 . 4 4 . 1888883 . 4   @222     2222222   22222255  222222222   2222222   22222222  ", 0
			db "4 . . . . . . 4 4 . . . . 4 4 . . . . 4 4 . . . . . . 4   @666    666666666    6666    666666666  666666666  66666666  ", 0
			db "18888888889 . 4 1888889   4 4   7888883 4 . 78888888883                               wby Bobby Martin & Jared Conroy  ", 0
			db "          4 . 4 7888883   183   1888889 4 . 4                                                                          ", 0
			db "          4 . 4 4                     4 4 . 4           788888888888888888888888888888888888888888888888888888888888889", 0
			db "          4 . 4 4   78888_____88889   4 4 . 4           4wRULES:                                                      4", 0
			db "88888888883 . 183   4             4   183 . 18888888888 4                                                             4", 0
			db "<           .       4             4       .           > 4w- USE THE ARROW KEYS TO MOVE PACMAN                         4", 0
			db "88888888889 . 789   4             4   789 . 78888888888 4w- DON'T MAKE CONTACT WITH THE GHOSTS                        4", 0
			db "          4 . 4 4   188888888888883   4 4 . 4           4w- EAT ALL THE DOTS TO MOVE TO THE NEXT LEVEL                4", 0
			db "          4 . 4 4                     4 4 . 4           4                                                             4", 0
			db "          4 . 4 4   788888888888889   4 4 . 4           4wVALUE:                                                      4", 0
			db "78888888883 . 183   1888889 7888883   183 . 18888888889 4                                                             4", 0
			db "4 . . . . . . . . . . . . 4 4 . . . . . . . . . . . . 4 4 . w!0 POINTS                                                4", 0
			db "4 . 7888889 . 788888889 . 4 4 . 788888889 . 7888889 . 4 4 ~ wf0 POINTS                                                4", 0
			db "4 . 18889 4 . 188888883 . 183 . 188888883 . 4 78883 . 4 4=%w!00 POINTS                                                4", 0
			db "4 ~ . . 4 4 . . . . . . .     . . . . . . . 4 4 . . ~ 4 188888888888888888888888888888888888888888888888888888888888883", 0
			db "18889 . 4 4 . 789 . 788888888888889 . 789 . 4 4 . 78883                                                                ", 0
			db "78883 . 183 . 4 4 . 1888889 7888883 . 4 4 . 183 . 18889                                                                ", 0
			db "4 . . . . . . 4 4 . . . . 4 4 . . . . 4 4 . . . . . . 4                                                                ", 0
			db "4 . 78888888883 1888889 . 4 4 . 7888883 18888888889 . 4  wLIVES:                                                       ", 0
			db "4 . 1888888888888888883 . 183 . 1888888888888888883 . 4                                                                ", 0
			db "4 . . . . . . . . . . . . . . . . . . . . . . . . . . 4                                                                ", 0
			db "1888888888888888888888888888888888888888888888888888883                                                                 "

	aLife db "   @5555  ",0
		  db " @22222266",0
		  db "@Q2222    ",0
		  db " @22222266",0
		  db "   @5555  ",0
						

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

	endScreen db " ~ 789 789 789 789 789 789 789 789 789 789 788888888888888888888888888888889 789 789 789 789 789 789 789 789 789 789 ~", 0
			  db " 783 183 183 183 183 183 183 183 183 183 183 wBobby Martin & Jared Conroy  183 183 183 183 183 183 183 183 183 183 189", 0
			  db " 189                                                                                                               783", 0
			  db " 783                                                                                                               189", 0
			  db " 189                                                                                                               783", 0
			  db " 783                                                                                                               189", 0
			  db " 189                                                                                                               783", 0
			  db " 783                  =222222   22222  222    222 2222222      222222  22    22 2222222 222222                     189", 0
			  db " 189                 =22       22   22 2222  2222 22          22    22 22    22 22      22   22                    783", 0
			  db " 783                 =22   222 2222222 22 2222 22 22222       22    22 22    22 22222   222222                     189", 0
  			  db " 189                 =22    22 22   22 22  22  22 22          22    22  22  22  22      22   22                    783", 0
			  db " 783                  =222222  22   22 22      22 2222222      222222    2222   2222222 22   22                    189", 0
			  db " 189                                                                                                               783", 0
			  db " 783                        wYOU MADE IT TO LEVEL                    WITH A SCORE OF                               189", 0
			  db " 189                                                                                                               783", 0
			  db " 783                                                                                                               189", 0
			  db " 189                                                                                                               783", 0
			  db " 783                                                                                                               189", 0
			  db " 189                                                   @55555555                                                   783", 0
			  db " 783                                                 @222222222226                                                 189", 0
			  db " 189                                                @2222k22266                                                    783", 0
			  db " 783                                               @Q2222x2                                                        189", 0
			  db " 189                                                @2222x22255                                                    783", 0
			  db " 783                                                 @222x22222225                                                 189", 0
			  db " 189                                                   @66666666                                                   783", 0
			  db " 783                                                                                                               189", 0
			  db " 189                                                                                                               783", 0
			  db " 783                                                                                                               189", 0
			  db " 189 789 789 789 789 789 789 789 789 789 789 789wPRESS ANY KEY TO EXIT 789 789 789 789 789 789 789 789 789 789 789 783", 0
			  db " ~ 183 183 183 183 183 183 183 183 183 183 183 1888888888888888888888883 183 183 183 183 183 183 183 183 183 183 183 ~", 0

.code

main PROC

	call Randomize
	call DrawSplash
	SPLASHSCRN:
		call ReadKey
		cmp eax, 1
		jne STARTGAME
		mov eax, 10
		call Delay
		jmp SPLASHSCRN

	STARTGAME:
	call clrscr
	call DrawMap
	call SetupGame

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

SetupGame PROC

	mov moveInst, OFFSET MovePacLeft
	mov moveCache, OFFSET MovePacLeft
	mov gameClock, 0

	mov pacXCoord, 28
	mov pacYCoord, 23

	mov pacChar1, ">"
	mov pacChar2, "'"

	mov G1XCoord, 26
	mov G1YCoord, 11

	mov G2XCoord, 22
	mov G2YCoord, 14

	mov G3XCoord, 26
	mov G3YCoord, 14

	mov G4XCoord, 30
	mov G4YCoord, 14

	call ShowPac
	call ShowG1
	call ShowG2
	call ShowG3
	call ShowG4
	call ShowReady

	invoke sndPlaySound, offset beginSound, 0000

	call UnShowReady
	ret

SetupGame ENDP

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
		mov eax, 15
		call SetTextColor
		mov dh, 1
		mov dl, 116
		call Gotoxy
		mov eax, level
		call writeDec

		mov dh, 27
		mov dl, 65
		call Gotoxy
		movzx eax, lives
		call WriteDec

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

	cmp al, "f"
	je PRINTFIVEPLS

	cmp al, "!"
	je PRINTONEPLS

	cmp al, "_"
	je PRINTGATEPLS

	cmp al, "%"
	je PRINTCHERRYPLS

	cmp al, "<"
	je PRINTSPACEPLS

	cmp al, ">"
	je PRINTSPACEPLS

	cmp al, "k"
	je PRINTPACEYEPLS

	cmp al, "m"
	je PRINTTOPTEARPLS

	cmp al, "s"
	je PRINTMIDDLETEARPLS

	cmp al, "q"
	je PRINTLEFTTEARPLS

	cmp al, "z"
	je PRINTRIGHTTEARPLS

	cmp al, "x"
	je PRINTBOTTOMTEARPLS

	cmp al, 0
	je CARRIAGERETURNPLS

	cmp al, " "
	je PRINTSPACEPLS

	call WriteChar
	jmp KEEPDRAWING

	PRINTSPACEPLS :
		mov eax, " "
		call WriteChar
		jmp KEEPDRAWING

	SETYELLOW :
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

	PRINTPACEYEPLS :
		call PrintPacEye
		jmp KEEPDRAWING

	PRINTTOPTEARPLS :
		call PrintTopTear
		jmp KEEPDRAWING

	PRINTMIDDLETEARPLS :
		call PrintMiddleTear
		jmp KEEPDRAWING

	PRINTLEFTTEARPLS :
		call PrintLeftTear
		jmp KEEPDRAWING

	PRINTRIGHTTEARPLS :
		call PrintRightTear
		jmp KEEPDRAWING

	PRINTBOTTOMTEARPLS :
		call PrintBottomTear
		jmp KEEPDRAWING

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

	PRINTFIVEPLS:
		call PrintFive
		jmp KEEPDRAWING

	PRINTONEPLS:
		call PrintOne
		jmp KEEPDRAWING

	PRINTEYELEFTPLS :
		call PrintEyeLeft
		jmp KEEPDRAWING

	PRINTEYERIGHTPLS :
		call PrintEyeRight
		jmp KEEPDRAWING

	PRINTWALL7PLS :
		call PrintWall7
		jmp KEEPDRAWING

	PRINTWALL9PLS :
		call PrintWall9
		jmp	KEEPDRAWING

	PRINTWALL1PLS :
		call PrintWall1
		jmp KEEPDRAWING

	PRINTWALL3PLS :
		call PrintWall3
		jmp KEEPDRAWING

	PRINTWALL8PLS :
		call PrintWall8
		jmp KEEPDRAWING

	PRINTWALL4PLS :
		call PrintWall4
		jmp KEEPDRAWING

	PRINTBLOCKPLS :
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

	PRINTDOTPLS :
		call PrintDot
		jmp KEEPDRAWING

	PRINTBIGDOTPLS :
		call PrintBigDot
		jmp KEEPDRAWING

	PRINTGATEPLS :
		call PrintGate
		jmp KEEPDRAWING

	PRINTCHERRYPLS:
		call PrintCherry
		jmp KEEPDRAWING

	CARRIAGERETURNPLS :
		call CarriageReturn

	KEEPDRAWING :
		ret

DrawWhatYouSee ENDP

PrintPacEye PROC

	mov eax, 14*16
	call SetTextColor
	mov eax, 223
	call WriteChar
	mov eax, 14
	call SetTextColor

	ret

PrintPacEye ENDP

PrintTopTear PROC

	mov eax, 11 + (14*16)
	call SetTextColor
	mov eax, 220
	call WriteChar
	mov eax, 14
	call SetTextColor

ret

PrintTopTear ENDP

PrintMiddleTear PROC

	mov eax, 11
	call SetTextColor
	mov eax, 219
	call WriteChar
	mov eax, 14
	call SetTextColor

	ret

PrintMiddleTear ENDP

PrintLeftTear PROC

	mov eax, 11 + (14 * 16)
	call SetTextColor
	mov eax, 222
	call WriteChar
	mov eax, 14
	call SetTextColor

	ret

PrintLeftTear ENDP

PrintRightTear PROC

	mov eax, 11 + (14 * 16)
	call SetTextColor
	mov eax, 221
	call WriteChar
	mov eax, 14
	call SetTextColor

	ret

PrintRightTear ENDP

PrintBottomTear PROC

	mov eax, 11 + (14 * 16)
	call SetTextColor
	mov eax, 223
	call WriteChar
	mov eax, 14
	call SetTextColor

	ret

PrintBottomTear ENDP

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

PrintFive PROC

	mov eax, 53
	call WriteChar

	ret

PrintFive ENDP

PrintOne PROC

	mov eax, 49
	call WriteChar

	ret

PrintOne ENDP

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

	movzx eax, wallColor
	call SetTextColor
	mov eax, 201
	call WriteChar
	
	ret

PrintWall7 ENDP

PrintWall9 PROC

	movzx eax, wallColor
	call SetTextColor
	mov eax, 187
	call WriteChar
		
	ret

PrintWall9 ENDP

PrintWall1 PROC

	movzx eax, wallColor
	call SetTextColor
	mov eax, 200
	call WriteChar
	
	ret

PrintWall1 ENDP

PrintWall3 PROC

	movzx eax, wallColor
	call SetTextColor
	mov eax, 188
	call WriteChar
	
	ret

PrintWall3 ENDP

PrintWall8 PROC

	movzx eax, wallColor
	call SetTextColor
	mov eax, 205
	call WriteChar
	
	ret

PrintWall8 ENDP

PrintWall4 PROC

	movzx eax, wallColor
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

PrintCherry PROC

	mov eax, 12
	call SetTextColor
	mov eax, "%"
	call WriteChar

	ret

PrintCherry ENDP

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

	jmp YOUGOTCAUGHT

	SAFEFROMG1:
		cmp al, G2XCoord
		jne SAFEFROMG2

		cmp bl, G2YCoord
		jne SAFEFROMG2

		jmp YOUGOTCAUGHT

	SAFEFROMG2:
		cmp al, G3XCoord
		jne SAFEFROMG3

		cmp bl, G3YCoord
		jne SAFEFROMG3

		jmp YOUGOTCAUGHT

	SAFEFROMG3:
		cmp al, G4XCoord
		jne HELIVES

		cmp bl, G4YCoord
		jne HELIVES

		jmp YOUGOTCAUGHT

		jmp HELIVES

	YOUGOTCAUGHT:
		call PacDeathAnim
		dec lives
		cmp lives, -1
		je HEDEAD
		call ClrScr
		call DrawMap
		call SetupGame
		jmp HELIVES
		
	HEDEAD:
		mov gameIsOver, 0FFh
		mov eax, 500
		call Delay

	HELIVES:
		ret

IsPacKill ENDP

PacDeathAnim PROC

	mov dl, pacXCoord
	mov dh, pacYCoord

	mov eax, black+(yellow*16)
	call SetTextColor

	call GotoXY
	mov eax, ">"
	call WriteChar
	mov eax, "'"
	call WriteChar

	mov eax, 100
	call Delay

	call GotoXY
	call GotoXY
	mov eax, "V"
	call WriteChar
	mov eax, ":"
	call WriteChar

	mov eax, 100
	call Delay

	call GotoXY
	call GotoXY
	mov eax, "."
	call WriteChar
	mov eax, "<"
	call WriteChar

	mov eax, 100
	call Delay

	call GotoXY
	call GotoXY
	mov eax, ":"
	call WriteChar
	mov eax, 239
	call WriteChar

	mov eax, 100
	call Delay

	call GotoXY
	mov eax, ">"
	call WriteChar
	mov eax, "'"
	call WriteChar

	invoke sndPlaySound, offset endSound, 0000

	mov eax, 8
	call SetTextColor

	ret

PacDeathAnim ENDP

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

SummonG2 PROC

	call UnShowG2
	mov G2XCoord, 26
	mov G2YCoord, 11
	call ShowG2

	ret

SummonG2 ENDP

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
; G3 MOVEMENT PROCEDURES

ShowG3 PROC

	mov eax, white+(11*16)
	call SetTextColor

	mov dl, G3XCoord
	mov dh, G3YCoord
	call Gotoxy

	mov eax, 248
	call WriteChar
	call WriteChar

	mov eax, 0Fh
	call SetTextColor

	ret

ShowG3 ENDP

UnShowG3 PROC

	mov dl, G3XCoord
	mov dh, G3YCoord
	call Gotoxy			; move cursor to desired X and Y coordinate

	mov esi, OFFSET theMap
	movzx eax, G3YCoord
	movzx ebx, G3XCoord
	call CheckPos
	call DrawWhatYouSee
	inc esi
	mov al, [esi]
	call DrawWhatYouSee

	ret

UnShowG3 ENDP

; move PacMan up one space

MoveG3Up PROC uses edx

	movzx eax, G3YCoord
	movzx ebx, G3XCoord
	call CheckAbove

	call CanIGoHere
	cmp ebx, 1
	je ENDG3UP

	CARRYG3UP:
		call UnShowG3
		dec G3YCoord		; move up 1 Y-coordinate

		call ShowG3

	ENDG3UP:
		ret

MoveG3Up ENDP

; move G3 down one space

MoveG3Down PROC uses edx

	movzx eax, G3YCoord
	movzx ebx, G3XCoord
	call CheckBelow

	call CanIGoHere
	cmp ebx, 1
	je ENDG3DOWN

	CARRYG3DOWN:
		call UnShowG3
		inc G3YCoord		; move down 1 Y-coordinate

		call ShowG3

	ENDG3DOWN:
		ret

MoveG3Down ENDP

; move G3 left one space

MoveG3Left PROC uses edx

	movzx eax, G3YCoord
	movzx ebx, G3XCoord
	call CheckLeft

	call CanIGoHere
	cmp ebx, 1
	je ENDG3LEFT

	CARRYONG3LEFT:
		call UnShowG3
		sub G3XCoord, 2	; move left 1 X-coordinate

		call ShowG3
	
	ENDG3LEFT:
		ret

MoveG3Left ENDP

; move G3 right one space

MoveG3Right PROC uses edx

	movzx eax, G3YCoord
	movzx ebx, G3XCoord
	call CheckRight

	call CanIGoHere
	cmp ebx, 1
	je ENDG3RIGHT

	CARRYONG3RIGHT:
		call UnShowG3
		add G3XCoord, 2	; move right 1 X-coordinate

		call ShowG3

	ENDG3RIGHT:
		ret

MoveG3Right ENDP

SummonG3 PROC

	call UnShowG3
	mov G3XCoord, 26
	mov G3YCoord, 11
	call ShowG3

	ret

SummonG3 ENDP

G3Think PROC

	mov edi, OFFSET G3Options
	mov G3NumOpts, 0

	G3TRYUP:
		cmp G3MoveCache, OFFSET MoveG3Down
		je G3TRYDOWN

		movzx eax, G3YCoord
		movzx ebx, G3XCoord
		call CheckAbove
		call CanIGoHere
		cmp ebx, 1
		je G3TRYDOWN

		mov [edi], OFFSET MoveG3Up
		add edi, 4
		inc G3NumOpts

	G3TRYDOWN:
		cmp G3MoveCache, OFFSET MoveG3Up
		je G3TRYLEFT

		movzx eax, G3YCoord
		movzx ebx, G3XCoord
		call CheckBelow
		call CanIGoHere
		cmp ebx, 1
		je G3TRYLEFT

		mov [edi], OFFSET MoveG3Down
		add edi, 4
		inc G3NumOpts

	G3TRYLEFT:
		cmp G3MoveCache, OFFSET MoveG3Right
		je G3TRYRIGHT

		movzx eax, G3YCoord
		movzx ebx, G3XCoord
		call CheckLeft
		call CanIGoHere
		cmp ebx, 1
		je G3TRYRIGHT

		mov [edi], OFFSET MoveG3Left
		add edi, 4
		inc G3NumOpts

	G3TRYRIGHT:
		cmp G3MoveCache, OFFSET MoveG3Left
		je G3PREDECISION

		movzx eax, G3YCoord
		movzx ebx, G3XCoord
		call CheckRight
		call CanIGoHere
		cmp ebx, 1
		je G3PREDECISION

		mov [edi], OFFSET MoveG3Right
		add edi, 4
		inc G3NumOpts

	G3PREDECISION:
		cmp G3NumOpts, 0
		jne G3DECIDE

		inc G3NumOpts
		mov eax, G3MoveCache
		mov G3options, eax

	G3DECIDE:
		movzx eax, G3NumOpts
		call RandomRange
		mov bl, 4
		mul bl
		mov esi, OFFSET G3Options
		add esi, eax
		mov eax, [esi]
		mov G3MoveInst, eax

	TRYG3MOVE:
		mov eax, OFFSET MoveG3Up
		mov eax, G3moveInst
		call NEAR PTR eax		; Try executing G3moveInst
		cmp ebx, 1				; If G3moveInst failed
		je G3CANTGOTHERE		; G3 can't go there

		mov eax, G3moveInst		; Move desired instruction back into eax
		mov G3moveCache, eax	; Movement succeeded, store the movement we just made in moveCache
		ret						; you did it

	G3CANTGOTHERE:
		mov eax, G3moveCache	; move the cached movement into eax (we know it will execute because it was stored in the cache in the first place, see above)
		call NEAR PTR eax		; DOIT

	movzx eax, G3YCoord
	movzx ebx, G3XCoord
	call CheckPos

	cmp al, ">"
	je G3TRAVERSERIGHTTUBE

	cmp al, "<"
	je G3TRAVERSELEFTTUBE

	jmp G3ENDCHARCHECK

	G3TRAVERSELEFTTUBE:
		mov fixRightTube, 0FFh
		mov fixLeftTube, 0ffh
		mov G3XCoord, 54
		mov G3YCoord, 14
		call ShowG3
		jmp G3ENDCHARCHECK

	G3TRAVERSERIGHTTUBE:
		mov fixRightTube, 0FFh
		mov fixLeftTube, 0ffh
		mov G3XCoord, 0
		mov G3YCoord, 14
		call ShowG3
		jmp G3ENDCHARCHECK

	G3ENDCHARCHECK:
		ret

G3Think ENDP

; ********************************************************************************************************************************************************************************************************
; G4 MOVEMENT PROCEDURES

ShowG4 PROC

	mov eax, white+(10*16)
	call SetTextColor

	mov dl, G4XCoord
	mov dh, G4YCoord
	call Gotoxy

	mov eax, 248
	call WriteChar
	call WriteChar

	mov eax, 0Fh
	call SetTextColor

	ret

ShowG4 ENDP

UnShowG4 PROC

	mov dl, G4XCoord
	mov dh, G4YCoord
	call Gotoxy			; move cursor to desired X and Y coordinate

	mov esi, OFFSET theMap
	movzx eax, G4YCoord
	movzx ebx, G4XCoord
	call CheckPos
	call DrawWhatYouSee
	inc esi
	mov al, [esi]
	call DrawWhatYouSee

	ret

UnShowG4 ENDP

; move PacMan up one space

MoveG4Up PROC uses edx

	movzx eax, G4YCoord
	movzx ebx, G4XCoord
	call CheckAbove

	call CanIGoHere
	cmp ebx, 1
	je ENDG4UP

	CARRYG4UP:
		call UnShowG4
		dec G4YCoord		; move up 1 Y-coordinate

		call ShowG4

	ENDG4UP:
		ret

MoveG4Up ENDP

; move G4 down one space

MoveG4Down PROC uses edx

	movzx eax, G4YCoord
	movzx ebx, G4XCoord
	call CheckBelow

	call CanIGoHere
	cmp ebx, 1
	je ENDG4DOWN

	CARRYG4DOWN:
		call UnShowG4
		inc G4YCoord		; move down 1 Y-coordinate

		call ShowG4

	ENDG4DOWN:
		ret

MoveG4Down ENDP

; move G4 left one space

MoveG4Left PROC uses edx

	movzx eax, G4YCoord
	movzx ebx, G4XCoord
	call CheckLeft

	call CanIGoHere
	cmp ebx, 1
	je ENDG4LEFT

	CARRYONG4LEFT:
		call UnShowG4
		sub G4XCoord, 2	; move left 1 X-coordinate

		call ShowG4
	
	ENDG4LEFT:
		ret

MoveG4Left ENDP

; move G4 right one space

MoveG4Right PROC uses edx

	movzx eax, G4YCoord
	movzx ebx, G4XCoord
	call CheckRight

	call CanIGoHere
	cmp ebx, 1
	je ENDG4RIGHT

	CARRYONG4RIGHT:
		call UnShowG4
		add G4XCoord, 2	; move right 1 X-coordinate

		call ShowG4

	ENDG4RIGHT:
		ret

MoveG4Right ENDP

SummonG4 PROC

	call UnShowG4
	mov G4XCoord, 26
	mov G4YCoord, 11
	call ShowG4

	ret

SummonG4 ENDP

G4Think PROC

	mov edi, OFFSET G4Options
	mov G4NumOpts, 0

	G4TRYUP:
		cmp G4MoveCache, OFFSET MoveG4Down
		je G4TRYDOWN

		movzx eax, G4YCoord
		movzx ebx, G4XCoord
		call CheckAbove
		call CanIGoHere
		cmp ebx, 1
		je G4TRYDOWN

		mov [edi], OFFSET MoveG4Up
		add edi, 4
		inc G4NumOpts

	G4TRYDOWN:
		cmp G4MoveCache, OFFSET MoveG4Up
		je G4TRYLEFT

		movzx eax, G4YCoord
		movzx ebx, G4XCoord
		call CheckBelow
		call CanIGoHere
		cmp ebx, 1
		je G4TRYLEFT

		mov [edi], OFFSET MoveG4Down
		add edi, 4
		inc G4NumOpts

	G4TRYLEFT:
		cmp G4MoveCache, OFFSET MoveG4Right
		je G4TRYRIGHT

		movzx eax, G4YCoord
		movzx ebx, G4XCoord
		call CheckLeft
		call CanIGoHere
		cmp ebx, 1
		je G4TRYRIGHT

		mov [edi], OFFSET MoveG4Left
		add edi, 4
		inc G4NumOpts

	G4TRYRIGHT:
		cmp G4MoveCache, OFFSET MoveG4Left
		je G4PREDECISION

		movzx eax, G4YCoord
		movzx ebx, G4XCoord
		call CheckRight
		call CanIGoHere
		cmp ebx, 1
		je G4PREDECISION

		mov [edi], OFFSET MoveG4Right
		add edi, 4
		inc G4NumOpts

	G4PREDECISION:
		cmp G4NumOpts, 0
		jne G4DECIDE

		inc G4NumOpts
		mov eax, G4MoveCache
		mov G4options, eax

	G4DECIDE:
		movzx eax, G4NumOpts
		call RandomRange
		mov bl, 4
		mul bl
		mov esi, OFFSET G4Options
		add esi, eax
		mov eax, [esi]
		mov G4MoveInst, eax

	TRYG4MOVE:
		mov eax, OFFSET MoveG4Up
		mov eax, G4moveInst
		call NEAR PTR eax		; Try executing G4moveInst
		cmp ebx, 1				; If G4moveInst failed
		je G4CANTGOTHERE		; G4 can't go there

		mov eax, G4moveInst		; Move desired instruction back into eax
		mov G4moveCache, eax	; Movement succeeded, store the movement we just made in moveCache
		ret						; you did it

	G4CANTGOTHERE:
		mov eax, G4moveCache	; move the cached movement into eax (we know it will execute because it was stored in the cache in the first place, see above)
		call NEAR PTR eax		; DOIT

	movzx eax, G4YCoord
	movzx ebx, G4XCoord
	call CheckPos

	cmp al, ">"
	je G4TRAVERSERIGHTTUBE

	cmp al, "<"
	je G4TRAVERSELEFTTUBE

	jmp G4ENDCHARCHECK

	G4TRAVERSELEFTTUBE:
		mov fixRightTube, 0FFh
		mov fixLeftTube, 0ffh
		mov G4XCoord, 54
		mov G4YCoord, 14
		call ShowG4
		jmp G4ENDCHARCHECK

	G4TRAVERSERIGHTTUBE:
		mov fixRightTube, 0FFh
		mov fixLeftTube, 0ffh
		mov G4XCoord, 0
		mov G4YCoord, 14
		call ShowG4
		jmp G4ENDCHARCHECK

	G4ENDCHARCHECK:
		ret

G4Think ENDP

; ********************************************************************************************************************************************************************************************************

ShowCherry PROC

	mov dh, 17
	mov dl, 28
	call GotoXY
	call PrintCherry

	mov eax, 17
	mov esi, OFFSET theMap
	mov ebx, LENGTHOF theMap
	mul ebx
	mov ebx, 28
	add eax, ebx
	add esi, eax
	mov bl, "%"
	mov [esi], bl

	mov eax, 17
	mov ebx, 28
	call CheckPos

	ret

ShowCherry ENDP

SHOWREADY PROC

	mov dh, 17
	mov dl, 23
	call GotoXY
	mov eax, 12
	call SetTextColor
	mov edx, OFFSET ready
	call WriteString

	mov eax, 8
	call SetTextColor

	ret

SHOWREADY ENDP

UNSHOWREADY PROC

	mov dh, 17
	mov dl, 23
	call GotoXY
	mov eax, " "
	mov ecx, 9
	UNSHOWTHEREADY:
		call WriteChar
		loop UNSHOWTHEREADY

	ret

UNSHOWREADY ENDP

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

NextLevel PROC

	inc level
	mov esi, OFFSET mapTemp
	mov edi, OFFSET theMap
	mov ecx, mapSize
	mov edx, 0
	call Gotoxy
	RESETMAP:
		mov al, [esi]
		mov [edi], al
		inc esi
		inc edi
		loop RESETMAP

	cmp wallColor, 13
	jne DONTLOOPWALLCOLORBACK
	mov wallColor, 8

	DONTLOOPWALLCOLORBACK:
		inc wallColor

	call clrscr
	call DrawMap
	mov dotsEaten, 0
	call SetupGame

	ret

NextLevel ENDP

; MAKE THIS WORK

PrintALife PROC

	; line length = 11
	mov edx, OFFSET aLife
	mov ecx, 5

	PRINTTHATLIFE:
		call GotoXY
		call WriteString
		add edx, LENGTHOF aLife
		inc dh
		loop PRINTTHATLIFE

	ret

PrintALife ENDP

ControlLoop PROC uses eax

	mov edx, 0141h
	call Gotoxy
	mov eax, score
	call WriteDec

	cmp gameClock, 150
	jne DONTSHOWCHERRY
	call ShowCherry

	DONTSHOWCHERRY:

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
	call G3Think
	call G4Think

	cmp gameClock, 50
	jne DONTSUMMONG2
	call SummonG2

	DONTSUMMONG2:

	cmp gameClock, 100
	jne DONTSUMMONG3
	call SummonG3

	DONTSUMMONG3:

	cmp gameClock, 150
	jne DONTSUMMONG4
	call SummonG4

	DONTSUMMONG4:

	movzx eax, pacYCoord
	movzx ebx, pacXCoord
	call CheckPos
	mov edx, " "

	cmp al, "."
	je SCOREDOT

	cmp al, "~"
	je SCOREBIGDOT

	cmp al, "%"
	je SCORECHERRY

	cmp al, ">"
	je TRAVERSERIGHTTUBE

	cmp al, "<"
	je TRAVERSELEFTTUBE

	jmp ENDCHARCHECK

	SCOREDOT :
		add score, 10
		inc dotsEaten
		mov[esi], dl
		cmp shouldWaka, 1
		je doTheWaka
		inc shouldWaka
		jmp ENDCHARCHECK

	doTheWaka :
		invoke sndPlaySound, offset wakaSound, 0001
		dec shouldWaka
		jmp ENDCHARCHECK
 
	SCOREBIGDOT :
		add score, 50
		inc dotsEaten
		mov[esi], dl
		mov shouldWaka, 0
		invoke sndPlaySound, offset bigDotSound, 0001
		jmp ENDCHARCHECK
 
	SCORECHERRY :
		add score, 100
		mov[esi], dl
		mov shouldWaka, 0
		invoke sndPlaySound, offset cherrySound, 0001
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

	cmp dotsEaten, 244
	jne KEEPEATING
	mov eax, 1000
	call Delay
	call NextLevel

	KEEPEATING:

	inc gameClock
	ret

ControlLoop ENDP

GameOver PROC

	call ClrScr
	mov ecx, endSize; TODO: un - hardcode this
	mov esi, OFFSET endScreen

	DRAWENDLOOP:
		mov eax, 0
		mov al, [esi]
	
		call DrawWhatYouSee
		inc esi
		loop DRAWENDLOOP

	mov eax, 12
	Call SetTextColor
	mov edx, 0D32h
	call GotoXY
	mov eax, level
	call WriteDec

	mov edx, 0D55h
	call GotoXY
	mov eax, score
	call WriteDec

	ENDDRAWEND :
		mov eax, 8
		call SetTextColor

	GAMEOVERPRESS:
		call ReadKey
		cmp eax, 1
		jne ENDITALL
		mov eax, 10
		call Delay
		jmp GAMEOVERPRESS

	ENDITALL:

	ret

GameOver ENDP

end main