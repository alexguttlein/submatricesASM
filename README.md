# submatricesASM
Compara submatrices y muestra la de mayor sumatoria de columna

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
