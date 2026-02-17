; Connect4.asm - traditional game to get 4 in a row before your
; opponent

.386
.MODEL FLAT,C
.STACK 4096

COLS     EQU 7
ROWS     EQU 6
	EXTERN   printf:PROC
	EXTERN   puts:PROC
	EXTERN   putchar:PROC
	EXTERN   ExitProcess:PROC
	EXTERN   read_int:PROC
	EXTERN   print_newline:PROC

.data
; Board initialization; 42 bytes
	MSG_TURN    DB  "Player %d's turn - choose column (1-7): ", 0
	MSG_FULL    DB  "Column full! Choose again.", 0
	MSG_WIN     DB  "Player %d WINS!", 0
	MSG_DRAW    DB  "DRAW!", 0
	MSG_BORDER  DB  "+---+---+---+---+---+---+---+", 0
	MSG_CELL_E  DB  " . ", 0
	MSG_CELL_1  DB  " X ", 0
	MSG_CELL_2  DB  " O ", 0
	COL_NUMS    DB  " 1  2  3  4  5  6  7", 0

.data?
	BOARD       DB (ROWS* COLS) DUP(?)
	INPUT_COL   DB 4 DUP(?)
	MOVE_COUNT  DD ?
; ===================================================================
.code
	ASSUME CS:FLAT,DS:FLAT,SS:FLAT,ES:FLAT,FS:NOTHING,GS:NOTHING
_start PROC
	CALL     init_board
	MOV      DWORD PTR [MOVE_COUNT],0
	MOV      EDI,1

game_loop:
	CALL     print_board
	PUSH     EDI
	PUSH     OFFSET MSG_TURN
	CALL     printf
	ADD      ESP,8

get_column:
	CALL     read_int
	DEC      EAX
	MOV      ECX,EAX

	CMP      ECX,0
	JL       invalid_move
	CMP      ECX,COLS
	JGE      invalid_move

	CALL     drop_piece

	CMP      EAX,-1
	JE       invalid_move

	MOV      EDX,EAX
	CALL     check_win

	CMP      EAX,1
	JE       player_wins

	INC      DWORD PTR [MOVE_COUNT]
	MOV      EBX,[MOVE_COUNT]
	CMP      EBX,(ROWS*COLS)
	JE       game_draw

	XOR      EDI,3

	JMP      game_loop

invalid_move:
	PUSH     OFFSET MSG_FULL
	CALL     puts
	ADD      ESP,4
	JMP      get_column

player_wins:
	CALL     print_board
	PUSH     EDI
	PUSH     OFFSET MSG_WIN
	CALL     printf
	ADD      ESP,8
	JMP      exit_game

game_draw:
	CALL     print_board
	PUSH     OFFSET MSG_DRAW
	CALL     puts
	ADD      ESP,4

exit_game :
	PUSH     0
	CALL     ExitProcess
_start ENDP

; ===================================================================
init_board PROC
	CLD
	MOV      EDI, OFFSET BOARD
	MOV      ECX, (ROWS* COLS)
	XOR      EAX, EAX
	REP      STOSB
	RET
init_board ENDP
; ===================================================================
print_board PROC
	PUSH     OFFSET COL_NUMS
	CALL     puts
	ADD      ESP,4
	MOV      EDX,0
print_row_loop:
	CMP      EDX,ROWS
	JGE      print_board_done

	PUSH     OFFSET MSG_BORDER
	CALL     puts
	ADD      ESP,4

	MOV      ECX,0
print_cell_loop:
	CMP      ECX,COLS
	JGE      print_row_end

	MOV      EAX,EDX
	IMUL     EAX,COLS
	ADD      EAX,ECX
	MOVZX    EBX,BYTE PTR [BOARD + EAX]

	PUSH     '|'
	CALL     putchar
	ADD      ESP,4

	CMP      EBX,1
	JE       cell_is_1
	CMP      EBX,2
	JE       cell_is_2
	PUSH     OFFSET MSG_CELL_E
	JMP      print_char
cell_is_1:
	PUSH     OFFSET MSG_CELL_1
	JMP      print_char
