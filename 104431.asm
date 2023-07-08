;Se dispone de una matriz M en memoria de 15x15 en la que cada elemento (i,j) es un BPF c/signo de 1 byte y 
;de un archivo SUBMAT.DAT que contiene información para obtener submatrices de dimensiones n x m (no necesariamente 
;cuadradas) dentro de la matriz M.  
;Cada registro del archivo cuenta con los siguientes campos:
;●  Binario de punto fijo de 1 byte para indicar un nro. de fila (F) correspondiente al vértice superior 
;   izquierdo de la submatriz
;●  Binario de punto fijo de 1 byte para indicar un nro. de columna (C) correspondiente al mismo vértice
;●  Binario de punto fijo de 1 byte para indicar el valor de n (cantidad de filas de la submatriz)
;●  Binario de punto fijo de 1 byte para indicar el valor de m (cantidad de columnas de la submatriz)

;Se pide codificar un programa en assembler de Intel 8086 que realice lo siguiente:
;1- Lea cada registro del archivo y lo valide mediante el uso de una rutina interna llamada VALREG.  
;   Deberá validar los 4 campos y que la submatriz quede dentro de los límites de M
;2- Calcule la sumatoria de los elementos de la última columna de cada sumbatriz (la columna de mas a 
;   la derecha) muestre por pantalla la mayor de las sumatorias calculadas.

global	main
extern  puts 
extern  printf
extern  fopen
extern  fclose
extern  fread

section	.data
    fileName        db  "SUBMAT.dat",0
    modo            db  "rb",0
    msjErrorOpen	db	"Error apertura de archivo.",0,10

    ;matriz	times 450 dw 0			

    matriz  dw  1,1,1,1,1,1,1,1,1,1,1,1,1,1,5
            dw  1,1,2,1,1,1,1,1,1,1,1,4,1,1,5
            dw  1,1,1,1,1,1,1,1,1,1,1,4,1,1,5
            dw  1,1,1,1,1,1,1,1,1,1,1,4,1,1,5
			dw  1,1,1,1,2,1,1,1,8,1,1,4,1,1,5
			dw  1,1,1,1,1,1,1,1,9,1,1,5,1,1,5
			dw  1,1,1,1,1,1,1,1,1,1,1,1,1,1,5
			dw  1,1,1,1,1,1,1,1,1,1,1,1,1,1,5
			dw  1,1,1,1,1,1,1,1,1,1,1,1,1,1,5
			dw  1,1,1,1,1,1,1,1,1,1,1,1,1,1,5
			dw  1,1,1,1,1,1,1,1,1,1,1,1,1,1,5
			dw  1,1,1,1,1,1,1,1,1,1,1,1,1,1,5
			dw  1,1,1,1,1,1,1,1,1,1,1,1,1,1,5
			dw  1,1,1,1,1,1,1,1,1,1,1,1,1,1,5
			dw  1,1,1,100,1,1,1,1,1,1,1,1,1,1,5

    regArchivo         times 0     db ""
        nroFila        times 1     db ""
        nroColumna     times 1     db ""
        valorN	       times 1     db ""
		valorM	       times 1     db ""
	
	sumatoria          dd   0
	msjSumaMax		   db "La sumatoria maxima de la ultima columna de las submatrices es: %i",10,0


section	.bss
    registro		resw	30
	idArchivo       resq    1
    registroValido  resb    1

    fila			resw	1
	columna			resw	1
	cantFila		resw	1
	cantCol			resw	1

    desplaz         resw    1
	maxSuma         resd    1


section	.text
main:
    call	aperturaArchivo
	cmp		byte[registroValido],'n'
	je		finProg

	call	procesarRegistro

	call	cierreArchivo

	call    imprimirMayorSuma
finProg:
ret

;-------------------------
;APERTURA ARCHIVO
;-------------------------
aperturaArchivo:
	mov		byte[registroValido],'n'

	mov		rcx,fileName
	mov		rdx,modo
	sub		rsp,32
	call	fopen
	add		rsp,32

	cmp		rax,0
	jle		errorOpen
	mov		qword[idArchivo],rax

    mov		byte[registroValido],'s'
	jmp		openValido

errorOpen:
	mov		rcx,msjErrorOpen
	sub		rsp,32
	call	puts
	add		rsp,32
openValido:
ret

;***************************************************************

;-------------------------
;CIERRE ARCHIVO
;-------------------------
cierreArchivo:
	mov		rcx,[idArchivo]
	sub		rsp,32
	call	fclose
	add		rsp,32
ret

;***************************************************************

;-------------------------
;PROCESAR REGISTRO
;-------------------------
procesarRegistro:

