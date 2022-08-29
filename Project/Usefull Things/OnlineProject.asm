.model SMALL 
.386
.stack 64
.data   
;SCREEN PARAMETERS
WINDOW_WIDTH DW 140H; THE WIDTH OF THE CONSOLE (320 PIXELS)
WINDOW_HEIGHT DW 0C8H; THE HEIGHT OF THE CONSOLE (200 PIXELS)    
WINDOW_ERROR DW 1h  
CHAT_X DB ?
CHAT_Y DB ?
CHAT_X2 DB ?
CHAT_Y2 DB ?
;POWER UPS PARAMETERS
TIME_AUX2 DB 0 ;SPAWN POWERUPS EVERY X SECONDS 
POWERUP_APPEARED DW 0
XPOWERUPS DW 80H
YPOWERUPS DW 80H
POWERUP_TYPE DW 1H
FIRST_SECOND_READ DW 01H ;read time as powerups spawn every 10 seconds
IS_PLANE1_FROZEN DW 0H;PLANE 2 PCICKS UP FREEZE POWER UP
IS_PLANE2_FROZEN DW 0H;PLANE 1 PICKS UP FREEZE POWERUP
FREEZING_TIME DB 0;KEEP PLANE1 OR PLANE 2 FROZEN FOR X SECONDS
FIRST_FREEZING_READ DW 01H
;recive and send data parameters
VALUE DB ?
VALUER DB 00H
PC_NUMBER DB 1 
;GAME OVER
GAME_OVER DW 0
GAME_INVITATION DB 0
GAME_INVITATION2 DB 0 
;MESSAGES TO PRINT AND INPUT FROM USER TO PRINT           
MSG1 DB 'Enter  your name: $'  
MSG2 DB 'Press Enter to continue$'  
MSG3 DB 'To start chatting press F1$'
MSG4 DB 'To start the game press F2$'
MSG5 DB ' To exit the game press Esc$'
MSG6 DB 'Player 2$'
MSG7 DB 'Plane2(White) won (Press any key to go back to mainmenue) $'
MSG8 DB 'Plane1(Green) won (Press any key to go back to mainmenue) $'
MSG9 DB 'Both lost (Press any key to go back to mainmenue) $'
PlayerName db 16,?,16 dup('$')  
PlayerName2 db 16,?,16 dup('$')       
MESSAGES DB 30,?,30 DUP('?')
;PLANE1 PARAMETERS
XPLANE DW 17H ; X(COLUMN) POSITION OF AIRPLANE
YPLANE DW 0AH ; Y (ROW) POSITION OF AIRPLANE  
PLANE_POSITION DW 73h
PLANE_HEALTH DW 5H
YPLANE_PREVIOUS DW 17H
XPLANE_PREVIOUS DW 0AH  
;PLANE 2 PARAMETERS
XPLANE2 DW 0AAH
YPLANE2 DW 0AAH
PLANE2_POSITION DW 4AH
PLANE2_HEALTH DW 5H
YPLANE2_PREVIOUS DW 0AAH
XPLANE2_PREVIOUS DW 0AAH  

;PLANE PARAMETERS
PLANE_VELOCITY DW 02H 
Airplane_Width EQU 25
Airplane_Height EQU 25 

PLANE_HEIGHT EQU 5H

Airplane_FileName DB 'Airplane.bin',0  
Airplane_FileHandle DW ?  
Airplane_Data DB Airplane_Width*Airplane_Height DUP(0)
 


;BULLET VELOCITY
BULLET_VELOCITY DW 08H 




;BULLET1 PARAMETERS
XBULLET1 DW ?
YBULLET1 DW ?
FIRST_BULLET1_MOVEMENT DB 1h
BULLET1_DIRECTION DW 44H
IS_BULLET1_SHOT DW 0H

;BULLET2 PARAMETERS
XBULLET2 DW ?
YBULLET2 DW ?
FIRST_BULLET2_MOVEMENT DB 1h
BULLET2_DIRECTION DW 50H
IS_BULLET2_SHOT DW 0H


TIME_AUX DB 0 ;USED TO CHECK TIME


.code
main proc far
mov ax,@data
mov ds,ax

CALL CLEARSCREEN
call STARTSCREEN  
CALL SEND_PLAYER2_NAME

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
;-->
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

EXIT:; send player name to other pc and save it in player name2 
RET 
STARTSCREEN ENDP

SEND_PLAYER2_NAME PROC
LEA SI,PlayerName
LEA DI,PlayerName2
MOV CL,[SI]+1
LOOP_SAVE_NAME:
MOV AL,[SI]+2
MOV VALUE,AL
CALL PORTS_INTLIZATION
CALL SEND_DATA  
CALL READ_DATA
MOV [DI]+2,AL
INC DI
INC SI  
DEC CL
CMP CL,0H
JNZ LOOP_SAVE_NAME
SEND_PLAYER2_NAME ENDP

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

PORTS_INTLIZATION PROC
Mov dx,3fbh
mov al,10000000b
Out dx,al
mov dx,3fbh
mov al,0ch
out dx,al
mov dx,3fdh
mov al,00h
out dx,al
mov dx,3fbh
mov al,00011011b
out dx,al      
RET
PORTS_INTLIZATION ENDP

SEND_DATA PROC
Mov dx,3fdh
AGAIN1:
In al,dx
and al,00100000b
JZ AGAIN1
Mov dx,3f8h
Mov al,VALUE
Out dx,al
RET
SEND_DATA ENDP

READ_DATA PROC
Mov dx,3fdh
CHK:
In al,dx
test al,1
Jz CHK
Mov dx,03f8h
in al,dx
mov VALUER,al
RET
READ_DATA ENDP

