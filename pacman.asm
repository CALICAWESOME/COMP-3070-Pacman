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

	beginSound BYTE "C:\Pacman-Conroy_Martin\sounds\pacman_beginning.wav", 0
	endSound BYTE "C:\Pacman-Conroy_Martin\sounds\pacman_death.wav", 0
	wakaSound BYTE "C:\Pacman-Conroy_Martin\sounds\waka.wav", 0
	bigDotSound BYTE "C:\Pacman-Conroy_Martin\sounds\bigdot.wav", 0
	cherrySound BYTE "C:\Pacman-Conroy_Martin\sounds\cherry.wav", 0

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

;:: SETUPGAME ::
; Called when pacman dies, or when the player reaches the next level
; Only called after map has been drawn or re-drawn
; 
; Resets Pacman, G1, G2, G3 and G4 to starting positions
; Pacman: Where pacman would start in actual pacman
; G1: just outside of ghost pen
; G2, G3, G4: evenly spaced inside ghost pen

SetupGame PROC

	mov moveInst, OFFSET MovePacLeft	; Start pacman off moving left
	mov moveCache, OFFSET MovePacLeft	; and make sure he stays moving left
	mov gameClock, 0

	mov pacXCoord, 28
	mov pacYCoord, 23

	mov pacChar1, ">"	; make pacman look like he is facing left, like his moveInst
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

	invoke sndPlaySound, offset beginSound, 0000	; Play the start level jingle

	call UnShowReady	; get rid of the red "R E A D Y" text
	ret

SetupGame ENDP

;:: DRAWMAP ::
; Draws the pac-man map using theMap as a template to make it really pretty

DrawMap PROC uses eax

	mov ecx, mapSize
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
		mov eax, level		; show level in sidebar
		call writeDec

		mov dh, 27
		mov dl, 65
		call Gotoxy
		movzx eax, lives	; show lives in sidebar
		call WriteDec

		mov eax, 8
		call SetTextColor	; reset text color

		ret

DrawMap ENDP

;:: DRAWSPLASH ::
; Draws the opening splash screen
; works the same way as DrawMap

DrawSplash PROC uses eax

mov ecx, splashSize
mov esi, OFFSET splash

DRAWSPLASHLOOP:
	mov eax, 0
	mov al, [esi]

	call DrawWhatYouSee
	inc esi
	loop DRAWSPLASHLOOP

	mov eax, 8
	call SetTextColor	; reset text color

	ret

DrawSPLASH ENDP

;:: DRAWWHATYOUSEE ::
; Since visual studio gets whiny when you try and write any extended ascii characters in your .asm file
; we wrote this procedure to decode special characters and output them as colored/unicode characters
; for example, if the ascii code for the number '8' is stored in al when this procedure is called, the procedure will draw a horizontal double bar in the console
;
; Takes a character to draw in al, and draws the corresponding unicode (or not) character with its corresponding color in the console

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

;:: PRINTPACEYE ::
; CHARACTER: upper half block
; COLOR:	 black with yellow background

PrintPacEye PROC

	mov eax, 14*16
	call SetTextColor
	mov eax, 223
	call WriteChar
	mov eax, 14
	call SetTextColor

	ret

PrintPacEye ENDP

;:: PRINTBOTTOMTEAR ::
; CHARACTER: top half block
; COLOR:	 light cyan with yellow background

PrintBottomTear PROC

	mov eax, 11 + (14 * 16)
	call SetTextColor
	mov eax, 223
	call WriteChar
	mov eax, 14
	call SetTextColor

	ret

PrintBottomTear ENDP

; ::PRINTNOSE ::
; CHARACTER: capital C
; COLOR:	 black with yellow background

PrintNose PROC

	mov eax, 14*16
	call SetTextColor
	mov eax, 67
	call WriteChar
	mov eax, 14 ; reset to yellow
	call SetTextColor

	ret

PrintNose ENDP

; ::PRINTGLOVE ::
; CHARACTER: full block
; COLOR:	 dark red

PrintGlove PROC

	mov eax, 4
	call SetTextColor
	mov eax, 219
	call WriteChar

	ret

PrintGlove ENDP

