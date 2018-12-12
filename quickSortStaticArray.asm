myss SEGMENT PARA STACK 'MYSS'
	DW 180 DUP(?)
myss ENDS

myds SEGMENT PARA 'MYDS'
DIZI Db 51, 0, 48, 100
LEN DW  4
myds ENDS


mycs SEGMENT PARA 'MYCS'
	ASSUME CS:mycs, DS:myds, SS:myss  
;print a string
PUT_STR PROC NEAR
    PUSH BX
    MOV BX, AX
    MOV AL, BYTE PTR[BX]
PUT_LOOP:  CMP AL, 0
           JE PUT_FIN
           CALL PUTC
           INC BX
           MOV AL, BYTE PTR[BX]
           JMP PUT_LOOP
    
PUT_FIN:
    POP BX
    RET    
PUT_STR ENDP
;print a character
PUTC PROC NEAR
    PUSH AX
    PUSH DX 
    
    MOV DL, AL
    MOV AH, 2
    INT 21H
    
    POP DX
    POP AX    
    RET
PUTC ENDP

;print the array
PRINT_ARRAY PROC NEAR   ;CX<-n is passed as a number of element size
        XOR  SI, SI     ;SI is index
    LOOP_PRINT_ARRAY:   CMP SI, CX      ;cmp (i<n)      
                        JAE FIN_PRINT_E ;if i>n
                        mov al, ' '
                        call putc
                        xor ax, ax 
                        MOV Al, DIZI[SI]        
                        CALL PRINT_E
                        INC SI
                        JMP LOOP_PRINT_ARRAY
    FIN_PRINT_E:
    RET
PRINT_ARRAY ENDP    

;print elements of the array
PRINT_E PROC NEAR
        PUSH CX
        PUSH DX
        XOR DX, DX
        PUSH DX     ;stackten cekerken kullanican, 0 gelene kadar
                                                                 
        MOV CX, 10  ;10'a bolcen sonra
        CMP AL, 0
        JGE CALC_DIGITS_P
        NEG AL
        PUSH AX
        MOV AL, '-'   ;- ekrana yazdir
        CALL PUTC
        POP AX  ;AX'i geri al
    CALC_DIGITS_P:  DIV CX  ;DX:AX<-AX/10   AX=bolen    DX=kalan
                    ADD DX, '0' ;kalan degerini ASCII olarak bul
                    PUSH DX 
                    XOR DX, DX
                    CMP AX, 0
                    JNE CALC_DIGITS_P
    DISP_LOOP:  POP AX
                CMP AX, 0
                JE END_DISP_LOOP
                CALL PUTC
                JMP DISP_LOOP
    END_DISP_LOOP:  POP DX
                    POP CX                                 
  RET
PRINT_E ENDP	

QS PROC NEAR
			; AX START, BX END
			PUSH AX
			PUSH BX
			;LEA SI,DIZI
			MOV SI,AX ; J
			MOV DI,BX ; LAST ELEMENT 
			
			XCHG AX,BX
			SUB AX,BX
			;MOV CX,2
			;XOR DX,DX
			;DIV CX
			MOV CX,AX ; # OF LOOPS

			MOV BX,SI ; I

	LS:		MOV Al,byte ptr[DI]
			CMP Al,byte ptr[SI]
			JNg LELSE
				MOV Al,byte ptr[SI]
				XCHG Al,byte ptr[BX]
				MOV byte ptr[SI],Al
				ADD BX,1
	LELSE:	
			ADD SI,1
			LOOP LS
			MOV Al,byte ptr[DI]
			XCHG Al,byte ptr[BX] ;BX is the pivot
			MOV byte ptr[DI],Al 
			MOV Dl,Bl ; RETURN DX
			POP BX
			POP AX
			RET
QS ENDP

SORT PROC NEAR
			; AX START, BX END
			PUSH DX
			PUSH AX
			PUSH BX
			
			PUSH BX
			SUB BX,AX
			CMP BX,2
			POP BX

			JL LEND
				CALL QS
				;FIRST CALL
				PUSH BX
				MOV Bl,Dl
				SUB BX,1
				CALL SORT
				;SECOND CALL
				POP BX
				MOV Al,Dl
				ADD AX,1
				CALL SORT		
	LEND:	
			POP BX
			POP AX
			POP DX
		RET
SORT ENDP

MAIN PROC FAR
			PUSH DS
			XOR AX,AX
			PUSH AX
			MOV AX,myds
			MOV DS,AX
			
			;CODE STARTS
			LEA AX,DIZI
			MOV BX,LEN 
			CALL SORT
			mov al, '*'
			call putc
			mov cx, len
			CALL PRINT_ARRAY
			RETF
MAIN ENDP

mycs ENDS

END MAIN


;*******************print*************  



 












mycs ENDS

END MAIN