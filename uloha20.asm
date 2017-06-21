;autor: Matus Olejnik

extrn SUBOR:byte


ZAS SEGMENT stack
	DB	256 dup(?)
ZAS ENDS

DATA SEGMENT public
DATA ENDS

DATA SEGMENT 

Ent			DB 10,13,'$'
ziadny_s	DB 10,13,'Ziadny subor nenajdeny$'

prve	DB '0$'
druhe	DB '0$'
tretie 	DB '0$'
stvrte 	DB '0$'
piate 	DB '0$'

zaciatok DB '0$'

H			DW 0
pocetRiadkov db 10,13,'Pocet riadkov: $'
STRINGL		EQU 1024 
STRING     	DB STRINGL + 1  DUP(?)  ; retazec na citanie

DATA ENDS


CODE SEGMENT public 

ASSUME CS:CODE, DS:DATA, SS:ZAS
JUMPS
include macr.txt

uloha20	proc
		
		MOV AX, SEG DATA
		MOV DS, AX
		MOV ES, AX
		MOV AX, 0003					; vycistenie obrazovky
		INT 10H
		vypis Ent
		MOV prve, 30h
		MOV druhe, 30h
		MOV tretie, 30h
		MOV stvrte, 30h
		MOV piate, 30h
		MOV AH,3DH                     	; otvorenie suboru
        MOV AL,0                       	; citanie 
        MOV DX,OFFSET SUBOR
        INT 21H                        	; prerusenie
		JC POM2                   		; nenajdeny subor
		MOV H,AX                       	; ax sa ulozi do h  
		MOV zaciatok, 31h				;premena ktora znaci ci pred velkym pismenom bola medzera, tabulator alebo zaciatok riadka
		JMP CITANIE

POM2:		 
		JMP NENAJDENY	

CITANIE:
		MOV AH, 3FH						; citanie suboru
		MOV DX,OFFSET STRING           	; bude sa nacitavat do retazca String
        MOV CX,STRINGL                 	; 
        MOV BX,H                      	; do bx sa ulozi handler aktualneho suboru
		INT 21H							; prerusenie
		CMP AX, 0						; kontrola ci bol nacitany znak/koniec suboru
		JZ EN							; koniec suboru skoc na koniec
		MOV CX,AX						; do CX ulozi kolko Bytov nacitalo
		MOV SI,OFFSET STRING			; do SI ulozi adresu odkial ma zacat porovavat znaky
		MOV di, cx						;do di sa ulozi tiez pocet nacitanych Bytov a bude pouzite ako pocitadlo pre cyklus na vypisovanie riadka
		JMP ZAC							; cyklus na porovnanie znakov

ZAC:	 
		MOV zaciatok, 31h				;do premenej zaciatok nastavime 1 ako znak ze sme na zaciatku riadka a teda ak bude nasledujuce pismeno velke mozme vypisat vetu
		MOV es, si						;do ES sa ulozi zaciatok riadka
		MOV di, cx
		
DALSI0:	
		CMP CX,0						; ak uz boli prejdene vsetky znaky
		JZ CITANIE ;EN					;skoci do EN kde vypise riadky a skonci
		MOV DL,[SI]						; do DL uzlozi jeden z nacitanych znakov
		CMP DL, 40h 					; (@ pred A) ak je nacitany znak >= ako ascii hodnota A 
		JG DALSI 						; skoc na DALSI
		JL RESET 						; inak skoc na RESET 

