data segment
	message  db "salam brother",10,13,"$"
	ch1 db "ayah lela mat9oulich hedi la 1ch yeeeh",10,13,"$"
data ends
my_stack segment stack "stack"
		dw 128 dup(?)
		TOP label word
my_stack ends
code segment
	assume cs: code, ds: data, es: extra, ss: my_stack
output proc near
		mov ah,09
		int 21h
		ret 
output endp
deroute proc near
		cmp bl,32h
		Jl noaffi
		push dx
		mov dx,offset ch1 
		call output
		mov bl,0H
		pop dx
noaffi: iret
deroute endp
instalation proc near
		push ds
		mov ax,cs
		mov ds,ax
		mov dx,offset deroute
		mov ax,251CH
		int 21H
		pop ds
		ret
instalation endp
start:
		MOV AX, data
		MOV DS,AX
		MOV AX ,my_stack
		MOV SS,AX
		MOV SP,TOP
		call instalation
		MOV AX,3 
    	INT 10H ; clear screen grace a l'interuption 10H
		mov bl,0
loopa: 	mov dx,offset message ; la loop mena melhih ak ta3ref	
		call output	
		mov cx,03C0H
lap:	inc bl
		mov ax,3d09H
sghira:	dec ax
		jnz sghira
		loop lap
		jmp loopa	
		mov dx,offset message
		call output
code ends
		end start