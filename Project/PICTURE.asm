.model small 
.stack 64
.data
.code       
Airplane_Width EQU 25
Airplane_Height EQU 25  

Airplane_FileName DB 'Airplane.bin',0  
Airplane_FileHandle DW ?  
Airplane_Data DB Airplane_Width*Airplane_Height DUP(0)
 



main proc far   
    mov ax,@data
    mov ds,ax 
    
    MOV AH, 0
    MOV AL, 13h
    INT 10h   
    
    CALL OpenFile
    CALL ReadData    
    
    LEA BX , Airplane_Data ; BL contains index at the current drawn pixel   
    
    MOV CX,0
    MOV DX,0
    MOV AH,0ch
    
    
    ; Drawing loop
DrawLoop:
    MOV AL,[BX]
    INT 10h 
    INC CX
    INC BX
    CMP CX,Airplane_Width
JNE DrawLoop 
	
    MOV CX , 0
    INC DX
    CMP DX , Airplane_Height
JNE DrawLoop 

 ; Press any key to exit
    MOV AH , 0
    INT 16h
    
    call CloseFile
    
    ;Change to Text MODE
    MOV AH,0          
    MOV AL,03h
    INT 10h 

    ; return control to operating system
    MOV AH , 4ch
    INT 21H
    
    
    
    
    main endp 


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
end main