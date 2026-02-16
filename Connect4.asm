; Connect4.asm - traditional game to get 4 in a row before your
; opponent

.data
; Board initialization; 42 bytes
	COLS     EQU 7
	ROWS     EQU 6
	BOARD    RESB (ROWS * COLS)
	MSG_CELL_E  DB  " . ",0
	MSG_CELL_1  DB  " X ",0
	MSG_CELL_2  DB  " O ",0
	COL_NUMS    DB  " 1 2 3 4 5 6 7",0