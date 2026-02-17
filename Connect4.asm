; Connect4.asm - traditional game to get 4 in a row before your
; opponent

.data
; Board initialization; 42 bytes
	COLS     EQU 7
	ROWS     EQU 6
	BOARD    RESB(ROWS * COLS)
	MSG_TURN    DB  "Player %d's turn - choose column (1-7): ",0
	MSG_FULL    DB  "Column full! Choose again.",0
	MSG_WIN     DB  "Player %d WINS!",0
	MSG_DRAW    DB  "DRAW!",0
	MSG_BORDER  DB  "+---+---+---+---+---+---+---+",0
	MSG_CELL_E  DB  " . ", 0
	MSG_CELL_1  DB  " X ", 0
	MSG_CELL_2  DB  " O ", 0
	COL_NUMS    DB  " 1  2  3  4  5  6  7", 0

	INPUT_COL   RESB 4
	MOVE_COUNT  RESD 1
;
================================================================== =
;
_start:
	CALL     init_board
	MOV      [MOVE_COUNT],DWORD 0
	MOV      EDI,1

game_loop:
	CALL     print_board
	PUSH     EDI
	PUSH     OFFSET MSG_TURN
	CALL     printf
	ADD      ESP,8

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

exit_game:
	MOV      EAX,1
	XOR      EBX,EBX
	INT      0x80
;
===================================================================
;
init_board:
	MOV      EDI, OFFSET BOARD
	MOV      ECX, (ROWS* COLS)
	XOR      EAX, EAX
	REP      STOSB
	RET
;
===================================================================
;
print_board:
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
	MOVZX    EBX,BYTE [BOARD + EAX]

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
;
===================================================================
;
drop_piece:
	MOV      EDX,(ROWS-1)

find_empty_row:
	CMP      EDX,-1
	JL       column_is_full

	MOV      EAX,EDX
	IMUL     EAX,COLS
	ADD      EAX,ECX
	MOVZX    EBX,BYTE [BOARD + EAX]
	
place_token:
	MOV      BYTE [BOARD + EAX],DIL
	MOV      EAX,EDX
	RET

column_is_full:
	MOV      EAX,-1
	RET
;
===================================================================
;
check_win:
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

	CMP      EBX,4
	JGE      win_found

; Vertical
	MOV      EBX,1

	PUSH     1
	PUSH     0
	CALL     count_direction
	ADD      EBX,EAX

	PUSH     - 1
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

;
===================================================================
;
count_direction:
	PUSH     EBP
	MOV      EBP,ESP
	PUSH     ESI
	PUSH     EBX

	MOV      EAX,0
	MOV      ESI,EDX
	MOV      EBX,ECX

	MOV      DWORD [EBP-4],0
	MOV      DWORD [EBP-8],0
	MOV      EAX,[EBP+8]
	MOV      [EBP-4],EAX
	MOV      EAX,[EBP+4]
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
	MOVZX    EAX,BYTE [BOARD + EAX]
	MOV      ECX,EAX
	POP      EAX

	CMP      ECX,EDI
	JNE      count_broke

	INC      EAX
	CMP      EAX,3
	JL       count_broke

count_broke:
	POP      EBX
	POP      ESI
	POP      EBP
	RET      8