; ::PRINTO ::
; CHARACTER: top half block
; COLOR:	 dark cyan with white background

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

; ::PRINTEYELEFT ::
; CHARACTER: right half block (not a mistake)
; COLOR:	 whatever color is currently set with a white background

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

; ::PRINTEYERIGHT ::
; CHARACTER: left half block (not a mistake)
; COLOR:	 whatever color is currently set with a white background

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

; ::PRINTTONGUE ::
; CHARACTER: bottom half block
; COLOR:	 yellow with a red background

PrintTongue PROC

	mov eax, 14 + (12 * 16)
	call SetTextColor
	mov eax, 220
	call WriteChar
	mov eax, 14; reset to yellow
	call SetTextColor

	ret

PrintTongue ENDP

; ::PRINTLEG ::
; CHARACTER: bottom half block
; COLOR:	 red with a yellow background

PrintLeg PROC

	mov eax, 12 + (14 * 16)
	call SetTextColor
	mov eax, 220
	call WriteChar
	mov eax, 14; reset to yellow
	call SetTextColor

	ret

PrintLeg ENDP

; ::PRINTEYE ::
; CHARACTER: >
; COLOR:	 whatever color is currently set

PrintEye PROC

	mov eax, 62
	call WriteChar

	ret

PrintEye endp

; ::PRINTBROWUP ::
; CHARACTER: /
; COLOR:	 black with yellow background

PrintBrowUp PROC

	mov eax, 14*16
	call SetTextColor
	mov eax, 47
	call WriteChar

	ret

PrintBrowUp ENDP

; ::PRINTBROWDOWN ::
; CHARACTER: \
; COLOR:	 black with yellow background

PrintBrowDown PROC

	mov eax, 92
	Call WriteChar
	mov eax, 14; reset to yellow
	call SetTextColor

	ret

PrintBrowDown ENDP

; ::PRINTFIVE ::
; CHARACTER: 5
; COLOR:	 whatever color is currently set

PrintFive PROC

	mov eax, 53
	call WriteChar

	ret

PrintFive ENDP

; ::PRINTONE ::
; CHARACTER: 1
; COLOR:	 whatever color is currently set

PrintOne PROC

	mov eax, 49
	call WriteChar

	ret

PrintOne ENDP

; ::PRINTBLOCK ::
; CHARACTER: full block
; COLOR:	 whatever color is currently set

PrintBlock PROC

	mov eax, 219
	call WriteChar

	ret

PrintBlock ENDP

; ::PRINTTOPBLOCK ::
; CHARACTER: top half block
; COLOR:	 whatever color is currently set

PrintTopBlock PROC

	mov eax, 223
	call WriteChar

	ret

PrintTopBlock ENDP

; ::PRINTBOTTOMBLOCK ::
; CHARACTER: bottom half block
; COLOR:	 whatever color is currently set

PrintBottomBlock PROC

	mov eax, 220
	call WriteChar

	ret

PrintBottomBlock ENDP

; ::PRINTLEFTBLOCK ::
; CHARACTER: left half block
; COLOR:	 whatever color is currently set

PrintLeftBlock PROC

	mov eax, 221
	call WriteChar

	ret

PrintLeftBlock ENDP

; ::PRINTRIGHTBLOCK ::
; CHARACTER: right half block
; COLOR:	 whatever color is currently set

PrintRightBlock PROC

	mov eax, 222
	call WriteChar

	ret

PrintRightBlock ENDP

; ::PRINTWALL7 ::
; CHARACTER: top left corner pipes
; COLOR:	 whatever color is currently in wallColor (changes each level)

PrintWall7 PROC

	movzx eax, wallColor
	call SetTextColor
	mov eax, 201
	call WriteChar
	
	ret

PrintWall7 ENDP

; ::PRINTWALL9 ::
; CHARACTER: top right corner pipes
; COLOR:	 whatever color is currently in wallColor(changes each level)

PrintWall9 PROC

	movzx eax, wallColor
	call SetTextColor
	mov eax, 187
	call WriteChar
		
	ret

PrintWall9 ENDP

; ::PRINTWALL1 ::
; CHARACTER: bottom left corner pipes
; COLOR:	 whatever color is currently in wallColor(changes each level)

