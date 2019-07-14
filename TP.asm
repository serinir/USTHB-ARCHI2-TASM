data segment
    MESSAGE db 10,13,"Hi im imad$"
data ends

code segment
  af proc
        MOV AH,09H
	    mov DX,offset MESSAGE
	    int 21h
        ret 
    af endp
    
start:
    assume cs:code,ds:data
    mov ax,data
    mov ds,ax
   call af
    int 04h
  
 
    mov ax,4c00h
    int 21h
code ends
    end start
  