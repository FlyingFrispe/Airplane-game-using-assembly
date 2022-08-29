.model SMALL 
.stack 64
.data   
WINDOW_WIDTH DW 140H; THE WIDTH OF THE CONSOLE (320 PIXELS)
WINDOW_HEIGHT DW 0C8H; THE HEIGHT OF THE CONSOLE (200 PIXELS)    
WINDOW_ERROR DW 1h  
            
MSG1 DB 'Enter  your name: $'  
MSG2 DB 'Press Enter to continue$'  
MSG3 DB 'To start chatting press F1$'
MSG4 DB 'To start the game press F2$'
MSG5 DB ' To exit the game press Esc$'
XPLANE DW 0AH ; X(COLUMN) POSITION OF AIRPLANE
YPLANE DW 0AH ; Y (ROW) POSITION OF AIRPLANE  

PLANE_POSITION DB 73h
PLANE_VELOCITY DW 02H 

BULLET_DIRECTION DB 0H
BULLET_VELOCITY DW 06H 

TIME_AUX DB 0 ;USED TO CHECK TIME
PlayerName db 16,?,16 dup('$')        
MESSAGES DB 30,?,30 DUP('?')
.code
main proc far
mov ax,@data
mov ds,ax

CALL CLEARSCREEN
call STARTSCREEN  

BACK_TO_MAINMENUE: 
call CLEARSCREEN  
CALL CLEAR_KEYBOARD_BUFFER
call MainMenue
;check on pressed button
mov ah,0
int 16h

;go to chatting mode
cmp ah,3bh
je ChattingMode

;start the game
cmp AH,3ch
je TheGame

;end the program
cmp al,1bh
je EndProgram

ChattingMode:
call CLEARSCREEN
call chat

;chatting mode implemented here


TheGame:
call CLEARSCREEN
call game

mov ah,0
int 16h

;the game implemnted here
    
    
    
    
    
    
    
EndProgram:    
MOV AH,4CH
INT 21H
    main endp 

NEWLINE PROC
MOV AH,2
MOV DL,0AH
INT 21H
MOV DL,0DH
INT 21H
RET
NEWLINE   ENDP

CLEARSCREEN PROC
mov ah,00
mov al,02
int 10h
RET
CLEARSCREEN ENDP

STARTSCREEN PROC 
mov ah,2
mov dx,0f0fH
int 10h
  
mov cx,dx  ;SAVE LOCATION OF CURSOR 
 ;print enter your name   
mov ah, 9
lea dx,MSG1 
int 21h
;leave a line for entering your name
mov dx,cx
mov ah,2
add dh,2
int 10h
;print press enter to continue
mov ah, 9
lea dx,MSG2
int 21h  
;go back to the middle to enter name
mov dx,cx
mov ah,2
inc dh
int 10h
;take name from user
mov ah,0AH
LEA dx,PlayerName
int 21h

lea si,PlayerName +2
MOV AL,[SI] 
CMP AL,41H
JAE CHECK2
MOV AL,50H
MOV [SI],AL
JMP EXIT
CHECK2:
CMP AL,5AH
JBE EXIT  

JMP CHECK3

CHECK3: 
CMP AL,61H
JAE CHECK4
MOV AL,50H
MOV [SI],AL
JMP EXIT

CHECK4:
CMP AL,7AH
JBE EXIT
MOV AL,50H
MOV [SI],AL
JMP EXIT

EXIT:    
RET 
STARTSCREEN    ENDP

BACKTOMAINMENUE PROC
JMP BACK_TO_MAINMENUE
RET
BACKTOMAINMENUE ENDP

MainMenue proc 

mov ah,2
mov dx,0f0fH
int 10h
  
mov cx,dx  ;SAVE LOCATION OF CURSOR 
mov ah, 9
lea dx,MSG3 
int 21h

mov dx,cx
mov ah,2
add dh,2
int 10h


mov ah, 9
lea dx,MSG4 
int 21h

mov dx,cx
mov ah,2
add dh,4
int 10h

mov ah, 9
lea dx,MSG5 
int 21h

RET
MainMenue endp

chat PROC
    ;go to middle of screen 
    mov cx,13
    loop1:
    call NEWLINE
    loop loop1
    
    ;print seprating line
    mov cx,50h
    loop2:
    mov ah, 2
    mov dl,'-'
    int 21h 
    loop loop2
    ;print name
    mov ah,9
    lea dx,PlayerName+2
    int 21H    
call NEWLINE   

loop3:  
mov ah,0
int 16h 
cmp AH,3Dh ;EXIT IF USER PRESSED F3
je Exitc
mov ah,0AH
LEA dx,MESSAGES
int 21h 
call NEWLINE
jne loop3 
Exitc:
RET
chat endp

Game proc 
CALL CLEARVIDEO
MOV CL,0H

LOOP_DRAW_PLANE:
CALL DRAW_PLANE
CALL DRAW_HEALTH
CALL MOVE_PLANE

CHECK_TIME:
MOV AH,2CH ;GET THE SYSTEM TIME 
INT 21H ;CH = hour CL = minute DH = second DL = 1/100 seconds 
CMP DL,TIME_AUX ;CHECK if current time = TIME_AUX

JE CHECK_TIME ;IF ITS THE SAME GET TIME AGAIN 
MOV TIME_AUX,DL ; IF NOT UPDATE TIME_AUX AND GO BACK TO DRAW THE X AND Y 
JMP LOOP_DRAW_PLANE