READ_DATAC PROC
Mov dx,3fdh
In al,dx
test al,1
Jz PLS_RET
Mov dx,03f8h
in al,dx
mov VALUER,al
PLS_RET:
RET
READ_DATAC ENDP

SEND_DATAC PROC
Mov dx,3fdh
In al,dx
and al,00100000b
JZ PLS_RET1
Mov dx,3f8h
Mov al,VALUE
Out dx,al
PLS_RET1:
RET
SEND_DATAC ENDP


chat PROC
    ;print other player name
    mov ah,9
    lea dx,PlayerName2+2
    int 21H
    CALL NEWLINE 
    MOV AH,3H
    MOV BH,0H
    INT 10H
    MOV CHAT_X,DL
    MOV CHAT_Y,DH 
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
    MOV AH,3h
    MOV BH,0H
    INT 10H 
    MOV CHAT_X2,DL
    MOV CHAT_Y2,DH 

loop3: 
MOV AH,2
MOV DL,CHAT_X2
MOV DH,CHAT_Y2
INT 10H
mov al,0E6h ;intliaze al with zero

mov ah,1; check if a key is pressed
INT 16h 
call CLEAR_KEYBOARD_BUFFER
cmp AL,0E6h
JE HERE40; no key pressed

MOV AH,2
MOV DL,AL
INT 21h

INC CHAT_X2
HERE40:
MOV VALUE,AL
CALL PORTS_INTLIZATION
CALL SEND_DATA
CALL PORTS_INTLIZATION
CALL READ_DATAC
MOV AL,VALUER
CMP AH,3BH
JE Exitc
CMP AL,0E6H
JE READ_ANOTHER_KEY
MOV AH,2
MOV DL,CHAT_X
MOV DH,CHAT_Y
INT 10H
MOV AH,2
MOV DL,VALUER
INT 21h
INC CHAT_X
READ_ANOTHER_KEY:
JMP LOOP3
Exitc:
RET
chat endp

Game proc 
CALL CLEARVIDEO
MOV CL,0H

LOOP_DRAW_PLANE:
;check if the previous game has endded
CMP GAME_OVER,1
JE PREVIOUS_GAME_ENDED
JMP GAME_DIDNT_END
PREVIOUS_GAME_ENDED:
CALL RESET_GAME
MOV GAME_OVER,0
GAME_DIDNT_END:
CALL ARSM_PLANE
CALL DRAW_HEALTH
CALL MOVE_PLANE
CMP POWERUP_APPEARED,1
JE PLEASE_DRAW
JMP NO_POWERUPS
PLEASE_DRAW:
CALL DRAW_POWER_UPS
;CALL POWERUPS_COLLISION
;CALL DRAW_POWER_UPS
;BULLET DRAWING IF FEASIABLE
NO_POWERUPS:
cmp IS_BULLET1_SHOT,1
JE BULLET_IS_SHOT

CMP IS_BULLET2_SHOT,1
JE BULLET_IS_SHOT
JMP CHECK_TIME

BULLET_IS_SHOT:
CALL MOVE_BULLET11
CALL ARSM_BULLET

CHECK_TIME:
MOV AH,2CH ;GET THE SYSTEM TIME 
INT 21H ;CH = hour CL = minute DH = second DL = 1/100 seconds 
CMP DL,TIME_AUX ;CHECK if current time = TIME_AUX
JE CHECK_TIME ;IF ITS THE SAME GET TIME AGAIN 
MOV TIME_AUX,DL ; IF NOT UPDATE TIME_AUX AND GO BACK TO DRAW THE X AND Y 
;spawn a powerup or no?
CMP POWERUP_APPEARED,1h
JE SPAWN_POWERUP
CMP FIRST_SECOND_READ,1H
JE READ1
JMP CHECK_IF_ITS_TIME
READ1:
MOV TIME_AUX2,DH
ADD TIME_AUX2,10
CMP TIME_AUX2,3BH
JA SUB60
JMP TIS_OKAY
SUB60:
SUB TIME_AUX2,3BH
TIS_OKAY:
MOV FIRST_SECOND_READ,0H
CHECK_IF_ITS_TIME : 
CMP DH,TIME_AUX
JE SPAWN_POWERUP
JMP COMPLETE_CODE
SPAWN_POWERUP:
MOV POWERUP_APPEARED,1
COMPLETE_CODE:
CALL CHECK_AIRPLANE_COLLISION
CALL BULLET_COLLISION
CALL DID_SOMEONE_WIN
CALL POWERUPS_COLLISION

;FREEZING TIME
CMP IS_PLANE1_FROZEN,1
JE START_FREEZING_TIME
CMP IS_PLANE2_FROZEN,1
JE START_FREEZING_TIME
JMP NO_FREEZING_TIME

START_FREEZING_TIME:
CMP FIRST_FREEZING_READ,1
JE FREEZE1
JMP CHECK_TO_UNFREEZE
FREEZE1:
MOV FREEZING_TIME,DH
ADD FREEZING_TIME,3h
CMP FREEZING_TIME,3BH
JA SUB601
JMP DONT_UNFREEZE
SUB601:
SUB FREEZING_TIME,3BH
DONT_UNFREEZE:
MOV FIRST_FREEZING_READ,0H

CHECK_TO_UNFREEZE:
CMP DH,FREEZING_TIME
JE UNFREEZE_PLEASE
JMP NO_FREEZING_TIME
UNFREEZE_PLEASE:
MOV IS_PLANE1_FROZEN,0
MOV IS_PLANE2_FROZEN,0
MOV FIRST_FREEZING_READ,1H


