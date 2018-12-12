myss    SEGMENT PARA 'STACK'
    DW 32 DUP(?)
myss ENDS
myds    SEGMENT PARA 'DATA'  
    CR EQU 13   
    n DB ?
    enter_n DB 'Please enter a value of n : ', 0
    negative_n DB 'n can not be negative ', 0 
    not_integer DB 'you entered not an intger ', 0 
    hata_out_of_range DB 'the number is out of range', 0  
    read_value DB 'enter element : ', 0
    array DB 100 DUP(?) 
      
myds    ENDS     
mycs    SEGMENT PARA 'CODE'
    ASSUME SS:myss, DS:myds, CS:mycs

main    PROC FAR
    PUSH DS
    XOR AX, AX
    PUSH AX
    MOV AX, myds
    MOV DS, AX
    
    MOV AX, OFFSET enter_n
    CALL PUT_STR 
    CALL READ_N ;value is returned in AX
    MOV AL, n  
    MOV CX, ax  ;loop size
    CALL READ_ARRAY 
    ;assign loop size
    XOR CX, CX
    MOV CL, n
    CALL PRINT_ARRAY
    ;CODE STARTS
	LEA AX,array
	xor bx, bx
	MOV bx, 5 
	CALL SORT 
     ;assign loop size
     mov al, '*'
	call putc
    XOR CX, CX
    MOV CL, n
    CALL PRINT_ARRAY
    ;CALL PRINT_ARRAY
    RETF
main ENDP

;******************QUICK SORT*****************
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

;here we take a value for n i.e array element size:
READ_N PROC NEAR
        PUSH BX
        PUSH CX
    GETN_START: XOR BX, BX
                XOR CX, CX
    NEW:    CALL GETC                
            CMP AL, CR
            JE FIN_READ_N
            CMP AL, '-'
            JNE CTRL_NUM
            
    ERROR_NEG:  MOV AX, OFFSET negative_n
                CALL PUT_STR
                JMP GETN_START  
                
    CTRL_NUM:   CMP AL, '0'                                 
                JB ERROR_OUT
                CMP AL, '9'
                JA ERROR_OUT
                SUB AL, '0'
                MOV BL, AL
                MOV AX, 10
                MUL CX
                MOV CX, AX
                ADD CX, BX
                JMP NEW
    ERROR_OUT:  MOV AX, OFFSET not_integer
                CALL PUT_STR
                JMP GETN_START
    FIN_READ_N:   MOV AX, CX
                POP CX
                POP BX
    RET                                             
READ_N ENDP    

;get a character from keyboard
GETC PROC NEAR
    MOV AH, 1h
    INT 21h
    RET
GETC ENDP    

;read array elements array[n]
READ_ARRAY PROC NEAR    ;loop size is passed from main procedure as CX<-n
    XOR SI, SI  ;SI is index for array
LOOP_READ_ARRAY:    CMP SI, CX  ;loop until SI==CX
                    JAE FIN_READ_A 
                    ;write to user to enter value and index
                    mov ax, offset read_value
                    call put_str
                    mov ax, si 
                    add al, '0'
                    mov dl, al
                    mov ah, 2
                    int 21h 
                    
                    CALL GETN_E
                    MOV array[SI], AL
                    INC SI
                    JMP LOOP_READ_ARRAY                   
FIN_READ_A:
            RET                              
READ_ARRAY ENDP 

;read elements of an array
GETN_E PROC NEAR
        PUSH BX
        PUSH CX
        PUSH DX
    GETN_START_E:   MOV DX, 1   ;initially assume a number as a positive numbver
                    XOR BX, BX
                    XOR CX, CX
                    
    NEW_E:      CALL GETC   ;take a character from a keyboard
                CMP AL, CR
                JE  FIN_READ_E
                CMP AL, '-'
                JNE CTRL_NUM_E
    NEGATIVE:   MOV DX, -1
                JMP NEW_E
    CTRL_NUM_E: CMP AL, '0'
                JB ERROR_NOT_INTEGER    ;sayi girmedin
                CMP AL, '9'
                JA ERROR_NOT_INTEGER
                SUB AL, '0'
                MOV BL, AL  ;okunan sayiyi BL'ye koy
                MOV AX, 10  ;onceki okunan sayilari *10 yapmak icin
                PUSH DX     ;isaretini saklamak icin
                MUL CX      ;DX:AX<-CX*10
                POP DX      ;isaret bilgisini geri al
                MOV CX, AX  ;CX<-CX*10
                ADD CX, BX  ;okunan haneyi ara deger ekle
                JMP NEW_E
    ERROR_NOT_INTEGER: MOV AX, OFFSET not_integer
               CALL PUT_STR
               JMP GETN_START_E
    ERROR_OUT_OF_RANGE: MOV AX, OFFSET hata_out_of_range
                        CALL PUT_STR
                        JMP GETN_START_E                               
    FIN_READ_E: MOV AX, CX
                CMP DX, 1
                JE POSITIVE_E
                neg al
                CMP AL, -128 
                ;neg al
                JGE FIN_GETN_E
                CALL ERROR_OUT_OF_RANGE
    POSITIVE_E: CMP AX, 127
                JBE FIN_GETN_E
                CALL ERROR_OUT_OF_RANGE
    FIN_GETN_E: POP DX
                POP CX
                POP BX

    RET
GETN_E ENDP 

;print the array
PRINT_ARRAY PROC NEAR   ;CX<-n is passed as a number of element size
        XOR  SI, SI     ;SI is index
    LOOP_PRINT_ARRAY:   CMP SI, CX      ;cmp (i<n)      
                        JAE FIN_PRINT_E ;if i>n
                        mov al, ' '
                        call putc
                        xor ax, ax 
                        MOV AL, array[SI]        
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



mycs ENDS
    END main