RET
Game endp

DELAY PROC 
MOV     CX, 01H
MOV     DX, 4240H
MOV     AH, 86H
INT     15H
RET
DELAY ENDP

DRAW_PLANE PROC 
CALL CLEARVIDEO
MOV AH,0CH
MOV AL,0FH ;CHOOSE COLOR AS WHITE
MOV CX,XPLANE
MOV DX,YPLANE
INT 10h

RET
DRAW_PLANE ENDP

CLEARVIDEO PROC
    mov ah,00h
    mov al,13h;320x200
    int 10h;open graphics mode 

RET
CLEARVIDEO ENDP

DRAW_HEALTH PROC
  
    MOV AH,2
    MOV DX,0H;SET CURSOR POSITION TO 0
    INT 10H

    MOV CX,5
    LOOP_HEALTH:
    MOV AH,2
    MOV DL,03H;DRAW HEARTS AT TOP OF THE PAGE
    INT 21h
    LOOP LOOP_HEALTH


    RET
DRAW_HEALTH ENDP

MOVE_PLANE PROC
MOV AX,0H  
LEA SI,PLANE_POSITION


MOV AL,[SI];RESTORE OLD POSITION OF PLANE
MOV AH,1;CHECK IF A  BUTTON IS PRESSED
INT 16h


CMP AL,73h
JE INCREMENT_Y
CMP AL,53h
JE INCREMENT_Y

CMP AL,77h
JE DECREMENT_Y
CMP AL,57h
JE DECREMENT_Y

CMP AL,64H
JE  INCREMENT_X
CMP AL,44H
JE  INCREMENT_X

CMP AL,61H
jmp checkdecX
CMP AL,41H
jmp checkdecX

COMPLETE1:
CMP AL,20H
JMP checkshoot

COMPLETE2:
CMP AL,1bh
JMP BACK_TO_MAIN



COMPLETE3:
JMP INVALID_BUTTON

INCREMENT_Y:
MOV [SI] ,AL
MOV AX,PLANE_VELOCITY
ADD YPLANE,AX
MOV BX, WINDOW_HEIGHT  
SUB BX,WINDOW_ERROR
CMP YPLANE,BX
JAE STOP1 
CALL CLEAR_KEYBOARD_BUFFER
JMP CHECK_TIME
STOP1:
MOV AX,PLANE_VELOCITY
SUB YPLANE,AX 
CALL CLEAR_KEYBOARD_BUFFER
JMP CHECK_TIME

DECREMENT_Y:
MOV [SI] ,AL
MOV AX,PLANE_VELOCITY
SUB YPLANE,AX
CMP YPLANE,00H
JL STOP2  
CALL CLEAR_KEYBOARD_BUFFER
JMP CHECK_TIME
STOP2:
MOV AX,PLANE_VELOCITY
ADD YPLANE,AX
CALL CLEAR_KEYBOARD_BUFFER
JMP CHECK_TIME

INCREMENT_X:
MOV [SI] ,AL
MOV AX,PLANE_VELOCITY
ADD XPLANE,AX
MOV BX,WINDOW_WIDTH
sub BX,WINDOW_ERROR
CMP XPLANE,BX
JA STOP3
CALL CLEAR_KEYBOARD_BUFFER
JMP CHECK_TIME
STOP3:
MOV AX,PLANE_VELOCITY
SUB XPLANE,AX 
CALL CLEAR_KEYBOARD_BUFFER
JMP CHECK_TIME

checkdecX:
CMP AL,61H
JE DECREMENT_X
CMP AL,41H
JE DECREMENT_X
JMP COMPLETE1

DECREMENT_X:
MOV [SI] ,AL
MOV AX,PLANE_VELOCITY
SUB XPLANE,AX
CMP XPLANE,00H
JL STOP4 
CALL CLEAR_KEYBOARD_BUFFER
JMP CHECK_TIME
STOP4:
MOV AX,PLANE_VELOCITY
ADD XPLANE,AX
CALL CLEAR_KEYBOARD_BUFFER
JMP CHECK_TIME



checkshoot:
CMP al,20H
JE SHOOT_BULLET
JMP COMPLETE2

SHOOT_BULLET:
CALL BULLET_SHOOT



BACK_TO_MAIN:
CMP AL,1bh
JE GO_MAINMENUE_FUNC
JMP COMPLETE3

GO_MAINMENUE_FUNC:
call BACKTOMAINMENUE

INVALID_BUTTON:
CALL CLEAR_KEYBOARD_BUFFER

RET
MOVE_PLANE ENDP

BULLET_SHOOT PROC
LEA DI,BULLET_DIRECTION
MOV BL,[SI]

CMP BL,73h
JE BULLET_DOWN
CMP BL,53h
JE BULLET_DOWN

CMP BL,77h
JE BULLET_UP
CMP BL,57h
JE BULLET_UP

CMP BL,64h
JE BULLET_RIGHT
CMP BL,44h
JE BULLET_RIGHT

CMP BL,61h
JE BULLET_LEFT
CMP BL,41h
JE BULLET_LEFT

BULLET_DOWN:


BULLET_UP:


BULLET_RIGHT:


BULLET_LEFT:

BULLET_SHOOT ENDP

CLEAR_KEYBOARD_BUFFER PROC
mov ah,0ch              
int 21h
RET
CLEAR_KEYBOARD_BUFFER ENDP
end main    