cell_is_2 :
	PUSH     OFFSET MSG_CELL_2
	JMP      print_char
print_char :
	CALL     printf
	ADD      ESP, 4

	INC      ECX
	JMP      print_cell_loop
print_row_end:
	PUSH     '|'
	CALL     putchar
	ADD      ESP,4
	CALL     print_newline

	INC      EDX
	JMP      print_row_loop
print_board_done:
	PUSH     OFFSET MSG_BORDER
	CALL     puts
	ADD      ESP,4
	RET
print_board ENDP
; ===================================================================
drop_piece PROC
	MOV    EDX,(ROWS-1)

find_empty_row:
	CMP      EDX,-1
	JL       column_is_full

	MOV      EAX,EDX
	IMUL     EAX,COLS
	ADD      EAX,ECX
	MOVZX    EBX,BYTE PTR [BOARD + EAX]
	CMP      EBX,0
	JNE      move_up
	
place_token:
	MOV      EBX,EDI
	AND      EBX,0FFh
	MOV      BYTE PTR [BOARD + EAX],DIL
	MOV      EAX,EDX
	RET

move_up:
	DEC      EDX
	JMP      find_empty_row

column_is_full:
	MOV      EAX,-1
	RET
drop_piece ENDP
; ===================================================================
check_win PROC
; direction vectors(dRow,dCol):
	; Horizontal(0,1)
	; Vertical(1,0)
	; DIAGONAL / (-1,1)
	; DIAGONAL \ (1,1)

; Horizontal
	MOV      EBX,1

	PUSH     0
	PUSH     1
	CALL     count_direction
	ADD      EBX,EAX

	PUSH     0
	PUSH     -1
	CALL     count_direction
	ADD      EBX,EAX

	CMP      EBX,4
	JGE      win_found

; Vertical
	MOV      EBX,1

	PUSH     1
	PUSH     0
	CALL     count_direction
	ADD      EBX,EAX

	PUSH     -1
	PUSH     0
	CALL     count_direction
	ADD      EBX,EAX

	CMP      EBX,4
	JGE      win_found

; Diagonal /
	MOV      EBX,1

	PUSH     -1
	PUSH     1
	CALL     count_direction
	ADD      EBX,EAX

	PUSH     1
	PUSH     -1
	CALL     count_direction
	ADD      EBX,EAX

	CMP      EBX,4
	JGE      win_found

; Diagonal \
	MOV      EBX,1

	PUSH     1
	PUSH     1
	CALL     count_direction
	ADD      EBX,EAX

	PUSH     -1
	PUSH     -1
	CALL     count_direction
	ADD      EBX,EAX

	CMP      EBX,4
	JGE      win_found

	MOV      EAX,0
	RET

win_found:
	MOV      EAX,1
	RET
check_win ENDP
; ===================================================================
count_direction PROC
	PUSH     EBP
	MOV      EBP,ESP
	SUB      ESP,8
	PUSH     ESI
	PUSH     EBX
	PUSH     ECX

	MOV      ESI,EDX
	MOV      EBX,ECX

	MOV      EAX,[EBP+12]
	MOV      [EBP-4],EAX
	MOV      EAX,[EBP+8]
	MOV      [EBP-8],EAX
	MOV      EAX,0
count_loop:
	ADD      ESI,[EBP-4]
	ADD      EBX,[EBP-8]

	CMP      ESI,0
	JL       count_broke
	CMP      ESI,ROWS
	JGE      count_broke
	CMP      EBX,0
	JL       count_broke
	CMP      EBX,COLS
	JGE      count_broke

	PUSH     EAX
	MOV      EAX,ESI
	IMUL     EAX,COLS
	ADD      EAX,EBX
	MOVZX    EAX,BYTE PTR [BOARD + EAX]
	POP      EAX

	CMP      ECX,EDI
	JNE      count_broke

	INC      EAX
	CMP      EAX,3
	JL       count_loop

count_broke:
	LEA      ESP,[EBP-20]
	POP      ECX
	POP      EBX
	POP      ESI
	MOV      ESP,EBP
	POP      EBP
	RET      8
count_direction ENDP
END _start