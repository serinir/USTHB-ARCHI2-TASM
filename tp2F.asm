DATA SEGMENT
	MESSAGE   db "ARCHI2",10,13,"$"
	effect 	  db "Appuyer sur une touche pour effectuer l'operation de soustraction",10,13,"$" 	
	message_quite db "Taper sur une touche pour quitter:$"
	message_TP db "TP02:$"
	Message_resto db "OPERATION DE RESTAURATION DU VECTEUR 4 EST TERMINEE$"
	MESSAGE_1 db "DEROUTEMENT DE L'INTERRUPTION OVERFLOW",10,13,"LE PROCESSEUR SIGNALE UN ETAT D'OVERFLOW,Appuyer une touche pour continuer",10,13,"$"
	MESSAGE_2 db "OPERATION EFFECTUEE SANS ERREUR D'OVERFLOW",10,13,"$"
	ancien_cs dw ? 
	ancien_ip dw ?
	x dw 0000H
	y dw 0000H 	; 8000H mettre la valeur de Y à 8000H pour avoir une erreur overflow	
	col db 70
	lig db 0
DATA ENDS

PILE SEGMENT STACK
	dw  128 dup(?)
	TOS LABEL WORD
PILE ENDS

CODE SEGMENT
	ASSUME CS:CODE,DS:DATA,SS:PILE
	; ******** PROCEDURES DEMANDEES OBLIGATOIRES ********
	
	OUTPUT PROC FAR    ; **affiche une chaine de caractères (option ah=09 de int 21h) dont l'offset est passé en parametre via La pile ** 
	
		MOV BP,SP  		; on recupere le SP dans BP 
		PUSH AX
		PUSH BX
		MOV DX,[BP+4]    ; vu que c'est une procedure far (le cs et ip sont empilés) on recupere notre parametre à l'adresse BP+4
			
		call CENTER
		MOV AH,09H 
		INT 21H
		
		POP BX   ; on sauvgarde AX ET BX et on les restaure apres la fin de la procedure pour pas toucher le programme appelant
		POP AX
		RET 2
	OUTPUT ENDP
	
	OVERFLOW PROC FAR   			; ** Code de l'interuption vers la quelle on va derouter INT 04H **
            ; Elle ne fait qu'afficher le message_1 et attend que l'utilisateur appuie sur une touche pour terminer
			CALL CENTER
			PUSH OFFSET MESSAGE_1
			CALL OUTPUT
			CALL PRESS_BUTTON
			
		IRET 
	OVERFLOW ENDP

	NOVERFLOW PROC FAR
		
		JO Done                    ; si il y'a overflow on Jump vers l'etiquette 'Done' et on affiche rien 
		PUSH OFFSET MESSAGE_2      ; Sinon on Affiche le message_2
		CALL OUTPUT
Done:
		RET 
	NOVERFLOW ENDP


	READ_SAVE PROC
		PUSH AX
		PUSH ES
		PUSH BX

		MOV AX,3504H    ; Lecture du vecteur IT 04  via le parametre AH=35 de l'interruption int 21H
		INT 21H
		MOV AX,ES
		                 
		MOV ancien_cs,AX     ; Sauvgarde du cs et ip de l'IT 04H 
		MOV ancien_ip,BX

		POP BX
		POP ES
		POP AX
		RET
	READ_SAVE ENDP

	INSTALL PROC    ;** installation d'un vecteur dans l'interruption 04h via le parametre AH = 25 de l'interuption int 21h **
		
		PUSH AX
		PUSH DS

		PUSH CS
		POP DS
		MOV DX, OFFSET OVERFLOW; on met l'offset de l'interruption qu'on a créée 
		MOV AX,2504H
		INT 21H	
		
		POP DS ; On remet l'ancienne valeur de DS (sinon on ne peut pas utiliser nos données declarées dans data)
		POP AX
		RET
	INSTALL ENDP

	SUBSTRACTION PROC 
		
		MOV lig,8	
		MOV COL,0
		PUSH OFFSET effect
		CALL OUTPUT
		call PRESS_BUTTON

		; les parametres sont passés par la pile
		MOV  BP,SP   ; MOV BP , SP pour pouvoir acceder à la pile de maniere directe
		PUSH AX      ; on sauvgarde la valeur de ax et bx avant de commencer
		PUSH BX 

		MOV AX,[BP+2]   ; on retrouve donc nos parametres Y à [BP + 2] et X à [BP + 4]
		SUB AX,[BP+4]  ; on fait la soustraction et push le resultat dans la pile 
		MOV lig,11
		MOV COL,0
		CALL NOVERFLOW 	; Si il n y'a pas d'overflow , la procedure NoverFlow va afficher le message_2
		INTO			; SINON INTO va executer la routine d'interruption 		
		JNO NOV
		CALL RESTORATION
	NOV:
		
		MOV DX,AX 		; on retourne le resultat de la substraction dans DX 
		                ; ax et bx sont remis à leur ancienne valeur
		POP BX
		POP AX
		RET 4
	SUBSTRACTION ENDP

	RESTORATION PROC NEAR
		
		PUSH DX       ; on sauvgarde DX et DS pour les restaurer a la fin de la procedure
		PUSH DS

		MOV AX,ancien_cs ; on utilise l'option ah=25 de int 21h pour installer le vecteur qu'on avait sauvgardé dans ancien_cs:ancien_ip
	
		MOV DS,AX
		MOV DX,ancien_ip
		MOV AX,2504H
		INT 21H

		POP DS
		POP DX

		MOV LIG,13
		MOV COL,0
		push OFFSET Message_resto
		CALL OUTPUT
		RET 
	RESTORATION endp

	; ********  PROCEDURES SUPPLEMENTAIRES ********
	CENTER PROC 
		PUSH AX
		PUSH BX
		PUSH DX
		; mettre le curseur a la ligne 'lig' et colonne 'col' grace au parametre ah=02H de l'interruption 10H
		MOV AH,02H
		MOV BH,0
		MOV DH,lig
		MOV DL,col
		INT 10H

		POP DX
		POP BX
		POP AX
		RET
		
	CENTER ENDP
	
	PRESS_BUTTON PROC NEAR
		; on attend que l'utilisateur appuis sur un touche grace au pramatre AX= 08H De l'interruption INT 21H
		MOV AH,08H
		INT 21H
	
		RET
	PRESS_BUTTON ENDP
	
	CLRSCREEN PROC
		PUSH AX
		 ; clear screen grace a l'interuption 10H
		MOV AX,3 
    	INT 10H 
		
		POP AX
		RET
	CLRSCREEN ENDP
	HEAD PROC NEAR	
		PUSH OFFSET MESSAGE
		CALL OUTPUT
		MOV lig,3
		MOV COL,35
		PUSH OFFSET message_TP
		CALL OUTPUT
		RET
	HEAD ENDP

	quite proc NEAR
		MOV LIG,20
		MOV COL,35
		PUSH OFFSET message_quite
		CALL OUTPUT
		CALL PRESS_BUTTON
		RET
	quite ENDP
START:
	; Declaration des segements
	MOV AX,DATA
	MOV DS,AX
	CALL CLRSCREEN
	CALL READ_SAVE; on reccupere le cs et l'ip de INT 04H dans ancient_cs et ancien_ip
	CALL INSTALL  ; on installe notre procedure 
	
	CALL HEAD
	; on push nos parametres pour la procedure SUBSTRACTION	
	PUSH x
	PUSH Y
	CALL SUBSTRACTION  ; appel de la procedure SUBSTRACTION pour tester 
	; QUITE
	CALL QUITE
	MOV AX,4C00H
	INT 21H

CODE ENDS 
	END START