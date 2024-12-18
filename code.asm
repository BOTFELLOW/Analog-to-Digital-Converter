CODE    SEGMENT PARA 'CODE'
        ASSUME CS:CODE, DS:DATA, SS:STAK
STAK    SEGMENT PARA STACK 'STACK'
        DW 20 DUP(?)
STAK    ENDS
 
DATA    SEGMENT PARA 'DATA'
ATIMER 	DW 0800H
DTIMER  DW 0806H
DAC   	DW 0600H
AADC   	DW 0200H
IADC   	DW 0400H
A8255 	DW 0000H
B8255 	DW 0002H
C8255 	DW 0004H
D8255 	DW 0006H

Filtered DB 150 DUP(?)
SAMPLING DB 150 DUP(?)
DATA    ENDS

START PROC
        MOV AX, DATA
	MOV DS, AX
	 
	MOV AL,90H	
	MOV DX,D8255
	OUT DX,AL
	
	MOV AL, 00110101B 
	MOV DX,DTIMER 
	OUT DX, AL
	
	XOR AL,AL
	MOV DX,ATIMER
	OUT DX,AL
	
	MOV AL, 01H
	MOV DX,ATIMER
	OUT DX, AL
	XOR BX,BX
	
	XOR SI,SI
	MOV CX,96H   ; =150D*0.2 =3 SEC
OKU:
T1:	MOV DX,A8255
	IN AL,DX
	TEST AL,01H
	JNZ T1
	
T2:	IN AL,DX ;wait for 1
	TEST AL,01H
	JE T2
	 
	MOV DX,AADC
	MOV AL,00H
	OUT DX, AL
	
	MOV DX, IADC
	 
	CHECK_INTR:
	IN AL, DX
	TEST AL, 10H		; chck adc int
	JNZ CHECK_INTR
	 
	MOV DX,AADC
	IN AL, DX
	CALL DELAY
	 
	MOV SAMPLING[SI],AL
	INC SI
	 
	LOOP OKU ; OKUDUK
	
		
	MOV SI,1
	MOV CX,96H   ; =150D*0.2 =3 SEC
	MOV SAMPLING[0],00H
	
	
FILTERING:
	MOV AL,SAMPLING[SI]
	DEC SI
	SUB AL,SAMPLING[SI]
	ADD AL,filtered[SI] 
	INC SI
	
	PUSH CX
	MOV CL,5 ; 2^5 = 32 
	SAR AL,CL
	POP CX 
	
	MOV Filtered[SI],AL 
	INC SI
	LOOP FILTERING

	MOV DX,DAC 
ENDLESS:
	 XOR SI,SI
	 MOV CX,96H
PRINT:
T3:	 MOV DX,A8255 
	 IN AL,DX
       	 TEST AL,01H
 	 JNZ T3
	
T4:	 IN AL,DX    
	 TEST AL,01H
	 JZ T4
	 
	 MOV DX,DAC
	 MOV AL,Filtered[SI]
	 OUT DX,AL
	 CALL DELAY
	 INC SI 
	 LOOP PRINT
         JMP ENDLESS
	 RET
	
START ENDP

 
 
DELAY PROC NEAR
PUSH CX
MOV CX, 00FFH
L1:
LOOP L1
POP CX
RET
DELAY ENDP	

CODE    ENDS
        END START