NO_FREEZING_TIME:
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

MOV AH,0CH
MOV AL,0FH ;CHOOSE COLOR AS WHITE
MOV CX,XPLANE2
MOV DX,YPLANE2
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

    MOV CX,PLANE_HEALTH
    LOOP_HEALTH:
    MOV AH,2
    MOV DL,03H;DRAW HEARTS AT TOP OF THE PAGE
    INT 21h
    LOOP LOOP_HEALTH
    ;PRINT PLAYER1 NAME AND PLAYER2 NAMES 
    call PRINT_NAMES
    
   ; MOV AH,2
   ; MOV DX,0FCH;SET CURSOR POSITION TO 0
   ; INT 10H


    MOV CX,PLANE2_HEALTH
    LOOP_HEALTH2:
    MOV AH,2
    MOV DL,03H;DRAW HEARTS AT TOP OF THE PAGE
    INT 21h
    LOOP LOOP_HEALTH2

    
    RET
DRAW_HEALTH ENDP
DID_SOMEONE_WIN PROC
    mov ax,PLANE_HEALTH
    mov bx,PLANE2_HEALTH
    CMP AX,0
    JE CHECK_IF_PLANE2_WON
    JMP CHECK_ON_PLANE2
    CHECK_IF_PLANE2_WON:
    CMP BX,0
    JA PLANE2_WON
    JLE BOTHLOSE
    CHECK_ON_PLANE2:
    CMP BX,0
    JE CHECK_IF_PLANE1_WON
    JMP NO_ONE_WON_YET

    CHECK_IF_PLANE1_WON:
    CMP AX,0
    JA PLANE1_WON
    JE BOTHLOSE
    
    
    PLANE2_WON:
    ;han3ml7agat hnaa
    call CLEARSCREEN
    mov ah,2
    mov dx,0f0fH
    int 10h
    mov ah,9
    lea dx,MSG7
    int 21H
    mov GAME_OVER,1
    mov ah,0
    int 16h
    call BACK_TO_MAINMENUE

    
    PLANE1_WON:
        ;han3ml7agat hnaa
    call CLEARSCREEN
    mov ah,2
    mov dx,0f0fH
    int 10h
    mov ah,9
    lea dx,MSG8
    int 21H
    mov GAME_OVER,1
    mov ah,0
    int 16h
    call BACK_TO_MAINMENUE
   
    BOTHLOSE:
    ;han3ml7agat hnaa
    call CLEARSCREEN
    mov ah,2
    mov dx,0f0fH
    int 10h
    mov ah,9
    lea dx,MSG9
    int 21H
    mov GAME_OVER,1
    mov ah,0
    int 16h
    call BACK_TO_MAINMENUE

    NO_ONE_WON_YET:
    RET
DID_SOMEONE_WIN ENDP

PRINT_NAMES PROC 
LEA DI,PlayerName+2
mov cx,[DI]-1
MOV CH,0
LOOP65:
mov ah, 0eh           ;0eh = 14
mov al, [di]
xor bx, bx            ;Page number zero
mov bl, 0ch           ;Color is red
int 10h 
INC DI
DEC CX
JNZ LOOP65
;PRINT SOME SPACES
 MOV CX,0FH
 LOOP_SPACES:  
 MOV AH,2
 MOV DL,20H
 INT 21h
 LOOP LOOP_SPACES

;PRINT PLAYER2
LEA DI,MSG6
MOV CX,8H
LOOP66:
mov ah, 0eh           ;0eh = 14
mov al, [di]
xor bx, bx            ;Page number zero
mov bl, 0ch           ;Color is red
int 10h 
INC DI
DEC CX
JNZ LOOP66



DONT_PRINT:
RET
PRINT_NAMES ENDP

SEND_PLANE1_MOVEMENTS PROC
MOV VALUE,AL
CALL PORTS_INTLIZATION
CALL SEND_DATA
CALL PORTS_INTLIZATION
CALL READ_DATA
RET
SEND_PLANE1_MOVEMENTS ENDP

SEND_PLANE2_MOVEMENTS PROC
MOV VALUE,AH
CALL PORTS_INTLIZATION
CALL SEND_DATA
CALL PORTS_INTLIZATION
CALL READ_DATA
RET
SEND_PLANE2_MOVEMENTS ENDP


MOVE_PLANE PROC
;MOV AL,0H 
CMP IS_PLANE1_FROZEN,1
JE  MOVEPLANE2
LEA SI,PLANE_POSITION
MOV AL,[SI];RESTORE OLD POSITION OF PLANE
CMP PC_NUMBER,1
JE TAKE_PLANE1_MOVEMENTS_ONLY
CMP PC_NUMBER,2
JE READ_SENT_DATA_FROMPC1
TAKE_PLANE1_MOVEMENTS_ONLY:
MOV AH,1;CHECK IF A  BUTTON IS PRESSED
INT 16h
MOV VALUE,AL
CALL PORTS_INTLIZATION
CALL SEND_DATA
JMP MOVE_PLANE1
READ_SENT_DATA_FROMPC1:
CALL PORTS_INTLIZATION
CALL READ_DATA
MOV AL,VALUER

MOVE_PLANE1:
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
CMP AL,20h
JMP checkshoot

COMPLETE2:
CMP AL,1bh
JMP BACK_TO_MAIN



COMPLETE3:
JMP MOVEPLANE2

