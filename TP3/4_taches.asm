data segment
	prog1 db "Tache1 en cours d'execution...",10,13,"$"
	prog2 db "Tache2 en cours d'execution...",10,13,"$"
	prog3 db "Tache3 en cours d'execution...",10,13,"$"
	prog4 db "Tache4 en cours d'execution...",10,13,10,13,"$"
	INSTALLED db "Deroutement fait",10,13,10,13,"$"
data ends


code segment
	assume cs: code, ds: data
	instalation proc near
		push ds
		mov ax,cs
		mov ds,ax
		mov dx,offset deroute
		mov ax,251CH
		int 21H
		pop ds
		mov dx,offset INSTALLED
		mov ah,09h
		int 21h
		ret
instalation endp
PRO1 proc near
	
	mov dx,offset PROG1
	mov ah,09h
	int 21h
	ret
PRO1 endp
PRO2 proc near
	
	mov dx,offset PROG2
	mov ah,09h
	int 21h
	ret
PRO2 endp
PRO3 proc near
	
	mov dx,offset PROG3
	mov ah,09h
	int 21h
	ret
PRO3 endp
PRO4 proc near
	
	mov dx,offset PROG4
	mov ah,09h
	int 21h
	ret
PRO4 endp

deroute proc near
un:		cmp bl,0H
		jne deux	
			cmp bh,1
			jnge zero
			inc bl
			call PRO1
deux: 	
		cmp bl,1H
		jne trois
			cmp bh,2
			jnge zero
			inc bl
			call PRO2
trois:	cmp bl,2H
		jne quatre
			cmp bh,3H
			jnge zero
			inc bl
			call PRO3
quatre: cmp bl,3H
		jne zero
			cmp bh,4H
			jnge zero
			mov bl,0
			mov bh,0
			call PRO4
zero:	iret
		
deroute endp
start:
mov ax,data
mov ds,ax
	

mov bl,0H
mov bh,1h
MOV AX,3 
INT 10H ; clear screen grace a l'interuption 10H
call instalation
infinie_et_au_dela:	
			

		  	mov ax,7a12H
la_bas:		mov cx ,140H
ici:	  	loop ici
		  	dec ax
		 	jnz la_bas
		 	inc bh
			jmp infinie_et_au_dela
code ends
	end start