data segment
	message  db 10,13,"**** Programme principal en cours **** $"
	ch1 db "oh la 1ch!... $"
data ends
my_stack segment stack "stack"
		dw 128 dup(?)
		TOP label word
my_stack ends
code segment
	assume cs: code, ds: data,ss: my_stack
output proc near
		mov ah,09
		int 21h
		ret 
output endp
deroute proc near
		cmp bl,3Dh
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
loopa: 	mov dx,offset message ; la loop kda mena melhih ak ta3ref	
		call output	
		mov cx,3C0H
lap:	
		inc bl
		mov ax,3d09H
sghira:	dec ax
		jnz sghira
		loop lap
		jmp loopa	

code ends
		end start