INCREMENT_Y:
MOV [SI] ,AL
MOV AX,PLANE_VELOCITY
ADD YPLANE,AX
MOV BX, WINDOW_HEIGHT  
SUB BX,WINDOW_ERROR
MOV CX,YPLANE
ADD CX,5
CMP CX,BX
JAE STOP1 
CALL CLEAR_KEYBOARD_BUFFER
JMP MOVEPLANE2
STOP1:
MOV AX,PLANE_VELOCITY
SUB YPLANE,AX 
CALL CLEAR_KEYBOARD_BUFFER
JMP MOVEPLANE2

DECREMENT_Y:
MOV [SI] ,AL
MOV AX,PLANE_VELOCITY
SUB YPLANE,AX
push bx
mov bx,PLANE_HEIGHT+15
CMP YPLANE,bx
pop BX
JL STOP2  
CALL CLEAR_KEYBOARD_BUFFER
JMP MOVEPLANE2
STOP2:
MOV AX,PLANE_VELOCITY
ADD YPLANE,AX
CALL CLEAR_KEYBOARD_BUFFER
JMP MOVEPLANE2

INCREMENT_X:
MOV [SI] ,AL
MOV AX,PLANE_VELOCITY
ADD XPLANE,AX
MOV BX,WINDOW_WIDTH
sub BX,WINDOW_ERROR
CMP XPLANE,BX
JA STOP3
CALL CLEAR_KEYBOARD_BUFFER
JMP MOVEPLANE2
STOP3:
MOV AX,PLANE_VELOCITY
SUB XPLANE,AX 
CALL CLEAR_KEYBOARD_BUFFER
JMP MOVEPLANE2

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
MOV BX,PLANE_HEIGHT+15
CMP XPLANE,BX
JL STOP4 
CALL CLEAR_KEYBOARD_BUFFER
JMP MOVEPLANE2
STOP4:
MOV AX,PLANE_VELOCITY
ADD XPLANE,AX
CALL CLEAR_KEYBOARD_BUFFER
JMP MOVEPLANE2



checkshoot:
CMP al,20H
JE SHOOT_BULLET
JMP COMPLETE2

SHOOT_BULLET:
CMP IS_BULLET1_SHOT,0
JE YES_SHOOT
JMP BACK_TO_MAIN
YES_SHOOT:
MOV IS_BULLET1_SHOT,1
push ax
mov ax,XPLANE
mov XBULLET1,ax
mov ax,YPLANE
mov YBULLET1,ax
;mov ax,PLANE_POSITION
;mov BULLET1_DIRECTION,AX
POP AX
JMP INVALID_BUTTON



BACK_TO_MAIN:
CMP AL,1bh
JE GO_MAINMENUE_FUNC
JMP COMPLETE3

GO_MAINMENUE_FUNC:
call BACKTOMAINMENUE

INVALID_BUTTON:
CALL CLEAR_KEYBOARD_BUFFER

MOVEPLANE2:
CMP IS_PLANE2_FROZEN,1
JE INVALID_BUTTON2   
LEA SI,PLANE2_POSITION
MOV AL,[SI];RESTORE OLD POSITION OF PLANE
CMP PC_NUMBER,2
JE TAKE_PLANE2_MOVEMENTS_ONLY
CMP PC_NUMBER,1
JE READ_SENT_DATA_FROMPC2
TAKE_PLANE2_MOVEMENTS_ONLY:
MOV AH,1;CHECK IF A  BUTTON IS PRESSED
INT 16h  
MOV VALUE,AL
CALL CLEAR_KEYBOARD_BUFFER
CALL PORTS_INTLIZATION
CALL SEND_DATA
JMP MOVE_PLANE2

READ_SENT_DATA_FROMPC2:
CALL PORTS_INTLIZATION
CALL READ_DATA
MOV AL,VALUER

MOVE_PLANE2:
CMP AL,4Bh
JE INCREMENT_Y2
CMP AL,6Bh
JE INCREMENT_Y2

CMP AL,49h
JE DECREMENT_Y2
CMP AL,69h
JE DECREMENT_Y2

CMP AL,4CH
JE  INCREMENT_X2
CMP AL,6CH
JE  INCREMENT_X2

CMP AL,4AH
jmp checkdecX2
CMP AL,6AH
jmp checkdecX2

COMPLETE4:
CMP AL,4EH
JMP checkshoot2
CMP AL,6EH
JMP checkshoot2

COMPLETE5:
CMP AL,1bh
JMP BACK_TO_MAIN2



COMPLETE6:
JMP INVALID_BUTTON2

INCREMENT_Y2:
MOV [SI] ,AL
MOV AX,PLANE_VELOCITY
ADD YPLANE2,AX
MOV BX, WINDOW_HEIGHT  
SUB BX,WINDOW_ERROR
MOV CX,YPLANE2
ADD CX,5
CMP CX,BX
JAE STOP5 
CALL CLEAR_KEYBOARD_BUFFER
JMP INVALID_BUTTON2
STOP5:
MOV AX,PLANE_VELOCITY
SUB YPLANE2,AX 
CALL CLEAR_KEYBOARD_BUFFER
JMP INVALID_BUTTON2

DECREMENT_Y2:
MOV [SI] ,AL
MOV AX,PLANE_VELOCITY
SUB YPLANE2,AX
MOV BX,PLANE_HEIGHT+15
CMP YPLANE2,BX
JL STOP6  
CALL CLEAR_KEYBOARD_BUFFER
JMP INVALID_BUTTON2
STOP6:
MOV AX,PLANE_VELOCITY
ADD YPLANE2,AX
CALL CLEAR_KEYBOARD_BUFFER
JMP INVALID_BUTTON2