DALSI: 
		CMP DL, 5Bh 					; ([ za Z) ak je nacitany znak <= ako asii hodnota Z 
		JL DALSI3						;skoc na DALSI3
		JG RESET						;inak skoc na RESET

DALSI3: 
		CMP zaciatok, 31h 				;ak je nacitany znak velke pismeno pozri do pomocnej premenej zaciatok ci je v nej hodnota 1 aby sa zistilo ci sa velkym pismenom zacina slovo
		JZ DALSI2 						;ak je to zaciatok slova skoc na DALSI2
		JNZ DALSI1 						;inak skoc na DALSI1

RESET: 	CMP dl, 0Ah						;ak je znak novy riadok 
		JZ POSUN2						;skoc na navestie POSUN2
		CMP dl, ' '						;ak je znak medzera
		JNZ RESET2
		
		MOV zaciatok, 31h				;nastav premenu zaciatok na 1 ci znaci ze nasledujuci znak moze byt zaciatok slova 
		JMP DALSI1

RESET2: 
		CMP dl, 0Bh						;alebo tabulator
		JNZ NASTAV
		MOV zaciatok, 31h				;nastav premenu zaciatok na 1 ci znaci ze nasledujuci znak moze byt zaciatok slova 
		JMP DALSI1

NASTAV:	
		MOV zaciatok, 30h				;nastav premenu na 0 ako znak ze nasledujuci znak nebude zaciatok slova
		JMP DALSI1

DALSI1:
		INC si							;zvacsenie SI aby sa preslo na dalsi znak
		DEC cx 							;zmensenie CX pre cyklus
		JMP DALSI0

POSUN2:
		INC si
		DEC cx							; ak je novy riadok posuniem sa na prve pismeno v dalsiom riadku
		MOV es, si						; do es sa ulozi zaciatok riadka
		MOV di, cx 						; do di sa ulozi aktualne cislo cyklu aby ked sa najde riadok na vypisanie tak aby sa zacal cyklus na vypisovanie na spravnom offsete
		MOV dl, [si] 					;do dl sa ulozi nacitany znak
		JMP ZAC

;POSUN:
;		INC si 
;		DEC cx 
;		MOV dl, [si]
;		CMP DL, 40h
;		JG DALSI

DALSI2:	
		MOV si, es						;do si uloz hodnotu s poziciou zaciatku riadka
		MOV cx, di						;do cx sa ulozi pomocna hodnota pre cyklus pri vypisovani
		MOV dl, [si]					;do dl vloz znak na vypisanie
		JMP PRIPOCITAJ 

DALSI4:	
		vypisznak
		CMP DL, 0Ah						;ak je znak novy riadok
		JZ NOVY_RIADOK					;skoc na NOVY_RIADOK
		CMP CX,0						; ak uz boli prejdene vsetky znaky
		JZ NIC
		INC SI							; posuniem sa o adresu dalej
		DEC CX							;znizim CX pre cyklus
		MOV DL,[SI]						; do DL uzlozi jeden z nacitanych znakov
		CMP CX,0						; ak uz boli prejdene vsetky znaky
		JZ NIC							;skoc na NIC
		JMP DALSI4 						;inak pokracuj vo vypisovani

NOVY_RIADOK:		
		INC si
		DEC cx
		MOV es, si						;do es uloz novy poziciu riadku
		MOV dl,[si]
		JMP ZAC
		
PRIPOCITAJ:
		CMP prve, '9'
		JZ RDESIAT						; inkrementovanie premennych
		INC prve
		JMP DALSI4
		 
RDESIAT:
		MOV prve, 30h
		CMP druhe, '9'
		JZ RSTOVKY
		INC druhe
		JMP DALSI4

RSTOVKY:
		MOV druhe, 30h
		CMP tretie, '9'
		JZ RTISICKY
		INC tretie
		JMP DALSI4
		 
RTISICKY:
		MOV druhe, 30h
		CMP stvrte,'9'
		JZ RDESATTISICKY
		INC stvrte
		JMP DALSI4

RDESATTISICKY:
		MOV stvrte, 30h
		INC piate 
		JMP DALSI4

NENAJDENY: 
		vypis ziadny_s
		JMP EN
			
NIC:
		JMP CITANIE
	 
EN:	 
		vypis pocetRiadkov
		JMP VYP

V1:
		vypis piate

V2:	 	
		vypis stvrte

V3:	 	
		vypis tretie

V4:	 	
		vypis druhe						

V5:	 	
		vypis prve
		JMP ENDKON

VYP: 	
		CMP piate, '0'
		JZ S1
		JNZ V1

S1:		
		CMP stvrte, '0'
		JZ S2
		JNZ V2

S2:		
		CMP tretie, '0'
		JZ S3
		JNZ V3

S3:		
		CMP druhe, '0'
		JZ V5
		JNZ V4

ENDKON:	
		ret
		endp	 

CODE 	ENDS
	
		public uloha20
		END