PrintWall1 PROC

	movzx eax, wallColor
	call SetTextColor
	mov eax, 200
	call WriteChar
	
	ret

PrintWall1 ENDP

; ::PRINTWALL3 ::
; CHARACTER: bottom right corner pipes
; COLOR:	 whatever color is currently in wallColor(changes each level)

PrintWall3 PROC

	movzx eax, wallColor
	call SetTextColor
	mov eax, 188
	call WriteChar
	
	ret

PrintWall3 ENDP

; ::PRINTWALL8 ::
; CHARACTER: horizontal pipes
; COLOR:	 whatever color is currently in wallColor(changes each level)

PrintWall8 PROC

	movzx eax, wallColor
	call SetTextColor
	mov eax, 205
	call WriteChar
	
	ret

PrintWall8 ENDP

; ::PRINTWALL4 ::
; CHARACTER: vertical pipes
; COLOR:	 whatever color is currently in wallColor(changes each level)

PrintWall4 PROC

	movzx eax, wallColor
	call SetTextColor
	mov eax, 186
	call WriteChar
	
	ret

PrintWall4 ENDP

; ::PRINTDOT ::
; CHARACTER: centered dot
; COLOR:	 light gray

PrintDot PROC

	mov eax, 7
	call SetTextColor
	mov eax, 250
	call WriteChar
	
	ret

PrintDot ENDP

; ::PRINTBIGDOT ::
; CHARACTER: centered big dot
; COLOR:	 light gray

PrintBigDot PROC
	mov eax, 7
	call SetTextColor
	mov eax, 254
	call WriteChar
	
	ret

PrintBigDot ENDP

; ::PRINTGATE ::
; CHARACTER: horizontal singular pipe centered
; COLOR:	 red

PrintGate PROC

	mov eax, 12
	call SetTextColor
	mov eax, 196
	call WriteChar

	ret

PrintGate ENDP

; ::PRINTCHERRY ::
; CHARACTER: %
; COLOR:	 red

PrintCherry PROC

	mov eax, 12
	call SetTextColor
	mov eax, "%"
	call WriteChar

	ret

PrintCherry ENDP

; ::CARRIAGERETURN ::
; goes to the next line

CarriageReturn PROC

	call crlf
	
	ret

CarriageReturn ENDP

; ********************************************************************************************************************************************************************************************************
; PACMAN MOVEMENT PROCEDURES

;:: SHOWPAC ::
; shows pacman at the x and y coordinates stored in pacXCoord and pacYCoord respectively

ShowPac PROC uses edx

	mov eax, black+(yellow*16)
	call SetTextColor	; set the text color to black with a yellow background

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

;:: UNSHOWPAC ::
; un-shows pacman by printing two spaces at the x and y coordinates stored in pacXCoord and pacYCoord respectively

UnShowPac PROC

	mov dl, pacXCoord
	mov dh, pacYCoord
	call Gotoxy			; move cursor to desired X and Y coordinate

	mov eax, 32			; move the ascii code for space into eax to be printed
	call WriteChar		; UNSHOW ME THE MANS
	call WriteChar

	ret

UnShowPac ENDP

;:: MOVEPACUP ::
; moves pacman up one space, if possible
; if that is not possible, do nothing and return a 1 in ebx

MovePacUp PROC uses edx

	movzx eax, pacYCoord
	movzx ebx, pacXCoord
	call CheckAbove		; move the character above pacman's current position into eax

	call CanIGoHere		; check to see if pacman can move into the space above him
	cmp ebx, 1
	je ENDUP			; if he can't jump to the end of the procedure
	
	call UnShowPac		; otherwise, un-show pacman at his current poisition

	mov pacChar1, 'v'	; put the correct facing characters in the variables that show pacman
	mov pacChar2, ':'
	dec PacYCoord		; move up 1 Y-coordinate

	call ShowPac

	ENDUP:
		ret

MovePacUp ENDP

;:: MOVEPACDOWN ::
; moves pacman down one space, if possible
; if that is not possible, do nothing and return a 1 in ebx
; see MOVEPACUP for a more detailed instruction by instruction description

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

;:: MOVEPACLEFT ::
; moves pacman left one space, if possible
; if that is not possible, do nothing and return a 1 in ebx
; see MOVEPACUP for a more detailed instruction by instruction description

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

