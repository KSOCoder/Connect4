; Connect4.asm - traditional game to get 4 in a row before your
; opponent

.data
; Board initialization; 42 bytes
	COLS     EQU 7
	ROWS     EQU 6
	BOARD    RESB(ROWS * COLS)
	MSG_BORDER  DB  "+---+---+---+---+---+---+---+",0
	MSG_CELL_E  DB  " . ", 0
	MSG_CELL_1  DB  " X ", 0
	MSG_CELL_2  DB  " O ", 0
	COL_NUMS    DB  " 1 2 3 4 5 6 7", 0

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
================================================================== =
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

