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

read_int PROC PUBLIC
	PUSH        OFFSET INT_BUF
	PUSH        OFFSET FMT_INT
	CALL        scanf
	ADD         ESP, 8

	CMP         EAX, 1
	JE          ri_ok
	MOV         DWORD PTR [INT_BUF],0
	MOV         EAX,[INT_BUF]
	RET
read_int ENDP

print_newline PROC PUBLIC
	PUSH        OFFSET FMT_NEWLINE
	CALL        printf
	ADD         ESP,4
	RET
print_newline ENDP

END