;:: MOVEPACRIGHT ::
; moves pacman right one space, if possible
; if that is not possible, do nothing and return a 1 in ebx
; see MOVEPACUP for a more detailed instruction by instruction description

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

;:: ISPACKILL ::
; checks to see if pacman's coordinates are the same as any of the ghosts', one by one

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

	YOUGOTCAUGHT:			; if pacman's coordinates are the same as any of the ghosts'
		call PacDeathAnim	; spin pacman around once
		dec lives			; lose a life
		cmp lives, -1		; if no lives are left
		je HEDEAD			; death is imminent
		call ClrScr			; otherwise, clear the screen
		call DrawMap		; and redraw the map
		call SetupGame		; and reset everybody's coordinates
		jmp HELIVES			; and start a new life
		
	HEDEAD:					; if pacman bit the dust
		mov gameIsOver, 0FFh; let the program know that the game is over. This will be checked against later
		mov eax, 500
		call Delay			; pause for emphasis

	HELIVES:
		ret

IsPacKill ENDP

;:: PACDEATHANIM ::
; an animation, shows pacman spin counterclockwise 360 degrees, starting by facing left

PacDeathAnim PROC

	mov dl, pacXCoord
	mov dh, pacYCoord

	mov eax, black+(yellow*16)
	call SetTextColor

	call GotoXY
	mov eax, ">"
	call WriteChar
	mov eax, "'"
	call WriteChar	; show pacman facing left

	mov eax, 100	; wait 100ms
	call Delay

	call GotoXY
	call GotoXY
	mov eax, "V"
	call WriteChar
	mov eax, ":"
	call WriteChar	; show pacman facing up

	mov eax, 100	; wait 100ms
	call Delay

	call GotoXY
	call GotoXY
	mov eax, "."
	call WriteChar
	mov eax, "<"
	call WriteChar	; show pacman facing right

	mov eax, 100	; wait 100ms
	call Delay

	call GotoXY
	call GotoXY
	mov eax, ":"
	call WriteChar
	mov eax, 239
	call WriteChar	; show pacman facing down

	mov eax, 100	; wait 100ms
	call Delay

	call GotoXY
	mov eax, ">"
	call WriteChar
	mov eax, "'"
	call WriteChar	; show pacman facing left

	invoke sndPlaySound, offset endSound, 0000	; play pacman death sound

	mov eax, 8
	call SetTextColor	; reset text color

	ret

PacDeathAnim ENDP

; ********************************************************************************************************************************************************************************************************
; G1 MOVEMENT PROCEDURES

;:: SHOWG1 ::
; Works the same way as ShowPac
; Shows a ghost at x and y positions G1XCoord and GYCoord respectively

ShowG1 PROC

	mov eax, white+(lightred*16)	; G1 has white eyes with a light red background
	call SetTextColor

	mov dl, G1XCoord
	mov dh, G1YCoord
	call Gotoxy			; move cursor to G1's x and y coordinate

	mov eax, 248		; Ghost eyes are degree symbols	
	call WriteChar		; Most living things have 2 eyes
	call WriteChar		; Although the ghosts are ghosts, so technically they're no longer living

	mov eax, 0Fh		; reset text color
	call SetTextColor

	ret

ShowG1 ENDP

;:: UNSHOWG1 ::
; Works similarly to UnShowPac
; prints what was already there in the map at the x and y coordinates G1XCoord and G1YCoord, respectively

UnShowG1 PROC

	mov dl, G1XCoord
	mov dh, G1YCoord
	call Gotoxy			; move cursor to desired X and Y coordinate

	mov esi, OFFSET theMap
	movzx eax, G1YCoord
	movzx ebx, G1XCoord
	call CheckPos		; returns the character at the x position in eax and the y position in ebx in al
	call DrawWhatYouSee	; draws the character we got from calling the call above at G1XCoord and G1YCoord
	inc esi
	mov al, [esi]
	call DrawWhatYouSee	; do it again, because a ghost is 2 characters wide

	ret

UnShowG1 ENDP

; move G1 up one space

;:: MOVEG1UP ::
; Works exactly the same as MovePacUp, but instead calling G1's Show and UnShow procedures