INCREMENT_X2:
MOV [SI] ,AL
MOV AX,PLANE_VELOCITY
ADD XPLANE2,AX
MOV BX,WINDOW_WIDTH
sub BX,WINDOW_ERROR
SUB BX,20
CMP XPLANE2,BX
JA STOP7
CALL CLEAR_KEYBOARD_BUFFER
JMP INVALID_BUTTON2
STOP7:
MOV AX,PLANE_VELOCITY
SUB XPLANE2,AX 
CALL CLEAR_KEYBOARD_BUFFER
JMP INVALID_BUTTON2

checkdecX2:
CMP AL,4AH
JE DECREMENT_X2
CMP AL,6AH
JE DECREMENT_X2
JMP COMPLETE4

DECREMENT_X2:
MOV [SI] ,AL
MOV AX,PLANE_VELOCITY
SUB XPLANE2,AX
MOV BX,PLANE_HEIGHT-3
CMP XPLANE2,BX
JL STOP8 
CALL CLEAR_KEYBOARD_BUFFER
JMP INVALID_BUTTON2
STOP8:
MOV AX,PLANE_VELOCITY
ADD XPLANE2,AX
CALL CLEAR_KEYBOARD_BUFFER
JMP INVALID_BUTTON2



checkshoot2:
CMP al,4EH
JE SHOOT_BULLET2
CMP al,6EH
JE SHOOT_BULLET2
JMP COMPLETE5

SHOOT_BULLET2:
CMP IS_BULLET2_SHOT,0
JE YES_SHOOT2
JMP BACK_TO_MAIN2
YES_SHOOT2:
mov IS_BULLET2_SHOT,1
push ax
mov ax,XPLANE2
mov XBULLET2,ax
mov ax,YPLANE2
mov YBULLET2,ax
;mov ax,PLANE2_POSITION
;mov BULLET2_DIRECTION,AX
POP AX
JMP INVALID_BUTTON2




BACK_TO_MAIN2:
CMP AL,1bh
JE GO_MAINMENUE_FUNC2
JMP COMPLETE6

GO_MAINMENUE_FUNC2:
call BACKTOMAINMENUE

INVALID_BUTTON2:
CALL CLEAR_KEYBOARD_BUFFER

RET
MOVE_PLANE ENDP

CLEAR_KEYBOARD_BUFFER PROC
mov ah,0ch              
int 21h
RET
CLEAR_KEYBOARD_BUFFER ENDP

DRAW_BULLET PROC
CALL CLEARVIDEO
MOV AH,0CH
MOV AL,0FH ;CHOOSE COLOR AS WHITE
MOV CX,XBULLET1
MOV DX,YBULLET1
INT 10h
RET
DRAW_BULLET ENDP 

ARSM_PLANE PROC
CALL CLEARVIDEO    

MOV AH,0CH
MOV AL,0aH ;CHOOSE COLOR AS WHITE 
MOV BX,PLANE_HEIGHT   
MOV CX,XPLANE  ;X COORDINATE
MOV DX,YPLANE  ;Y COORDINATE
LOOP40:
INT 10h
DEC CX
DEC DX 
DEC BX
CMP BX,0
JNE LOOP40

MOV BX,PLANE_HEIGHT
MOV AL,0aH  
LOOP41:
DEC CX
INT 10H
DEC BX
CMP BX,0
JNE LOOP41  

MOV BX,PLANE_HEIGHT  
MOV AL,0aH
LOOP42:
INT 10h
DEC CX
DEC DX 
DEC BX
CMP BX,0
JNE LOOP42 

 
MOV AH,0CH
MOV AL,0aH
MOV BX,PLANE_HEIGHT 
LOOP43:  
INC DX
INT 10h 
DEC BX
CMP BX,0
JNE LOOP43   

MOV BX,PLANE_HEIGHT  
LOOP44:
DEC CX
INT 10H
DEC BX
CMP BX,0
JNE LOOP44 

MOV BX,PLANE_HEIGHT
LOOP45:  
INC DX
INT 10H
DEC BX
CMP BX,0
JNE LOOP45 

MOV BX,PLANE_HEIGHT
LOOP46:
INC CX
INT 10H
DEC BX
CMP BX,0
JNE LOOP46 

MOV BX,PLANE_HEIGHT
LOOP47:
INC DX
INT 10H
DEC BX
CMP BX,0
JNE LOOP47

MOV BX,PLANE_HEIGHT
LOOP48:
INC CX
DEC DX
INT 10H
DEC BX
CMP BX,0
JNE LOOP48

MOV BX,PLANE_HEIGHT
LOOP49: 
INC CX
INT 10H
DEC BX
CMP BX,0
JNE LOOP49

MOV BX,PLANE_HEIGHT
LOOP50:
DEC DX 
INC CX
INT 10H
DEC BX
CMP BX,0
JNE LOOP50
;DRAWING SECOND PLANE
MOV AH,0CH
MOV AL,0FH ;CHOOSE COLOR AS WHITE 
MOV BX,PLANE_HEIGHT   
MOV CX,XPLANE2  ;X COORDINATE
MOV DX,YPLANE2  ;Y COORDINATE 
LOOP51:
INT 10h
INC CX
DEC DX 
DEC BX
CMP BX,0
JNE LOOP51 

MOV BX,PLANE_HEIGHT 
LOOP52:
INC CX
INT 10H
DEC BX
CMP BX,0
JNE LOOP52  

MOV BX,PLANE_HEIGHT
LOOP53:
INT 10h
INC CX
DEC DX 
DEC BX
CMP BX,0
JNE LOOP53 