leerSiguiente:
sub rdx,rdx
    mov		rcx,regArchivo		;registro entrada
	mov		rdx,4				;longitud registro
	mov		r8,1
	mov		r9,[idArchivo]		;idArchivo
	sub		rsp,32
	call	fread
	add		rsp,32

	cmp		rax,0
	jle		finLectura

    call    VALREG				;se validan los registros
    cmp		byte[registroValido],'n'
    je		leerSiguiente

	call    calcularSumaCol		;se calcula la sumatoria de la ultima columna de cada submatriz valida

	sub     rbx,rbx
    mov     ebx,[sumatoria]
    cmp     ebx,[maxSuma]       ;comparo la ultima submatriz sumada con la maxima suma
    jle     leerSiguiente       ;si es menor o igual, leo el siguiente registro sin modificar la maxima

    mov     ebx,[sumatoria]     ;si es mayor, me guardo el nuevo maximo
    mov     [maxSuma],ebx

	jmp     leerSiguiente
finLectura:
ret

;***************************************************************

;-------------------------
;VALIDACION DE REGISTROS
;-------------------------
VALREG:
	mov		byte[registroValido],'n'

	sub		rcx,rcx
    sub		rbx,rbx

    mov		cl,byte[nroFila]
	mov		word[fila],cx

    mov		cl,byte[nroFila+1]	;MOD nroFila+3 por nroColumna
	mov		word[columna],cx	

    mov		cl,byte[nroFila+2]	;MOD nroFila+2 por valorN
	mov		word[cantFila],cx

	mov		cl,byte[nroFila+3]	;MOD nroFila+3 por valorM
	mov		word[cantCol],cx

;valido que el rango de la fila este entre 1 y 15
    cmp		word[fila],1
	jl		finValidarRegistro
	cmp		word[fila],15
	jg		finValidarRegistro

;valido que el rango de la columna este entre 1 y 15
    cmp		word[columna],1
	jl		finValidarRegistro
	cmp		word[columna],15
	jg		finValidarRegistro

;valido que la cantidad de filas de la submatriz se encuentre dentro del limite de la matriz
;para esto digo que N <= 16 - FILA
	sub		rbx,rbx
    mov     bx,15
	inc		bx

	sub     bx,word[fila]   ;bx = 15-fila (valor max de filas que puede tener la submatriz)
    cmp     bx,word[cantFila]
    jnge    finValidarRegistro  ;si la cantidad de filas de la submat es mayor al maximo permitido, no es valida

;valido que la cantidad de filas de la submatriz se encuentre dentro del limite de la matriz
;para esto digo que M <= 16 - COLUMNA
	sub		rbx,rbx
    mov     bx,15
	inc		bx

	sub     bx,word[columna]   ;bx = 15-columna (valor max de filas que puede tener la submatriz)
    cmp     bx,word[cantCol]
    jnge    finValidarRegistro  ;si la cantidad de columnas de la submat es mayor al maximo permitido, no es valida

    mov		byte[registroValido],'s'    ;si llega hasta acá quiere decir que el registro es valido
finValidarRegistro:
ret

;***************************************************************

;-------------------------
;CALCULAR SUMA ULTIMA COLUMNA
;-------------------------
calcularSumaCol:
	call calcularDespl  ;me ubico en la coordenada inicial (arriba a la izq) de la submatriz
	
	sub     rax,rax
    mov     [sumatoria],eax

    sub     rsi,rsi
    sub     rdi,rdi    
    sub     rcx,rcx

;me ubico en la primer coordenada a sumar (columna de mas a la derecha de la submatriz)
	mov 	bx,word[cantCol]
	sub 	bx,1
	imul 	bx,2
	add 	bx,word[desplaz]

	mov     cx,word[cantFila]  ;se define la cantidad de veces que va a iterar el loop
sumarSgte:
    push    rcx     ;me guardo el nro de iteraciones del loop

	mov		ax,word[matriz+rbx]
	add     [sumatoria],eax

	add 	bx,30    ;me posiciono en el valor siguiente a sumar
	
	pop     rcx             ;recupero el nro de iteraciones del loop 
    loop	sumarSgte
ret

;***************************************************************

;-------------------------
;CALCULAR DESPLAZAMIENTO
;-------------------------
;  [(fila-1)*longFila]  + [(columna-1)*longElemento]
;  longFila = longElemento * cantidad columnas
calcularDespl:
	sub		rbx,rbx

	mov		bx,word[fila]
	dec		bx				;(fila-1)
	imul	bx,30			;long fila = 30  --> bx = [(fila-1)*longFila] 


	mov		[desplaz],bx	;(fila-1)*longFila

	mov		bx,word[columna]
	dec		bx				;(columna-1)
	imul	bx,2            ;bx = [(columna-1)*longElemento]

	add		word[desplaz],bx	;desplaz = [(fila-1)*longFila]  + [(columna-1)*longElemento]
ret

;***************************************************************

;-----------------------------------
;MOSTRAR POR PANTALLA LA MAYOR SUMA
;-----------------------------------
imprimirMayorSuma:
    sub	rdx,rdx
    sub	rcx,rcx

    mov		rcx,msjSumaMax
    mov		edx,[maxSuma]
    sub		rsp,32
	call	printf
	add		rsp,32
ret