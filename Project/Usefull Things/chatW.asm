.model small
.stack 64
.data
c1 db 0
r1 db 0  
s  db 0
r  db 0  
CAR1        DB      ? 
c2 db 0
r2 db 0  
s1  db 0
rrr db 0  
CAR2        DB      ?
MOVBUL2 DB 0
STATUSREG   EQU     3FDH
CONTROLREG  EQU     3FBH
TRANSMITREG EQU     3F8H 

.code
main proc   
    
                mov AX,@DATA
                mov DS,AX 
  
       CHAT:    MOV DX, 3FBH        ;LINE CONTROL REGISTER
                MOV AL, 10000000B   ;SET DIVISOR LATCH ACCESS
                OUT DX, AL          ;OUT IT

        ;SET LSB BYTE OF THE BAUD RATE DIV LATCH REG
                MOV DX, 3F8H
                MOV AL, 0CH
                OUT DX, AL

;SET MSB BYTE OF THE BAUD RATE DIV LATCH REG
                MOV DX, 3F9H
                MOV AL, 00H
                OUT DX, AL

;SET PORT CONFIGURATION 
                MOV DX, 3FBH
                MOV AL, 00000011B
                OUT DX, AL

                CALL SPLITSCREEN
                CALL SCURSOR1
                               
                 BOSSLOOP:
    mov s,0
    mov r,0
    ;GET KEY PRESSED 
    MOV AH, 1
    INT 16H
    JZ GOREC
    ; GET THE KEY
    MOV AH, 0
    INT 16H
    cmp ah,01h
    jnz here122
    here122:
    MOV CAR1, AL
    CALL SEND
    CMP S, 0
    JE PRINTREC
    CALL PRINTCHAR1
    INC C1
    CMP C1, 79
    JB GOREC
    INC R1
    MOV C1, 0
    ;CHECK NOS EL SHASHA------------------------------
    CMP R1, 13
    JB GOREC
GOREC:
    CALL RECIEVE
PRINTREC:
    CMP R, 0
    JE BOSSLOOP
    JMP BOSSLOOP               
                
                
main endp

SPLITSCREEN PROC
        MOV AX , 0B800H
        MOV ES ,AX
        MOV DI , 0 
        MOV AX , 0F20H
        MOV CX ,960
        REP STOSW 
        MOV AX , 0B800H
        MOV ES ,AX
        MOV DI , 0 
        ADD DI , 3C0H
        ADD DI ,3C0H
        MOV AX , 0F020H
        MOV CX ,1040
        REP STOSW 
        RET
SPLITSCREEN ENDP
;--------------
SCURSOR1    PROC
            MOV AH, 2
            MOV BH, 0
            MOV DL, C1
            MOV DH, R1
            INT 10H
            RET
SCURSOR1    ENDP     

SCURSOR2    PROC
            MOV AH, 2
            MOV BH, 0
            MOV DL, C2
            MOV DH, R2
            INT 10H
            RET
SCURSOR2    ENDP                         
                         
SEND    PROC
CHECKSEND:
        MOV DX, STATUSREG
        IN AL, DX
        TEST AL, 20H
        JZ LBL1
        MOV DX, TRANSMITREG
        MOV AL, CAR1
        OUT DX, AL
        MOV S, 1
LBL1:   RET
SEND    ENDP

;RECIEVE LINE REG TO CHECK THAT THERE IS DATA RECIEVED
RECIEVE PROC
CHECKREC:
        MOV DX, STATUSREG
        IN AL, DX
        TEST AL, 1H
        JZ LBL2
        MOV DX, TRANSMITREG
        IN AL, DX
        MOV CAR2, AL
        MOV R, 1
LBL2:   RET
RECIEVE ENDP  

PRINTCHAR1  PROC
            CALL SCURSOR1
            MOV AH, 9
            MOV AL, CAR1
            MOV BH, 0
            MOV BL, 0FH
            MOV CX, 1
            INT 10H
            RET
PRINTCHAR1  ENDP

end main
