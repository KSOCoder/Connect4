; addons.asm - implements read_int and print_newline

.386
.MODEL FLAT, C
.STACK 4096

EXTERN   scanf : PROC
EXTERN   printf : PROC

;==============================================================
.data
	FMT_INT     DB "%d",0
	FMT_NEWLINE DB 10,0

; ==============================================================
.data?
	INT_BUF     DD ?

; ==============================================================
.code
ASSUME CS:FLAT,DS:FLAT,SS:FLAT,ES:FLAT,FS:FLAT,GS:FLAT