MoveG1Up PROC uses edx

	movzx eax, G1YCoord
	movzx ebx, G1XCoord
	call CheckAbove			; move the character above G1 into eax

	call CanIGoHere			; Can G1 go up there?
	cmp ebx, 1
	je ENDG1UP				; If they can't, do nothing and return 1 in ebx

	CARRYG1UP:				; if they can though,
		call UnShowG1		; un-show G1
		dec G1YCoord		; move up 1 Y-coordinate

		call ShowG1			; show G1 in their brand new place

	ENDG1UP:
		ret

MoveG1Up ENDP

;:: MOVEG1DOWN ::
; see MoveG1Up

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

;:: MOVEG1DLEFT ::
; see MoveG1Up

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

;:: MOVEG1RIGHT ::
; see MoveG1Up

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

;:: G1THINK ::
;

G1Think PROC

	mov edi, OFFSET G1Options
	mov G1NumOpts, 0

	G1TRYUP:
		cmp G1MoveCache, OFFSET MoveG1Down	; if G1 is already moving down
		je G1TRYDOWN						; skip trying to move up, ghosts can't go backwards
											; otherwise,
		movzx eax, G1YCoord	
		movzx ebx, G1XCoord
		call CheckAbove						; move the character above G1 into al
		call CanIGoHere						; if the character above G1 isn't traversible
		cmp ebx, 1
		je G1TRYDOWN						; skip trying to move up, it's not possible.
											; otherwise,
		mov [edi], OFFSET MoveG1Up			; Add MoveG1Up's address to the G1Options array
		add edi, 4							; step forward one index of the G1Options array
		inc G1NumOpts						; increment the number of options G1 has to traverse

	G1TRYDOWN:
		cmp G1MoveCache, OFFSET MoveG1Up	; if G1 is already moving up
		je G1TRYLEFT						; skip trying to move down, ghosts can't go backwards

		movzx eax, G1YCoord					; everything else under this label is the same as G1TRYUP, but instead G1 is trying to go down
		movzx ebx, G1XCoord
		call CheckBelow
		call CanIGoHere
		cmp ebx, 1
		je G1TRYLEFT

		mov [edi], OFFSET MoveG1Down
		add edi, 4
		inc G1NumOpts

	G1TRYLEFT:
		cmp G1MoveCache, OFFSET MoveG1Right	; if G1 is already moving right
		je G1TRYRIGHT						; skip trying to move left, ghosts can't go backwards

		movzx eax, G1YCoord					; everything else under this label is the same as G1TRYUP, but instead G1 is trying to go left
		movzx ebx, G1XCoord
		call CheckLeft
		call CanIGoHere
		cmp ebx, 1
		je G1TRYRIGHT

		mov [edi], OFFSET MoveG1Left
		add edi, 4
		inc G1NumOpts

	G1TRYRIGHT:
		cmp G1MoveCache, OFFSET MoveG1Left	; if G1 is already movine left
		je G1PREDECISION					; skip trying to move right, ghosts can't go backwards

		movzx eax, G1YCoord					; everything else under this label is the same as G1TRYUP, but instead G1 is trying to go right
		movzx ebx, G1XCoord
		call CheckRight
		call CanIGoHere
		cmp ebx, 1
		je G1PREDECISION

		mov [edi], OFFSET MoveG1Right
		add edi, 4
		inc G1NumOpts

	G1PREDECISION:
		cmp G1NumOpts, 0					; if nothing is trversible
		jne G1DECIDE

		inc G1NumOpts
		mov eax, G1MoveCache				; move the move stored in the move cache into the list of options
		mov G1options, eax

	G1DECIDE:
		movzx eax, G1NumOpts				; move the number of options G1 has to travel into eax
		call RandomRange					; generate a random number between 0 and eax-1
		mov bl, 4
		mul bl								; multiply that number by 4
		mov esi, OFFSET G1Options
		add esi, eax						; add that number to the address of the first element of G1Options			
		mov eax, [esi]						; mov the value stored inside the address stored in esi into eax
		mov G1MoveInst, eax					; move that address into G1MoveInst

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
		mov G1XCoord, 54		; move G1 to exit the right tube
		mov G1YCoord, 14
		call ShowG1
		jmp G1ENDCHARCHECK

	G1TRAVERSERIGHTTUBE:
		mov fixRightTube, 0FFh
		mov fixLeftTube, 0ffh
		mov G1XCoord, 0			; move G1 to exit the left tube
		mov G1YCoord, 14
		call ShowG1
		jmp G1ENDCHARCHECK

	G1ENDCHARCHECK:
		ret