MOV BX,PLANE_HEIGHT
LOOP54:
INC DX
INT 10h 
DEC BX
CMP BX,0
JNE LOOP54  

MOV BX,PLANE_HEIGHT
LOOP55:
INC CX
INT 10H
DEC BX
CMP BX,0
JNE LOOP55 

MOV BX,PLANE_HEIGHT
LOOP56:
INC DX
INT 10H
DEC BX
CMP BX,0
JNE LOOP56 

MOV BX,PLANE_HEIGHT
LOOP57:
DEC CX
INT 10H
DEC BX
CMP BX,0 
JNE LOOP57

MOV BX,PLANE_HEIGHT
LOOP58: 
INC DX
INT 10H
DEC BX
CMP BX,0
JNE LOOP58

MOV BX,PLANE_HEIGHT
LOOP59: 
DEC CX
DEC DX
INT 10H
DEC BX
CMP BX,0
JNE LOOP59  

MOV BX,PLANE_HEIGHT
LOOP60:
DEC CX
INT 10H
DEC BX
CMP BX,0
JNE LOOP60 

MOV BX,PLANE_HEIGHT
LOOP61: 
DEC DX 
DEC CX
INT 10H
DEC BX
CMP BX,0
JNE LOOP61


RET
ARSM_PLANE ENDP

OpenFile PROC 

    ; Open file

    MOV AH, 3Dh
    MOV AL, 0 ; read only
    LEA DX, Airplane_FileName
    INT 21h
    
    ; you should check carry flag to make sure it worked correctly
    ; carry = 0 -> successful , file handle -> AX
    ; carry = 1 -> failed , AX -> error code
     
    MOV [Airplane_FileHandle], AX
    
    RET

OpenFile ENDP  

ReadData PROC

    MOV AH,3Fh
    MOV BX, [Airplane_FileHandle]
    MOV CX,Airplane_Width*Airplane_Height ; number of bytes to read
    LEA DX, Airplane_Data
    INT 21h
    RET
ReadData ENDP  

CloseFile PROC
	MOV AH, 3Eh
	MOV BX, [Airplane_FileHandle]

	INT 21h
	RET
CloseFile ENDP

CHECK_AIRPLANE_COLLISION PROC
 ;FIRST COMPARE:



MOV AX,XPLANE
MOV BX,XPLANE2
SUB AX,PLANE_HEIGHT
ADD BX,20
CMP AX,BX
JL CHECK10
JMP NO_COLLISION
CHECK10:
SUB BX,20
CMP AX,BX
JA CHECK_ON_Y
JMP NO_COLLISION

CHECK_ON_Y:
MOV AX,YPLANE
MOV BX,YPLANE2
SUB AX,PLANE_HEIGHT
CMP AX,BX
JLE CHECK11
JMP NO_COLLISION
CHECK11:
SUB BX,PLANE_HEIGHT
CMP AX,BX
JAE COLLISION
JMP NO_COLLISION

COLLISION:
DEC PLANE_HEALTH
DEC PLANE2_HEALTH
MOV AX,XPLANE_PREVIOUS
MOV BX,YPLANE_PREVIOUS
MOV XPLANE,AX
MOV YPLANE,BX
MOV AX,XPLANE2_PREVIOUS
MOV BX,YPLANE2_PREVIOUS
MOV XPLANE2,AX
MOV YPLANE2,BX


NO_COLLISION:
RET
CHECK_AIRPLANE_COLLISION ENDP

ARSM_BULLET PROC
 CMP IS_BULLET1_SHOT,1
JE ARSM_BULLET1
JMP CHECK_ON_OTHER_BULLET

    ARSM_BULLET1:
    ;implement drawing of bullet1 here
		MOV AH,0Ch ;set the configuration to writing a pixel
		MOV AL,0Ah ;choose red as color
		MOV CX,XBULLET1 ;set the column (X)
		MOV DX,YBULLET1 ;set the line (Y)
		INT 10h    ;execute the configuration
		

    CHECK_ON_OTHER_BULLET:
    CMP IS_BULLET2_SHOT,1
    JE ARSM_BULLET2
    JMP CONT
    ARSM_BULLET2:
    ;implement drawing of bullet 2 here
    	MOV AH,0Ch ;set the configuration to writing a pixel
		MOV AL,0Fh 
		MOV CX,XBULLET2 ;set the column (X)
		MOV DX,YBULLET2 ;set the line (Y)
		INT 10h    ;execute the configuration

    CONT:;continue
    RET
ARSM_BULLET ENDP

MOVE_BULLET11 PROC

CMP IS_BULLET1_SHOT,1
JE SHOOT_FIRST_BULLET1
JMP CHECK_ONOTHER_BULLET11
SHOOT_FIRST_BULLET1:
push ax
mov ax,XBULLET1
ADD ax,BULLET_VELOCITY
MOV XBULLET1,AX
MOV BX,WINDOW_WIDTH
sub BX,WINDOW_ERROR
CMP XBULLET1,BX
JA STOP10
POP AX
JMP CHECK_ONOTHER_BULLET11
STOP10:
MOV IS_BULLET1_SHOT,0
POP AX

CHECK_ONOTHER_BULLET11:
CMP IS_BULLET2_SHOT,1
JE SHOOT_SECOND_BULLET11
JMP CONT111

SHOOT_SECOND_BULLET11:
PUSH AX
mov ax,XBULLET2
SUB ax,BULLET_VELOCITY
MOV XBULLET2,AX
CMP XBULLET2,00h
JL STOP12
POP AX
JMP CONT111
STOP12:
MOV IS_BULLET2_SHOT,0
POP AX


