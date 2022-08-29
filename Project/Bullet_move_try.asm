.model SMALL 

.stack 64
.data
BULLET_DIRECTION DW 73H
BULLET_VEL DW 7H

.code 
main proc far
mov ax,@data
mov ds,AX
MOV AH,0
MOV AL,13h
INT 10H
MOV AH,0CH
MOV AL,0Fh
mov cx,0aH
MOV DX,0AH
INT 10h
MOV BX,10H
LOOP1:
MOV AH,0
MOV AL,13h
INT 10H

MOV AH,0CH
MOV AL,0Fh
ADD DX,BULLET_VEL
INT 10h
CMP BX,0
JNE LOOP1








main endp 
end main