G1Think ENDP

; ********************************************************************************************************************************************************************************************************
; G2 MOVEMENT PROCEDURES
; All the rest of the G2, G3, and G4 procedures are literally exactly the same as the G1 procedures, only with every G1 replaced with a G2, G3, or G4.
; The only differences are in color, and the summon procedure, which will be commented for G2.

ShowG2 PROC

	mov eax, white+(13*16)	; G2 has white eyes with a light magenta background
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

; move G2 up one space

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

;:: SUMMONG2 ::
; moves G2 out of the ghost pen and to x position 26, and y position 11

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

	mov eax, white+(11*16)	; G3 has white eyes with a light cyan background
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

; move G3 up one space

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

	mov eax, white+(10*16)	; G4 has white eyes and a light breen background
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

; move G4 up one space

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

;:: SHOWCHERRY ::
; shows the cherry (a red percent sign) at position (28, 17)

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

;:: SHOWREADY ::
; Shows "R E A D Y" in red right under the ghost pen

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

;:: UNSHOWREADY ::
; Prints 9 spaces under the ghost pen where "R E A D Y" would be

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

;:: CHECKABOVE ::
; returns the character above coordinate (x, y) in the map in eax
; eax = y coordinate
; ebx = x coordinate

CheckAbove PROC uses esi

	dec eax
	call CheckPos

	ret

CheckAbove ENDP

;:: CHECKBELOW ::
; returns the character below coordinate (x, y) in the map in eax
; eax = y coordinate
; ebx = x coordinate

CheckBelow PROC

	inc eax
	call CheckPos

	ret

CheckBelow ENDP

;:: CHECKLEFT ::
; returns the character to the left of coordinate (x, y) in the map in eax
; eax = y coordinate
; ebx = x coordinate

CheckLeft PROC

	sub ebx, 2
	call CheckPos

	ret

CheckLeft ENDP

;:: CHECKRIGHT ::
; returns the character to the right of coordinate (x, y) in the map in eax
; eax = y coordinate
; ebx = x coordinate

CheckRight PROC

	add ebx, 2
	call CheckPos

	ret

CheckRight ENDP

;:: CHECKPOS ::
; returns the character at coordinate (x, y) in the map in eax
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

;:: CANIGOHERE ::
; eax = character to check
; checks to see if the character in eax is a character that can be moved across

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

;:: FIXLEFTTUBEPLS ::
; Clears any left over pacmen or ghosts left over from going through the left tube

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

;:: FIXRIGHTTUBEPLS ::
; Clears any left over pacmen or ghosts left over from going through the right tube

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

;:: NEXTLEVEL ::
; this procedure is called when pacman eats all 244 dots in a level

NextLevel PROC

	inc level					; increment level
	mov esi, OFFSET mapTemp
	mov edi, OFFSET theMap
	mov ecx, mapSize
	mov edx, 0
	call Gotoxy
	RESETMAP:					; reset all the dots in the map
		mov al, [esi]
		mov [edi], al
		inc esi
		inc edi
		loop RESETMAP

	cmp wallColor, 13			; if the walls are light magenta,
	jne DONTLOOPWALLCOLORBACK
	mov wallColor, 8			; manually set them back to blue

	DONTLOOPWALLCOLORBACK:
		inc wallColor			; otherwise just increment wallColor

	call clrscr					; clear the screen
	call DrawMap				; re-draw the map
	mov dotsEaten, 0			; reset dotsEaten to zero
	call SetupGame				; reset everybody;s coordinates

	ret

NextLevel ENDP

;:: CONTROLLOOP ::
; this is the main procedure that drives game progression