CONT111:
    RET
MOVE_BULLET11 ENDP 


BULLET_COLLISION PROC
CMP IS_BULLET1_SHOT,1
JE CHECK_ON_BULLET1_COLLISION
JMP CHECK_ON_OTHER_BULLET_COLLISION
;BULLET1 HITS PLANE2
;CHECK ON MINIMUM VALUE OF XPLANE2
CHECK_ON_BULLET1_COLLISION:
MOV BX,XPLANE2
CMP XBULLET1,BX
JAE CHECK_ON_MAX_X
JMP NO_BULLET_COLLISION
CHECK_ON_MAX_X:
ADD BX,20H
CMP XBULLET1,BX
JLE CHECK_ON_MIN_Y
JMP NO_BULLET_COLLISION

CHECK_ON_MIN_Y:
MOV BX,YPLANE2
SUB BX,10H
CMP YBULLET1,BX
JAE CHECK_ON_MAX_Y
JMP NO_BULLET_COLLISION
CHECK_ON_MAX_Y:
MOV BX,YPLANE2
ADD BX,5H
CMP YBULLET1,BX
JLE BULLET_COLLISION_TRUE
JMP NO_BULLET_COLLISION
BULLET_COLLISION_TRUE:
DEC PLANE2_HEALTH
MOV IS_BULLET1_SHOT,0
MOV BX,XPLANE2_PREVIOUS
MOV XPLANE2,BX
MOV BX,YPLANE2_PREVIOUS
MOV YPLANE2,BX

CHECK_ON_OTHER_BULLET_COLLISION:
CMP IS_BULLET2_SHOT,1
JE CHECK_ON_BULLET2_COLLISION
JMP NO_BULLET_COLLISION
CHECK_ON_BULLET2_COLLISION:
;;CHECK ON MIN X 
MOV BX,XPLANE
SUB BX,20H
CMP XBULLET2,BX
JAE CHECK_ON_MAX_X2
JMP NO_BULLET_COLLISION
CHECK_ON_MAX_X2:
MOV BX,XPLANE
CMP XBULLET2,BX
JLE CHECK_ON_MIN_Y2
JMP NO_BULLET_COLLISION
CHECK_ON_MIN_Y2:
MOV BX,YPLANE
SUB BX,10H
CMP YBULLET2,BX
JAE CHECK_ON_MAX_Y2
JMP NO_BULLET_COLLISION
CHECK_ON_MAX_Y2:
MOV BX,YPLANE
ADD BX,5H
CMP YBULLET2,BX
JLE BULLET_COLLISION_TRUE1
JMP NO_BULLET_COLLISION
BULLET_COLLISION_TRUE1:
DEC PLANE_HEALTH
MOV IS_BULLET2_SHOT,0
MOV BX,XPLANE_PREVIOUS
MOV XPLANE,BX
MOV BX,YPLANE_PREVIOUS
MOV YPLANE,BX

NO_BULLET_COLLISION:
RET
BULLET_COLLISION ENDP 

RESET_GAME PROC
;RESET HEALTH FOR BOTH PLAYERS
MOV PLANE_HEALTH,5H
MOV PLANE2_HEALTH,5H
MOV IS_PLANE1_FROZEN,0
MOV IS_PLANE2_FROZEN,0
MOV FIRST_SECOND_READ,1
;RESET TO INTIAL SPAWN POSITION FOR BOTH PLAYERS
;PLANE1
PUSH AX ;SAVE LAST VALUE OF OF AX IN STACK
MOV AX,XPLANE_PREVIOUS
MOV XPLANE,AX
MOV AX,YPLANE_PREVIOUS
MOV YPLANE,AX
;PLANE2
MOV AX,XPLANE2_PREVIOUS
MOV XPLANE2,AX
MOV AX, YPLANE2_PREVIOUS
MOV YPLANE2,AX
POP AX ;POP THE LAST VALUE PUSHED IN THE STACKK TO AX 

RET 
RESET_GAME ENDP 


DRAW_POWER_UPS PROC
 ;CHECK WHAT KIND OF POWERUP TO DRAW   
CMP POWERUP_TYPE,1
JE DRAW_FREEZE_POWERUP
CMP POWERUP_TYPE,2
JE DRAW_EXTRA_HEART
DRAW_FREEZE_POWERUP:
PUSH AX
;DRAW SYMBOL OF ICE
MOV AH,0CH
    MOV AL,09H
    MOV CX,XPOWERUPS
    MOV DX,YPOWERUPS
    INT 10H
    
    LOOP70:
    DEC DX
    INT 10H
    CMP DX,75H
    JNE LOOP70
    
    MOV DX,YPOWERUPS
    LOOP71: 
    INC DX
    INT 10H
    CMP DX,88H
    JNE LOOP71
     
    MOV DX,YPOWERUPS 
    LOOP72:
    INC CX
    INT 10H
    CMP CX,88H
    JNE LOOP72 
    
    MOV CX,XPOWERUPS
    LOOP73:
    DEC CX
    INT 10H
    CMP CX,75H
    JNE LOOP73
    
    MOV CX,XPOWERUPS
    LOOP74:
    INC CX
    DEC DX
    INT 10H
    CMP CX,88H
    JNE LOOP74    
    
    MOV CX,XPOWERUPS  
    MOV DX,YPOWERUPS
    LOOP75:
    DEC CX
    INC DX
    INT 10H
    CMP DX,88H
    JNE LOOP75   
      
    MOV CX,XPOWERUPS 
    MOV DX,YPOWERUPS
    LOOP76:
    DEC CX
    DEC DX
    INT 10H
    CMP DX,77H
    JNE LOOP76  
    
    MOV CX,XPOWERUPS  
    MOV DX,YPOWERUPS
    LOOP77:
    INC CX
    INC DX
    INT 10H
    CMP DX,88H
    JNE LOOP77 