ControlLoop PROC uses eax

	mov edx, 0141h
	call Gotoxy
	mov eax, score
	call WriteDec			; show the score in the top right corner of the screen

	cmp gameClock, 150		; if the gameClock is at 150, show the cherry where it should be
	jne DONTSHOWCHERRY
	call ShowCherry

	DONTSHOWCHERRY:

	cmp fixLeftTube, 0FFh	; if the left tube needs to be fixed, fix it
	jne DONTFIXLEFT
	call FixLeftTubePls
	DONTFIXLEFT:

	cmp fixRightTube, 0FFh	; if the right ntube needs to be fixed, fix it
	jne DONTFIXRIGHT
	call FixRightTubePls
	DONTFIXRIGHT:

	call ReadKey		; read from keyboard input buffer

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
		mov moveInst, OFFSET MovePacLeft	; put MovePacLeft's address into MoveInst
		jmp TRYMOVE

	MOVEUP:
		mov moveInst, OFFSET MovePacUp		; put MovePacUp's address into MoveInst
		jmp TRYMOVE

	MOVERIGHT:
		mov moveInst, OFFSET MovePacRight	; put MovePacRight's addres into MoveInst
		jmp TRYMOVE

	MOVEDOWN:
		mov moveInst, OFFSET MovePacDown	; put MovePacDown's address into MoveInst
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

	call IsPacKill	; Check to see if Pacman is dead

	call G1Think	; make all of the ghosts think once
	call G2Think
	call G3Think
	call G4Think

	cmp gameClock, 50	; if gameClock = 50, summon G2
	jne DONTSUMMONG2
	call SummonG2

	DONTSUMMONG2:

	cmp gameClock, 100	; if gameClock = 100, summon G3
	jne DONTSUMMONG3
	call SummonG3

	DONTSUMMONG3:

	cmp gameClock, 150	; if gameClock = 150, summon G4
	jne DONTSUMMONG4
	call SummonG4

	DONTSUMMONG4:

	movzx eax, pacYCoord
	movzx ebx, pacXCoord
	call CheckPos		; it's time to do some scoring
	mov edx, " "

	cmp al, "."			; if pacman is on top of a dot
	je SCOREDOT

	cmp al, "~"			; if pacman is on top of a power pellet
	je SCOREBIGDOT

	cmp al, "%"			; if pacman is on top of a cherry
	je SCORECHERRY

	cmp al, ">"			; if pacman is at the end of the right tube
	je TRAVERSERIGHTTUBE

	cmp al, "<"			; if pacman is at thr rnd of the left tube
	je TRAVERSELEFTTUBE

	jmp ENDCHARCHECK

	SCOREDOT :				; DOT SCORING
		add score, 10		; add 10 to score
		inc dotsEaten		; increment dots eaten
		mov [esi], dl		; put a space where the dot was in theMap
		cmp shouldWaka, 1	; if ShouldWaka is 1
		je doTheWaka		; waka
		inc shouldWaka		; increment shouldWaka
		jmp ENDCHARCHECK

	doTheWaka :
		invoke sndPlaySound, offset wakaSound, 0001	; play a waka
		dec shouldWaka
		jmp ENDCHARCHECK
 
	SCOREBIGDOT :
		add score, 50		; add 50 to score
		inc dotsEaten		; increment dots eaten
		mov [esi], dl		; put a space where the power pellet was in theMap
		mov shouldWaka, -2	; don't waka
		invoke sndPlaySound, offset bigDotSound, 0001	; play power pellet sound
		jmp ENDCHARCHECK
 
	SCORECHERRY :
		add score, 100		; add 100 to score
		mov [esi], dl		; put a space where the cherry was in theMap
		mov shouldWaka, 1	; don't waka
		invoke sndPlaySound, offset cherrySound, 0001	; play cherry sound
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

	call IsPacKill		; check to see if pacman is dead

	cmp dotsEaten, 244	; if pacman atw 244 pellets
	jne KEEPEATING
	mov eax, 1000
	call Delay			; pause for emphasis
	call NextLevel		; start the next level

	KEEPEATING:

	inc gameClock		; increment the game clock with every iteration of ControlLoop
	ret

ControlLoop ENDP

;:: GAMEOVER ::
; displays game over splash screen

GameOver PROC

	call ClrScr
	mov ecx, endSize
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