POP AX
JMP CONTINUE12

DRAW_EXTRA_HEART:
PUSH AX
MOV AH,0CH
MOV AL,04H
MOV CX,XPOWERUPS
MOV DX,YPOWERUPS
INT 10H
LOOP80:
INC CX
INT 10H
CMP CX,83H
JNE LOOP80


LOOP81:
INC CX
DEC DX
INT 10H
CMP CX,86H
JNE LOOP81

LOOP82:
INC CX
INC DX
INT 10H
CMP CX,89H
JNE LOOP82  

LOOP83:
INC DX
INT 10H
CMP DX,83H
JNE LOOP83 

LOOP84:
DEC CX
INC DX
INT 10H
CMP CX,86H
JNE LOOP84 

LOOP85:
DEC CX
INT 10H
CMP CX,82H
JNE LOOP85

;OTHER HALF OF THE HEART
MOV CX,XPOWERUPS
MOV DX,YPOWERUPS
LOOP86:
DEC CX
INT 10H
CMP CX,7DH
JNE LOOP86 

LOOP87:
DEC CX
DEC DX
INT 10H
CMP CX,7AH
JNE LOOP87 

LOOP88:
DEC CX
INC DX
INT 10H
CMP CX,77H
JNE LOOP88 

LOOP89:
INC DX
INT 10H
CMP DX,83H
JNE LOOP89 

LOOP90:
INC CX
INC DX
INT 10H
CMP DX,86H
JNE LOOP90  

LOOP91: 
INC CX
INT 10H
CMP CX,81H
JNE LOOP91
POP AX


CONTINUE12:
RET
DRAW_POWER_UPS ENDP 

POWERUPS_COLLISION PROC
CMP POWERUP_APPEARED,1
JE YES_CHECK_POWERUP_COLLISION
JMP NO_COLLISION_P
 
YES_CHECK_POWERUP_COLLISION:
;CHECK ON MAX X 
MOV BX, XPLANE
CMP BX,XPOWERUPS
JAE CHECK_ON_MIN_XP
JMP CHECK_POWERUP_COLLISION_SECONDPLANE
CHECK_ON_MIN_XP:
MOV BX,XPLANE
SUB BX,20h
CMP BX,XPOWERUPS
JLE CHECK_ON_MAX_YP
JMP CHECK_POWERUP_COLLISION_SECONDPLANE
CHECK_ON_MAX_YP:
MOV BX,YPLANE
ADD BX,5
CMP BX,YPOWERUPS
JAE CHECK_ON_MIN_YP
JMP CHECK_POWERUP_COLLISION_SECONDPLANE
CHECK_ON_MIN_YP:
MOV BX,YPLANE
SUB BX,10
CMP BX,YPOWERUPS
JLE COLLISON_P
JMP CHECK_POWERUP_COLLISION_SECONDPLANE
COLLISON_P:
MOV POWERUP_APPEARED,0
MOV FIRST_SECOND_READ,1
CMP POWERUP_TYPE,1
JE FREEZE_PLANE2
CMP POWERUP_TYPE,2
JE EXTRA_HEART_FOR_PLANE1
;ADD REST OF POWERUPS HERE IN CASE PLANE 1 TAKE THEM
JMP NO_COLLISION_P
FREEZE_PLANE2:
MOV IS_PLANE2_FROZEN,1
MOV POWERUP_TYPE,2
JMP NO_COLLISION_P
EXTRA_HEART_FOR_PLANE1:
INC PLANE_HEALTH
MOV POWERUP_TYPE,1
JMP NO_COLLISION_P


CHECK_POWERUP_COLLISION_SECONDPLANE:
;CHECK ON DIMENSIONS FOR PLANE2 
;CHECK ON MAX X 
MOV BX, XPLANE2
ADD BX,20H
CMP BX,XPOWERUPS
JAE CHECK_ON_MIN_XP2
JMP NO_COLLISION_P
CHECK_ON_MIN_XP2:
MOV BX, XPLANE2
CMP BX,XPOWERUPS
JLE CHECK_ON_MAX_YP2
JMP NO_COLLISION_P
CHECK_ON_MAX_YP2:
MOV BX,YPLANE2
ADD BX,5
CMP BX,YPOWERUPS
JAE CHECK_ON_MIN_YP2
JMP NO_COLLISION_P
CHECK_ON_MIN_YP2:
MOV BX,YPLANE2
SUB BX,10
CMP BX,YPOWERUPS
JLE COLLISON_P2
JMP NO_COLLISION_P

COLLISON_P2:
MOV POWERUP_APPEARED,0
MOV FIRST_SECOND_READ,1
CMP POWERUP_TYPE,1
JE FREEZE_PLANE1
CMP POWERUP_TYPE,2
JE EXTRA_HEART_FOR_PLANE2
;ADD REST OF POWERUPS HERE IN CASE PLANE 1 TAKE THEM
JMP NO_COLLISION_P
FREEZE_PLANE1:
MOV IS_PLANE1_FROZEN,1
MOV POWERUP_TYPE,2
JMP NO_COLLISION_P
EXTRA_HEART_FOR_PLANE2:
INC PLANE2_HEALTH
MOV POWERUP_TYPE,1


NO_COLLISION_P:
RET
POWERUPS_COLLISION ENDP
end main    